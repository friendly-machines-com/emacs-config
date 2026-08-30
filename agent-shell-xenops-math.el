;;; agent-shell-xenops-math.el --- Render LaTeX math in agent-shell buffers via xenops  -*- lexical-binding: t; -*-

;; Keywords: agent-shell, xenops, latex, math, markdown

;;; Commentary:
;;
;; Usage:
;;
;;   (require 'agent-shell-xenops-math)
;;   (add-hook 'agent-shell-mode-hook #'agent-shell-xenops-math-mode)
;;
;; Claimed forms (rewritten where needed, tagged
;; `agent-shell-markdown-frozen', stashed on `agent-shell-markdown-source'
;; for copy-as-markdown, rendered via `xenops-math-render'):
;;
;;   $$...$$            display math -> \begin{equation*} (align* if &)
;;   \[...\] display math, single- or multi-line -> \begin{equation*}
;;     (align* when the body contains &; xenops' bracket parsing is
;;     unreliable here, so all bracket math is rewritten)
;;   \(...\)            inline math -> kept
;;   $...$              inline math -> \(...\) (currency-guarded)
;;   ```math fenced     -> \begin{equation*} around body
;;
;; Environment facts this works around:
;;
;;  * Multi-line \[...\] does not parse reliably (its `^'-anchored
;;    delimiters and the field-clamped line bounds xenops' parsers
;;    use), so display math is rewritten to \begin{equation*}, which
;;    parses at line start.
;;  * agent-shell tags body text with a contiguous `field' run.
;;    Inserting bare replacement text punches a hole in that run,
;;    which breaks xenops' line-bounded parsing at the claim boundary
;;    and mis-aligns agent-shell's own field-respecting scans.  All
;;    inserted text therefore carries the surrounding application
;;    properties (see `agent-shell-markdown--carry-properties').
;;  * xenops' parsers bound searches with field-aware line
;;    primitives; `inhibit-field-text-motion' is bound wherever we
;;    parse or compute line bounds in this buffer.

;;; Code:

(require 'cl-lib)
(require 'map)
(require 'seq)
(require 'subr-x)

;; agent-shell-markdown provides the external-renderer contract
;; (`agent-shell-markdown-render-functions') and the property filter
;; used when inserting claimed text.
(require 'agent-shell-markdown)

(declare-function agent-shell-markdown--carry-properties "agent-shell-markdown" (pos))
(declare-function xenops-math-render "xenops-math" (element &optional cached-only))
(declare-function xenops-math-parse-element-at-point "xenops-math" ())
(declare-function xenops-math-parse-element-from-string "xenops-math" (element-string))
(declare-function xenops-math-parse-element-at "xenops-math" (pos))
(declare-function xenops-mode "xenops" (&optional arg))
(declare-function aio-sem "aio" (n))
(declare-function xenops-math-file-name-static-hash-data "xenops-math" ())

(defvar xenops-cache-directory)
(defvar xenops-math-latex-max-tasks-in-flight)
(defvar xenops-math-latex-tasks-semaphore)
(defvar xenops-mode)
;; Dynamic binding target in `agent-shell-xenops-math--render'.
(defvar xenops-apply-user-point)

(defgroup agent-shell-xenops-math nil
  "Render LaTeX math in agent-shell buffers using xenops."
  :group 'agent-shell)

(defcustom agent-shell-xenops-math-fenced-languages '("math")
  "Fenced-block language names claimed as math and rendered by xenops.
```latex is NOT claimed by default: agents emit whole LaTeX
documents in ```latex blocks, and only display-math fragments
belong here."
  :type '(repeat string))

(defcustom agent-shell-xenops-math-inline-dollars t
  "Claim single-dollar inline math ($x$), rewriting it to \\(x\\).
A currency guard applies: the chars just inside both dollars must
be non-space, so \"$5 and $10\" never matches."
  :type 'boolean)

(defcustom agent-shell-xenops-math-preamble
  '("\\documentclass{article}"
    "\\usepackage{amsmath}"
    "\\usepackage{amssymb}"
    "\\usepackage{mathtools}"
    "\\usepackage{bm}")
  "LaTeX preamble for math rendered in agent-shell buffers."
  :type '(repeat string))

(defcustom agent-shell-xenops-math-enable-xenops-mode t
  "Whether enabling this mode also enables `xenops-mode' in the buffer."
  :type 'boolean)

(defvar-local agent-shell-xenops-math--xenops-by-us nil
  "Whether this mode itself turned on `xenops-mode' in this buffer.
Deactivation turns xenops off only when this is non-nil, so a
user-enabled xenops-mode survives the mode being toggled off.")

;;;###autoload
(define-minor-mode agent-shell-xenops-math-mode
  "Render LaTeX math in this agent-shell buffer using xenops."
  :lighter " xmath"
  (if agent-shell-xenops-math-mode
      (agent-shell-xenops-math--activate)
    (agent-shell-xenops-math--deactivate)))

(defun agent-shell-xenops-math--activate ()
  "Set up xenops rendering for the current buffer."
  (unless (require 'xenops nil t)
    (user-error "xenops is not available"))
  (make-directory xenops-cache-directory t)
  ;; `xenops-math-latex-create-image' awaits this buffer-local; normally
  ;; created by `xenops-math-activate' under `xenops-mode'.
  (unless (bound-and-true-p xenops-math-latex-tasks-semaphore)
    (setq-local xenops-math-latex-tasks-semaphore
                (aio-sem xenops-math-latex-max-tasks-in-flight)))
  (when (and agent-shell-xenops-math-enable-xenops-mode
             (not (bound-and-true-p xenops-mode)))
    (setq agent-shell-xenops-math--xenops-by-us t)
    (xenops-mode 1))
  ;; Both advices are mode-gated in their bodies (no-ops in buffers
  ;; without this mode), so installing them globally is safe.
  (unless (advice-member-p 'agent-shell-xenops-math--preamble-around
                            'xenops-math-latex-get-preamble-lines)
    (advice-add 'xenops-math-latex-get-preamble-lines :around
                #'agent-shell-xenops-math--preamble-around))
  ;; The custom preamble changes the generated LaTeX document, so it
  ;; must be part of the cache identity or stale images are reused.
  (unless (advice-member-p 'agent-shell-xenops-math--hash-data-around
                            'xenops-math-file-name-static-hash-data)
    (advice-add 'xenops-math-file-name-static-hash-data :around
                #'agent-shell-xenops-math--hash-data-around))
  ;; xenops' async completion re-parses at the :begin marker; true
  ;; line bounds and a nudge retry are needed there (see Commentary).
  (unless (advice-member-p 'agent-shell-xenops-math--parse-at-around
                            'xenops-math-parse-element-at)
    (advice-add 'xenops-math-parse-element-at :around
                #'agent-shell-xenops-math--parse-at-around))
  (add-hook 'agent-shell-markdown-render-functions
            #'agent-shell-xenops-math-renderer nil t))

(defun agent-shell-xenops-math--deactivate ()
  "Undo `agent-shell-xenops-math--activate'."
  (remove-hook 'agent-shell-markdown-render-functions
               #'agent-shell-xenops-math-renderer t)
  (when (and agent-shell-xenops-math--xenops-by-us
             (bound-and-true-p xenops-mode))
    (xenops-mode -1))
  (setq agent-shell-xenops-math--xenops-by-us nil))

(defun agent-shell-xenops-math--preamble-around (orig-fn &rest args)
  "Supply a fixed preamble; ORIG-FN's AUCTeX path needs a file/master."
  (if (bound-and-true-p agent-shell-xenops-math-mode)
      agent-shell-xenops-math-preamble
    (apply orig-fn args)))

(defun agent-shell-xenops-math--hash-data-around (orig-fn &rest args)
  "Include `agent-shell-xenops-math-preamble' in xenops' cache identity.
ORIG-FN returns the data hashed into image cache file names
\(`xenops-math-compute-file-name').  The advised preamble changes
the compiled document, so without this a changed preamble reuses
stale images and different preambles collide on identical LaTeX."
  (let ((data (apply orig-fn args)))
    (if (bound-and-true-p agent-shell-xenops-math-mode)
        (append data (list agent-shell-xenops-math-preamble))
      data)))

(defun agent-shell-xenops-math--parse-at-around (orig-fn pos)
  "Advice on `xenops-math-parse-element-at': true line bounds, nudged retry.
ORIG-FN is the original parse; POS the position tried.  Only active
in buffers with `agent-shell-xenops-math-mode' on.

Body text carries `field' properties and xenops' parsers bound
their search with field-aware line primitives -- a boundary inside
the math truncates the line and kills the parse, so
`inhibit-field-text-motion' is bound.  A parse starting exactly on
an opening delimiter can also fail; retry one char inside/before."
  (if (bound-and-true-p agent-shell-xenops-math-mode)
      (let ((inhibit-field-text-motion t))
        (or (funcall orig-fn pos)
            (and (< pos (point-max))
                 (funcall orig-fn (1+ pos)))
            (and (> pos (point-min))
                 (funcall orig-fn (1- pos)))))
    (funcall orig-fn pos)))

;;;###autoload
(defun agent-shell-xenops-math-renderer (context)
  "External agent-shell-markdown renderer: claim math, render via xenops.
CONTEXT is the alist from `agent-shell-markdown-context'."
  (let* ((inhibit-read-only t)
         (langs agent-shell-xenops-math-fenced-languages)
         (blocks (map-elt context :source-blocks))
         ;; ALL fenced blocks (math-language or not, complete or not)
         ;; are avoid-ranges for the delimited scans below: fenced
         ;; content is exclusively `--claim-fenced's business, and a
         ;; still-open ```math fence must not have its body rewritten
         ;; as delimited math before the fence closes.
         (code-ranges
          (append
           (map-elt context :inline-code-ranges)
           (mapcar (lambda (b)
                     (cons (map-nested-elt b '(:block :start))
                           (map-nested-elt b '(:block :end))))
                   blocks)))
         pending)
    ;; 1. Fenced math blocks, by language, back-to-front so replacing
    ;;    one does not disturb the markers of an adjacent one.  Only
    ;;    complete fences; an open one is protected by code-ranges
    ;;    above until its closer arrives.
    (dolist (block (reverse blocks))
      (when (and (member (map-elt block :language) langs)
                 (map-elt block :complete))
        (agent-shell-xenops-math--claim-fenced block)))
    ;; 2. Delimited math.  $$..$$ and multi-line \[..\] become
    ;;    equation*/align* environments (see Commentary).
    (agent-shell-xenops-math--scan
     (rx "$$" (group (*? anychar)) "$$")
     code-ranges #'agent-shell-xenops-math--display-rewrite 2)
    (agent-shell-xenops-math--scan
     (rx "\\[" (group (*? anychar)) "\\]")
     code-ranges #'agent-shell-xenops-math--display-rewrite 2)
    (agent-shell-xenops-math--scan
     (rx "\\(" (group (*? anychar)) "\\)")
     code-ranges nil 2)
    (when agent-shell-xenops-math-inline-dollars
      (agent-shell-xenops-math--scan
       ;; Escape-aware single-dollar math: a `$' inside the content
       ;; must be backslash-escaped (so the matched closer is by
       ;; construction unescaped), and the currency guard requires
       ;; non-space at both ends.  `$x\$$' claims content `x\$'.
       (rx "$"
           (group
            (or (not (any "$ \t\n\\"))
                (seq (or (not (any "$ \t\n\\"))
                         (seq "\\" (not (any "\n"))))
                     (*? (or (not (any "$\\\n"))
                             (seq "\\" (not (any "\n")))))
                     (or (not (any "$ \t\n\\"))
                         (seq "\\" (not (any "\n")))))))
           "$")
       code-ranges
       (lambda (content _start) (concat "\\(" content "\\)"))))
    ;; 3. Unclosed delimiters hold the streaming frontier.
    (setq pending (agent-shell-xenops-math--pending-watermark code-ranges))
    (and pending (list (cons :watermark pending)))))

(defun agent-shell-xenops-math--display-rewrite (content start)
  "Return display-math environment text replacing a match at START.
CONTENT is the math; an environment that xenops parses at line
start is built, opened at its own line (prepending a newline when
the match began mid-line, so the \\begin sits at BOL)."
  (let ((env (if (string-match-p "&" content) "align*" "equation*")))
    (concat (unless (= start (save-excursion
                               (goto-char start)
                               (let (inhibit-field-text-motion)
                                 (line-beginning-position))))
              "\n")
            "\\begin{" env "}\n"
            content
            "\n\\end{" env "}\n")))

(defun agent-shell-xenops-math--code-p (pos code-ranges)
  "Return non-nil when POS falls inside one of CODE-RANGES."
  (seq-some (lambda (r) (and (>= pos (car r)) (< pos (cdr r))))
            code-ranges))

(defun agent-shell-xenops-math--escaped-p (start)
  "Return non-nil when the char before START backslash-escapes it.
An odd run of backslashes immediately before START means the
matched opening delimiter is escaped markdown (e.g. \\$x$, \\\\(x\\\\)),
not math; claiming it would rewrite around the escape and leave
malformed text."
  (cl-loop for pos = (1- start) then (1- pos)
           while (and (>= pos (point-min)) (eq (char-after pos) ?\\))
           count t into n
           finally return (cl-oddp n)))

(defun agent-shell-xenops-math--inside-code-span-p (start)
  "Return non-nil when START sits inside an open inline code span.
A streaming-order fallback for when the context's code ranges lag
the claim: an odd number of backticks between line start and START
means the point is inside an unterminated `code' span, covering
matches anywhere in the span (e.g. `prefix $x$ suffix'), not only
ones adjacent to the delimiters.

`count-matches' sets match data, which `--scan' still needs for
its current match -- wrap it (the unguarded version replaced the
closing backtick of `a` instead of the $x$ that matched)."
  (save-match-data
    (cl-oddp (save-excursion
               (goto-char start)
               (let (inhibit-field-text-motion)
                 (count-matches "`" (line-beginning-position) (point)))))))

(defun agent-shell-xenops-math--scan (regexp code-ranges claim-fn &optional closer-len)
  "Scan the narrowed buffer for REGEXP and claim each match.
CLAIM-FN (content start) returns replacement text; nil keeps it.
CLOSER-LEN, when non-nil, is the length of the closing delimiter:
a match whose closer is backslash-escaped (odd backslashes before
it, e.g. the \\) of an escaped \\\\) is skipped rather than claimed.
Skipped likewise: frozen text, CODE-RANGES, escaped openers, open
code spans, and anything xenops cannot parse."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward regexp nil t)
      (let ((start (match-beginning 0))
            (end (match-end 0))
            (content (match-string 1)))
        (unless (or (get-text-property start 'agent-shell-markdown-frozen)
                    (agent-shell-xenops-math--code-p start code-ranges)
                    (agent-shell-xenops-math--code-p end code-ranges)
                    (agent-shell-xenops-math--escaped-p start)
                    (agent-shell-xenops-math--inside-code-span-p start)
                    (and closer-len
                         (agent-shell-xenops-math--escaped-p (- end closer-len))))
          (let ((rewrite (and claim-fn (funcall claim-fn content start))))
            (when (agent-shell-xenops-math--parseable-p
                   (string-trim (or rewrite
                                    (buffer-substring-no-properties start end))))
              (agent-shell-xenops-math--claim rewrite))))))))

(defun agent-shell-xenops-math--parseable-p (text)
  "Return non-nil when xenops can parse TEXT as a math element.
The claim gate: xenops' async completion re-parses the element at
its marker, and an unparseable claim (prose that merely mentions
math, escaped \\\\begin{...}, half-streamed delimiters) shows up as
\"Failed to parse element at marker\" with no image and an
orphaned waiting overlay.  Parse the candidate in a temp buffer
via `xenops-math-parse-element-from-string' -- no field
properties, no marker drift -- and only claim what parses.  The
streaming case is handled for free: while a closer has not
arrived the candidate does not parse, so it is left alone and
re-examined when the next chunk lands."
  (and (fboundp 'xenops-math-parse-element-from-string)
       (save-match-data
         (not (null (xenops-math-parse-element-from-string text))))))

(defun agent-shell-xenops-math--claim (rewrite)
  "Claim the match-data region: freeze, stash source, render.
REWRITE, when non-nil, replaces the matched text.  The
replacement carries the surrounding application-level properties
\(`field' above all) via `agent-shell-markdown--carry-properties':
inserting bare strings punches a hole in agent-shell's contiguous
`field' run, which both breaks xenops' line-bounded parsing at the
claim boundary and mis-aligns agent-shell's own field-respecting
scans over that text."
  (let* ((start (match-beginning 0))
         (source (buffer-substring-no-properties start (match-end 0)))
         (carried (agent-shell-markdown--carry-properties start)))
    (when rewrite
      (replace-match rewrite t t))
    (let ((end (point)))
      (when carried
        (add-text-properties start end carried))
      (put-text-property start end 'agent-shell-markdown-frozen t)
      (put-text-property start end 'agent-shell-markdown-source source)
      (put-text-property start end 'agent-shell-xenops-math-claimed t)
      (put-text-property start end
                         'rear-nonsticky '(agent-shell-markdown-frozen
                                           agent-shell-markdown-source
                                           agent-shell-xenops-math-claimed))
      (agent-shell-xenops-math--render start))))

(defun agent-shell-xenops-math--claim-fenced (block)
  "Claim fenced math BLOCK, replacing it with a display environment.
Skipped when the replacement does not parse (see
`agent-shell-xenops-math--parseable-p')."
  (let* ((start (marker-position (map-nested-elt block '(:block :start))))
         (end (marker-position (map-nested-elt block '(:block :end))))
         (body (or (map-elt block :body) ""))
         (source (buffer-substring-no-properties start end))
         (env (if (string-match-p "&" body) "align*" "equation*"))
         (replacement
          (if (string-match-p "\\`[ \t\n]*\\\\begin{\\(align\\|equation\\|tikzpicture\\|gather\\)" body)
              (concat (string-trim body) "\n\n")
            (concat "\\begin{" env "}\n" body "\n\\end{" env "}\n\n"))))
    (when (agent-shell-xenops-math--parseable-p (string-trim replacement))
      (let ((carried (agent-shell-markdown--carry-properties start)))
        (delete-region start end)
        (goto-char start)
        (insert replacement)
        (when carried
          (add-text-properties start (point) carried))
        (put-text-property start (point) 'agent-shell-markdown-frozen t)
        (put-text-property start (point) 'agent-shell-markdown-source source)
        (put-text-property start (point) 'agent-shell-xenops-math-claimed t)
        (put-text-property start (point)
                           'rear-nonsticky '(agent-shell-markdown-frozen
                                             agent-shell-markdown-source
                                             agent-shell-xenops-math-claimed))
        (agent-shell-xenops-math--render start)))))

(defun agent-shell-xenops-math--render (pos)
  "Hand the math element at POS to xenops.
Cached fragments display synchronously; others compile async.
Errors are reported rather than swallowed, so a failing render is
diagnosable; the region is already frozen, and
`agent-shell-xenops-math-render-missing' re-renders it later."
  (when (fboundp 'xenops-math-render)
    (with-demoted-errors "agent-shell-xenops-math render: %S"
      (save-excursion
        (save-restriction
          (widen)
          (goto-char pos)
          (let ((element (let ((inhibit-field-text-motion t))
                           (xenops-math-parse-element-at-point))))
            (when element
              ;; Render in place, not below point.
              (let ((xenops-apply-user-point (point-min)))
                (xenops-math-render element)))))))))

(defun agent-shell-xenops-math--closer-end (closer-regexp from)
  "Return the end position of the first unescaped closer after FROM.
Escaped closers are content, not the end of the element, so the
search steps past them.  Nil when there is none."
  (save-excursion
    (save-match-data
      (goto-char from)
      (catch 'found
        (while (re-search-forward closer-regexp nil t)
          (if (agent-shell-xenops-math--escaped-p (match-beginning 0))
              (goto-char (match-end 0))
            (throw 'found (match-end 0))))
        nil))))

(defun agent-shell-xenops-math--pending-watermark (code-ranges)
  "Return the start of an unclosed math delimiter in the narrowed region.
Fenced, escaped, and code-span delimiters do not pin the frontier."
  (let (pending)
    (dolist (pair '(("\\$\\$" . "\\$\\$")
                    ("\\\\(" . "\\\\)")
                    ("\\\\\\[" . "\\\\\\]")))
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward (car pair) nil t)
          (let ((start (match-beginning 0))
                (after-opener (point)))
            (unless (or (get-text-property start 'agent-shell-markdown-frozen)
                        (agent-shell-xenops-math--code-p start code-ranges)
                        (agent-shell-xenops-math--escaped-p start)
                        (agent-shell-xenops-math--inside-code-span-p start))
              (let ((closer-end (agent-shell-xenops-math--closer-end
                                 (cdr pair) after-opener)))
                (if closer-end
                    ;; Continue opener scanning past the closer, so
                    ;; closers are never re-read as openers.
                    (goto-char closer-end)
                  (setq pending (min (or pending (point-max)) start))
                  (goto-char (point-max)))))))))
    (and pending (/= pending (point-max)) pending)))

(defun agent-shell-xenops-math-render-missing ()
  "Render claimed math that has no image, clearing stale waiting overlays.
Sweeps the whole buffer for math lacking an image (e.g. after an
async completion lost its element mid-stream), drops any stale
waiting overlay on it, and re-renders it."
  (interactive)
  (agent-shell-xenops-math--sweep))

(defun agent-shell-xenops-math--sweep ()
  "Re-render claimed math lacking an image in the current buffer.
Only spans carrying `agent-shell-xenops-math-claimed' are touched:
`agent-shell-markdown-frozen' alone is not enough, since agent-shell
freezes whole rendered tables (whose cells may contain raw $x$ this
mode never claimed).  A waiting overlay does not count as an image;
it is deleted first, otherwise `xenops-math-render' is a no-op."
  (let ((inhibit-read-only t)
        (n 0))
    (save-excursion
      (save-restriction
        (widen)
        (goto-char (point-min))
        (while (re-search-forward
                ;; Mirrors what --claim-fenced can leave behind:
                ;; align/equation/gather/tikzpicture, starred or not,
                ;; plus the delimited forms.
                (rx (or "\\begin{equation" "\\begin{align"
                        "\\begin{gather" "\\begin{tikzpicture"
                        "\\[" "\\(" "$"))
                nil t)
          (let ((pos (match-beginning 0)))
            (when (and (get-text-property pos 'agent-shell-xenops-math-claimed)
                       (not (seq-some (lambda (ov)
                                        (and (overlay-get ov 'display)
                                             (<= (overlay-start ov) pos)
                                             (> (overlay-end ov) pos)))
                                      (overlays-at pos))))
              ;; Drop any stale waiting overlay first: it makes
              ;; `xenops-math-render' a no-op.
              (dolist (ov (overlays-at pos))
                (when (eq (overlay-get ov 'xenops-overlay-type)
                          'xenops-math-waiting)
                  (delete-overlay ov)))
              (agent-shell-xenops-math--render pos)
              (setq n (1+ n)))))))
    n))

(provide 'agent-shell-xenops-math)

;;; agent-shell-xenops-math.el ends here
