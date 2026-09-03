;;; agent-shell-org-math.el --- Render LaTeX math in agent-shell via org-latex-preview  -*- lexical-binding: t; -*-

;; Keywords: agent-shell, org, latex, math, markdown

;;; Commentary:
;;
;; Usage:
;;
;;   (require 'agent-shell-org-math)
;;   (add-hook 'agent-shell-mode-hook #'agent-shell-org-math-mode)
;;
;; Drop-in sibling of `agent-shell-xenops-math' that renders through
;; Org's LaTeX preview machinery (`org-latex-preview-place') instead
;; of xenops.  Requires Org >= 9.7 and the programs `latex' and
;; `dvisvgm' (or set `agent-shell-org-math-process' to `dvipng').
;;
;; Why this is so much smaller than the xenops version:
;;
;;  `org-latex-preview-place' takes EXPLICIT entries -- (BEG END) or
;;  (BEG END VALUE) buffer positions plus an explicit LaTeX preamble
;;  -- and never parses the buffer.  Every workaround the xenops
;;  module carried is therefore unnecessary:
;;
;;  * No rewrite to \begin{equation*} at BOL: org does not need the
;;    fragment to start a line, so $$..$$, multi-line \[..\], \(..\)
;;    and $..$ are claimed and overlaid RAW.  No text is modified for
;;    delimited math, so agent-shell's contiguous `field' run is never
;;    punched (only fenced blocks insert replacement text, still via
;;    `agent-shell-markdown--carry-properties').
;;  * No `inhibit-field-text-motion' gymnastics: the placement path
;;    uses no line-bounded primitives (`--face-around' reads text
;;    properties only), and async completion updates the OVERLAY
;;    object it captured -- it never re-parses the buffer at a marker.
;;  * No preamble advice: the preamble is an argument to
;;    `org-latex-preview-place' (and is hashed into the image cache
;;    key, so no cache-identity advice either).
;;  * No parse gate: a fragment that fails to compile shows a fringe
;;    "!" and a help-echo with the LaTeX error, and does not disturb
;;    its siblings (one latex run batches all uncached fragments).
;;  * No semaphore/xenops-mode setup: no minor mode is enabled here;
;;    in particular `org-latex-preview-mode' (the cursor-tracking
;;    auto machinery, which DOES use org parsing) stays off.
;;
;; Claimed forms (frozen, source stashed on
;; `agent-shell-markdown-source' for copy-as-markdown, rendered via
;; `org-latex-preview-place'):
;;
;;   $$...$$            display math, multi-line ok, claimed raw
;;   \[...\]            display math, multi-line ok, claimed raw
;;   \(...\)            inline math, kept raw
;;   $...$              inline math, kept raw (currency-guarded)
;;   ```math fenced     -> \begin{equation*}/align* around body
;;
;; Other facts worth knowing:
;;
;;  * Cached fragments display synchronously (~1ms); a re-render pass
;;    over already-claimed math is effectively free.  Images persist
;;    via `org-persist' (`org-latex-preview-cache').
;;  * Colours follow the buffer's faces (`:foreground auto' etc. in
;;    `org-latex-preview-appearance-options').
;;  * The preamble MUST load a colour package: org-latex-preview
;;    emits \pagecolor[rgb]/\color[rgb] around every fragment.

;;; Code:

(require 'cl-lib)
(require 'map)
(require 'rx)
(require 'seq)
(require 'subr-x)

;; agent-shell-markdown provides the external-renderer contract
;; (`agent-shell-markdown-render-functions') and the property filter
;; used when inserting claimed text.
(require 'agent-shell-markdown)

(declare-function agent-shell-markdown--carry-properties "agent-shell-markdown" (pos))
(declare-function agent-shell-markdown-context "agent-shell-markdown" ())
(declare-function org-latex-preview-place "org-latex-preview"
                  (processing-type entries &optional numbering-offsets latex-preamble))
(declare-function org-latex-preview-clear-overlays "org-latex-preview" (&optional beg end))

(defgroup agent-shell-org-math nil
  "Render LaTeX math in agent-shell buffers using org-latex-preview."
  :group 'agent-shell)

(defcustom agent-shell-org-math-fenced-languages '("math")
  "Fenced-block language names claimed as math and rendered by org.
```latex is NOT claimed by default: agents emit whole LaTeX
documents in ```latex blocks, and only display-math fragments
belong here."
  :type '(repeat string))

(defcustom agent-shell-org-math-inline-dollars t
  "Claim single-dollar inline math ($x$).
A currency guard applies: the chars just inside both dollars must
be non-space, so \"$5 and $10\" never matches."
  :type 'boolean)

(defcustom agent-shell-org-math-preamble
  '("\\documentclass{article}"
    "\\usepackage{amsmath}"
    "\\usepackage{amssymb}"
    "\\usepackage{mathtools}"
    "\\usepackage{bm}"
    ;; org-latex-preview emits \pagecolor[rgb]{...}/\color[rgb]{...}
    ;; around each fragment; without a colour package every preview
    ;; dies on "Undefined control sequence".
    "\\usepackage{xcolor}")
  "LaTeX preamble lines for math rendered in agent-shell buffers.
Passed to `org-latex-preview-place' verbatim and hashed into the
image cache key, so changing it invalidates stale images by itself."
  :type '(repeat string))

(defcustom agent-shell-org-math-process 'dvisvgm
  "Image conversion backend, a key of `org-latex-preview-process-alist'.
dvisvgm (default) needs the programs `latex' and `dvisvgm'; dvipng
needs `latex' and `dvipng'."
  :type '(choice (const :tag "dvi -> svg (vector, theme-aware)" dvisvgm)
                 (const :tag "dvi -> png" dvipng)
                 (const :tag "pdf -> png (imagemagick)" imagemagick)))

(defvar agent-shell-org-math--claim-id 0
  "Last issued claim identity, stored as the
`agent-shell-org-math-claimed' property value.  Identities are
unique per claim so that ADJACENT claims form distinct property
intervals -- a plain t would merge them ($x$$y$ would sweep as one
span and the second element could never be repaired).")

(defvar agent-shell-org-math--entries nil
  "Entries accumulated by the current render pass, most recent first.
Each entry is (MARKER-BEG MARKER-END VALUE); see
`agent-shell-org-math--flush' for why the value is captured at
claim time.  Bound dynamically by `agent-shell-org-math-renderer'
and flushed to `org-latex-preview-place' once at the end, so all
fresh fragments of a pass share one latex run.")

(defvar-local agent-shell-org-math--recovery-needed nil
  "Whether a failed Org preview batch left claims needing recovery.
Set by `agent-shell-org-math--process-finished' and consumed by the
next renderer pass, so normal streaming passes stay bounded to their
narrowed region instead of sweeping the whole accumulated buffer.")

;;;###autoload
(define-minor-mode agent-shell-org-math-mode
  "Render LaTeX math in this agent-shell buffer using org-latex-preview."
  :lighter " omath"
  (if agent-shell-org-math-mode
      (agent-shell-org-math--activate)
    (agent-shell-org-math--deactivate)))

(defun agent-shell-org-math--activate ()
  "Set up org-latex-preview rendering for the current buffer."
  (unless (require 'org-latex-preview nil t)
    (user-error "org-latex-preview is not available (needs Org >= 9.7)"))
  (unless (fboundp 'org-latex-preview-place)
    (user-error "Org too old for LaTeX previews: no `org-latex-preview-place'"))
  (add-hook 'agent-shell-markdown-render-functions
            #'agent-shell-org-math-renderer nil t)
  (add-hook 'org-latex-preview-process-finish-functions
            #'agent-shell-org-math--process-finished nil t)
  ;; Claims from a previous activation in this buffer are still
  ;; frozen but lost their overlays on deactivation: re-render them.
  (agent-shell-org-math-render-missing)
  ;; Interactively enabling the mode in an already-populated buffer
  ;; should also CLAIM the raw math that is already there -- with the
  ;; REAL agent-shell-markdown context, so fenced code blocks are
  ;; avoid-ranges and math-like text inside them ("$$not math$$" in a
  ;; ```text block) is not claimed.  Without the context builder we
  ;; skip the claiming scan entirely: an empty fabricated context
  ;; would claim fenced content.
  (when (fboundp 'agent-shell-markdown-context)
    (save-excursion
      (save-restriction
        (widen)
        (agent-shell-org-math-renderer
         (agent-shell-markdown-context))))))

(defun agent-shell-org-math--our-overlay-p (ov)
  "Return non-nil when OV is an Org LaTeX preview over our claim.
Deactivation must not touch previews this mode does not own (a
user's `org-latex-preview' overlays in the same buffer)."
  (and (eq (overlay-get ov 'org-overlay-type) 'org-latex-overlay)
       (get-text-property (overlay-start ov)
                          'agent-shell-org-math-claimed)))

(defun agent-shell-org-math--deactivate ()
  "Undo `agent-shell-org-math--activate'.
Removes THIS MODE's preview overlays only; the claimed text stays
frozen and fenced blocks stay rewritten (their markdown source
remains stashed for copy-as-markdown), so re-enabling the mode
restores the images."
  (remove-hook 'agent-shell-markdown-render-functions
               #'agent-shell-org-math-renderer t)
  (remove-hook 'org-latex-preview-process-finish-functions
               #'agent-shell-org-math--process-finished t)
  (setq agent-shell-org-math--recovery-needed nil)
  (dolist (ov (overlays-in (point-min) (point-max)))
    (when (agent-shell-org-math--our-overlay-p ov)
      (delete-overlay ov))))

(defun agent-shell-org-math--flush (entries)
  "Hand ENTRIES to `org-latex-preview-place' in one batch.
Each entry is (MARKER-BEG MARKER-END VALUE): markers are resolved
to positions NOW -- after every claim of the pass has finished
mutating the buffer -- because claims collected earlier in the
pass (plain integer bounds) would otherwise be shifted by the
insertions of later claims (e.g. fenced replacements), and
`org-latex-preview-place' would compile whatever text now sits at
the stale positions.  VALUE is passed explicitly for the same
reason.  Errors are demoted so a failing preview never breaks the
render pass; failures are visible as a fringe \"!\" plus error
help-echo, and `agent-shell-org-math-render-missing' retries
them."
  (condition-case-unless-debug err
      (org-latex-preview-place
       agent-shell-org-math-process
       (mapcar (lambda (e)
                 (list (marker-position (nth 0 e))
                       (marker-position (nth 1 e))
                       (nth 2 e)))
               entries)
       nil
       (string-join agent-shell-org-math-preamble "\n"))
    (error
     ;; Errors before Org starts its async process (for example, a
     ;; missing executable) never reach the process-finish hook.
     (setq agent-shell-org-math--recovery-needed t)
     (message "agent-shell-org-math: %S" err)
     nil)))

(defun agent-shell-org-math-clear-error-markings ()
  "Clear error markings on OUR previews that also show an image.
Org deliberately allows an overlay to carry both an image and an
error (e.g. a recovered compile), so this is NOT done
automatically -- only on demand, and only for previews over this
mode's claims."
  (interactive)
  (dolist (ov (overlays-in (point-min) (point-max)))
    (when (and (agent-shell-org-math--our-overlay-p ov)
               (overlay-get ov 'display)
               (overlay-get ov 'help-echo))
      (overlay-put ov 'help-echo nil)
      (overlay-put ov 'face nil)
      (overlay-put ov 'before-string nil)
      (when (eq (overlay-get ov 'hidden-face) 'error)
        (overlay-put ov 'hidden-face nil)))))

;;;###autoload
(defun agent-shell-org-math-renderer (context)
  "External agent-shell-markdown renderer: claim math, render via org.
CONTEXT is the alist from `agent-shell-markdown-context'."
  (let* ((inhibit-read-only t)
         (langs agent-shell-org-math-fenced-languages)
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
         (agent-shell-org-math--entries nil)
         pending)
    ;; 0. Self-heal only after Org reports that one of our preview
    ;;    batches failed.  A normal streaming pass must not widen and
    ;;    sweep the whole accumulated buffer: agent-shell deliberately
    ;;    narrows renderers to its watermark region.
    (when agent-shell-org-math--recovery-needed
      (setq agent-shell-org-math--recovery-needed nil)
      (agent-shell-org-math-render-missing))
    ;; 1. Fenced math blocks, by language, back-to-front so replacing
    ;;    one does not disturb the markers of an adjacent one.  Only
    ;;    complete fences; an open one is protected by code-ranges
    ;;    above until its closer arrives.
    (dolist (block (reverse blocks))
      (when (and (member (map-elt block :language) langs)
                 (map-elt block :complete))
        (agent-shell-org-math--claim-fenced block)))
    ;; 2. Delimited math, claimed raw -- no rewriting needed, since
    ;;    org-latex-preview-place takes explicit positions.  ORDER:
    ;;    bracketed forms, then $$ display, then single-$ inline.
    ;;    Display content excludes UNESCAPED `$', so a display pair
    ;;    cannot reach across the inner `$$' of an `$x$$y$' run --
    ;;    while a backslash-escaped dollar (valid LaTeX, e.g.
    ;;    $$\text{cost \$5}$$) is still allowed as content.  The
    ;;    display scan freezing first lets the adjacency guards of
    ;;    the single-$ scan accept the flanking inline fragments of
    ;;    `$x$$$y$$' and `$$x$$$y$'.
    (agent-shell-org-math--scan
     (rx "\\[" (group (*? anychar)) "\\]")
     code-ranges "\\]")
    (agent-shell-org-math--scan
     (rx "\\(" (group (*? anychar)) "\\)")
     code-ranges "\\)")
    (agent-shell-org-math--scan
     (rx "$$"
         (group (*? (or (not (any "$"))
                        (seq "\\" "$"))))
         "$$")
     code-ranges "$$")
    (when agent-shell-org-math-inline-dollars
      (agent-shell-org-math--scan
       ;; Escape-aware single-dollar math: a `$' inside the content
       ;; must be backslash-escaped (so the matched closer is by
       ;; construction unescaped), and the currency guard requires
       ;; non-space at both ends.  `$x\$$' claims content `x\$'.
       (rx "$"
           (group
            (or (not (any "$ \t\n\\"))
                (seq "\\" (not (any "\n")))
                (seq (or (not (any "$ \t\n\\"))
                         (seq "\\" (not (any "\n"))))
                     (*? (or (not (any "$\\\n"))
                             (seq "\\" (not (any "\n")))))
                     (or (not (any "$ \t\n\\"))
                         (seq "\\" (not (any "\n")))))))
           "$")
       code-ranges
       "$"
       (lambda (start end)
         ;; Adjacent-dollar guards, streaming-aware.  A delimiter
         ;; that was written \$ (decoded to $ by the escape pass) is
         ;; prose, not math.  A dollar on the LEFT is fine when it
         ;; is already part of a claim -- the closer of `$x$' in
         ;; `$x$$y$' -- but otherwise the match may be the tail of a
         ;; $$ construct still streaming (`$$x$' must stay raw until
         ;; `$$x$$' arrives).  A dollar on the RIGHT is fine unless
         ;; it opens a $$ (a display construct may still be waiting
         ;; for its closer).
         (or (agent-shell-org-math--escaped-dollar-p start)
             (agent-shell-org-math--escaped-dollar-p (1- end))
             (and (eq (char-before start) ?$)
                  (not (get-text-property (1- start)
                                          'agent-shell-markdown-frozen)))
             (and (eq (char-after end) ?$)
                  (not (get-text-property end
                                          'agent-shell-markdown-frozen))
                  (eq (char-after (1+ end)) ?$))))))
    ;; 3. Render every fresh claim of this pass in one latex run.
    (when agent-shell-org-math--entries
      (setq agent-shell-org-math--entries
            (nreverse agent-shell-org-math--entries))
      (unwind-protect
          (agent-shell-org-math--flush agent-shell-org-math--entries)
        ;; Detach every entry's markers -- `nreverse' is destructive,
        ;; so this must walk the very list that was flushed.
        (mapc (lambda (e)
                (set-marker (nth 0 e) nil)
                (set-marker (nth 1 e) nil))
              agent-shell-org-math--entries)))
    ;; 4. Unclosed delimiters hold the streaming frontier.
    (setq pending (agent-shell-org-math--pending-watermark code-ranges))
    (and pending (list (cons :watermark pending)))))

(defun agent-shell-org-math--code-p (pos code-ranges)
  "Return non-nil when POS falls inside one of CODE-RANGES."
  (seq-some (lambda (r) (and (>= pos (car r)) (< pos (cdr r))))
            code-ranges))

(defun agent-shell-org-math--escaped-p (start)
  "Return non-nil when the char before START backslash-escapes it.
An odd run of backslashes immediately before START means the
matched opening delimiter is escaped markdown (e.g. \\$x$, \\\\(x\\\\)),
not math; claiming it would rewrite around the escape and leave
malformed text."
  (cl-loop for pos = (1- start) then (1- pos)
           while (and (>= pos (point-min)) (eq (char-after pos) ?\\))
           count t into n
           finally return (cl-oddp n)))

(defun agent-shell-org-math--escaped-dollar-p (pos)
  "Return non-nil when the $ at POS was written as an escaped \\$.
agent-shell's escape pass decodes \\$ to a literal $ between
render passes; the escape then exists only as the
`agent-shell-markdown-source' property on the decoded character.
A match using such a $ as a delimiter must be skipped, or escaped
prose (\\$x\\$) turns into claimed math one pass after the
renderer correctly declined it."
  (equal (get-text-property pos 'agent-shell-markdown-source) "\\$"))

(defun agent-shell-org-math--inside-code-span-p (start)
  "Return non-nil when START sits inside an open inline code span.
A streaming-order fallback for when the context's code ranges lag
the claim.  CommonMark-style: a backtick run of length N opens a
span that only a run of the same length closes; runs of other
lengths inside an open span are literal text, and escaped
backticks are not delimiters.  So ``foo ` bar`` closes fully and
does not suppress a later $x$.

`re-search-forward' sets match data, which `--scan' still needs
for its current match -- hence `save-match-data'."
  (save-match-data
    (save-excursion
      (goto-char start)
      (let (inhibit-field-text-motion)
        (let ((bol (line-beginning-position))
              (active nil))
          (goto-char bol)
          (while (re-search-forward "`+" start t)
            (unless (agent-shell-org-math--escaped-p
                     (match-beginning 0))
              (let ((len (- (match-end 0) (match-beginning 0))))
                (cond ((eq active len) (setq active nil))
                      ((null active) (setq active len))))))
          active)))))

(defun agent-shell-org-math--empty-fragment-p (source)
  "Return non-nil when SOURCE is a math delimiter pair with only
whitespace inside (\"$$  $$\", \"\\\\[ \\\\]\", \"$$\").  Org
intentionally creates no image for such fragments, so claiming one
would leave a span the recovery sweep forever tries to repair."
  (or (string= source "$$")
      (and (>= (length source) 4)
           (let* ((open-len (cond ((string-prefix-p "$$" source) 2)
                                  ((string-prefix-p "$" source) 1)
                                  ((string-prefix-p "\\[" source) 2)
                                  ((string-prefix-p "\\(" source) 2)
                                  (t 0)))
                  (close-len (cond ((string-suffix-p "$$" source) 2)
                                   ((string-suffix-p "$" source) 1)
                                   ((string-suffix-p "\\]" source) 2)
                                   ((string-suffix-p "\\)" source) 2)
                                   (t 0))))
             (and (= open-len close-len)
                  (> open-len 0)
                  (string-match-p "\\`[ \t\n\r]*\\'"
                                  (substring source
                                             open-len
                                             (- (length source)
                                                close-len))))))))

(defun agent-shell-org-math--scan (regexp code-ranges &optional closer-str skip-fn)
  "Scan the narrowed buffer for REGEXP and claim each match.
CLOSER-STR, when non-nil, is the closing delimiter: a match whose
closer is backslash-escaped (odd backslashes before it) is not
dropped -- the match is extended to the next unescaped closer, as
the watermark scan does, so a later real closer still claims the
element.  With no unescaped closer at all the text is left raw.
Skipped likewise: frozen text, CODE-RANGES, escaped openers, open
code spans, whitespace-only fragments (see
`agent-shell-org-math--empty-fragment-p'), and whatever SKIP-FN
(called with the match bounds) rejects.

The matched text is claimed as-is (no rewrite): positions are all
`org-latex-preview-place' needs."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward regexp nil t)
      (let ((start (match-beginning 0))
            (end (match-end 0)))
        (unless (or (get-text-property start 'agent-shell-markdown-frozen)
                    (agent-shell-org-math--code-p start code-ranges)
                    (agent-shell-org-math--code-p end code-ranges)
                    (agent-shell-org-math--escaped-p start)
                    (agent-shell-org-math--inside-code-span-p start)
                    ;; The CLOSER must not sit inside a code span either:
                    ;; a span like `=$=` supplies a `$' that pairs with a
                    ;; prose dollar -- "$10, so `$`" would otherwise be
                    ;; claimed as math spanning the span boundary.
                    (and closer-str
                         (agent-shell-org-math--inside-code-span-p
                          (- end (length closer-str))))
                    (and skip-fn (funcall skip-fn start end)))
          (when (and closer-str
                     (agent-shell-org-math--escaped-p
                      (- end (length closer-str))))
            (let* ((cstart (agent-shell-org-math--closer-start
                            (regexp-quote closer-str) end))
                   (cend (and cstart (+ cstart (length closer-str)))))
              (cond
               ((not cstart)
                (setq end nil))   ; no unescaped closer: leave raw
               ;; The EXTENDED closer must pass the same checks the
               ;; original match went through: it may not land in a
               ;; code range, inside an inline code span, or on
               ;; already-frozen text.  Otherwise the claim would
               ;; freeze part of a code span as math.
               ((or (agent-shell-org-math--code-p cstart code-ranges)
                    (agent-shell-org-math--code-p cend code-ranges)
                    (agent-shell-org-math--inside-code-span-p cstart)
                    (get-text-property cstart
                                       'agent-shell-markdown-frozen))
                (setq end nil))
               (t
                ;; Whole match ends after the closer.
                (set-match-data (list start cend))
                (setq end cend)))))
          (when (and end
                     (not (agent-shell-org-math--empty-fragment-p
                           (buffer-substring-no-properties start end))))
            (agent-shell-org-math--claim)))))))

(defun agent-shell-org-math--claim ()
  "Claim the match-data region: freeze, stash source, queue preview.
No text is modified; the queued entry is (MARKER-BEG MARKER-END
VALUE) -- the value is captured NOW, and the bounds are markers,
because later claims of the same pass may still insert text (see
`agent-shell-org-math--flush')."
  (let* ((start (match-beginning 0))
         (end (match-end 0))
         (source (buffer-substring-no-properties start end)))
    (put-text-property start end 'agent-shell-markdown-frozen t)
    (put-text-property start end 'agent-shell-markdown-source source)
    (put-text-property start end 'agent-shell-org-math-claimed
                       (setq agent-shell-org-math--claim-id
                             (1+ agent-shell-org-math--claim-id)))
    (put-text-property start end
                       'rear-nonsticky '(agent-shell-markdown-frozen
                                         agent-shell-markdown-source
                                         agent-shell-org-math-claimed))
    (push (list (copy-marker start t) (copy-marker end) source)
          agent-shell-org-math--entries)))

(defun agent-shell-org-math--claim-fenced (block)
  "Claim fenced math BLOCK, replacing it with a display environment.
Only fenced blocks need replacement text: their body is bare math
with no delimiters of its own.  Whitespace-only bodies are left
alone (org produces no image for them; see
`agent-shell-org-math--empty-fragment-p')."
  (let* ((start (marker-position (map-nested-elt block '(:block :start))))
         (end (marker-position (map-nested-elt block '(:block :end))))
         (body (or (map-elt block :body) ""))
         (source (buffer-substring-no-properties start end))
         (env (if (string-match-p "&" body) "align*" "equation*"))
         (replacement
          (if (string-match-p "\\`[ \t\n]*\\\\begin{\\(align\\|equation\\|tikzpicture\\|gather\\)" body)
              (concat (string-trim body) "\n\n")
            (concat "\\begin{" env "}\n" body "\n\\end{" env "}\n\n"))))
    (unless (string-blank-p body)
      (let ((carried (agent-shell-markdown--carry-properties start)))
        (delete-region start end)
        (goto-char start)
        (insert replacement)
        (when carried
          (add-text-properties start (point) carried))
        (put-text-property start (point) 'agent-shell-markdown-frozen t)
        (put-text-property start (point) 'agent-shell-markdown-source source)
        (put-text-property start (point) 'agent-shell-org-math-claimed
                           (setq agent-shell-org-math--claim-id
                                 (1+ agent-shell-org-math--claim-id)))
        (put-text-property start (point)
                           'rear-nonsticky '(agent-shell-markdown-frozen
                                             agent-shell-markdown-source
                                             agent-shell-org-math-claimed))
        ;; Markers + captured value: an earlier-claimed fence (or any
        ;; other claim of this pass) may still shift the buffer.  The
        ;; START marker must be advancing: replacing an ADJACENT earlier
        ;; fence inserts at exactly this claim's start position, and a
        ;; non-advancing marker would stay before the inserted text,
        ;; overlapping the earlier claim's replacement.  The END marker
        ;; stays non-advancing: text inserted at the end position is
        ;; after the claim, not part of it.
        (push (list (copy-marker start t) (copy-marker (point)) replacement)
              agent-shell-org-math--entries)))))

(defun agent-shell-org-math--closer-start (closer-regexp from)
  "Return the start of the first unescaped closer after FROM.
Escaped closers are content, so the search steps past them.  Nil
when there is none."
  (save-excursion
    (save-match-data
      (goto-char from)
      (catch 'found
        (while (re-search-forward closer-regexp nil t)
          (if (agent-shell-org-math--escaped-p (match-beginning 0))
              (goto-char (match-end 0))
            (throw 'found (match-beginning 0))))
        nil))))

(defun agent-shell-org-math--closer-end (closer-regexp from)
  "Return the end position of the first unescaped closer after FROM.
Escaped closers are content, not the end of the element, so the
search steps past them.  Nil when there is none."
  (save-excursion
    (save-match-data
      (goto-char from)
      (catch 'found
        (while (re-search-forward closer-regexp nil t)
          (if (agent-shell-org-math--escaped-p (match-beginning 0))
              (goto-char (match-end 0))
            (throw 'found (match-end 0))))
        nil))))

(defun agent-shell-org-math--closer-end-safe (closer-regexp from code-ranges)
  "Like `--closer-end', but skip closers that are not real closers.
A closer inside a fenced/inline code range, inside an open code
span, on frozen text, or backslash-escaped is CONTENT, not the end
of a math element.  The watermark must not mistake it for one, or
a still-open construct would lose its hold on the streaming
frontier and a later legitimate closer could never complete it."
  (save-excursion
    (save-match-data
      (goto-char from)
      (catch 'found
        (while (re-search-forward closer-regexp nil t)
          (if (or (agent-shell-org-math--escaped-p (match-beginning 0))
                  (agent-shell-org-math--code-p (match-beginning 0) code-ranges)
                  (agent-shell-org-math--code-p (point) code-ranges)
                  (agent-shell-org-math--inside-code-span-p (match-beginning 0))
                  (get-text-property (match-beginning 0)
                                     'agent-shell-markdown-frozen))
              (goto-char (match-end 0))
            (throw 'found (match-end 0))))
        nil))))

(defun agent-shell-org-math--pending-watermark (code-ranges)
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
                        (agent-shell-org-math--code-p start code-ranges)
                        (agent-shell-org-math--escaped-p start)
                        (agent-shell-org-math--inside-code-span-p start))
              (let ((closer-end (agent-shell-org-math--closer-end-safe
                                 (cdr pair) after-opener code-ranges)))
                (if closer-end
                    ;; Continue opener scanning past the closer, so
                    ;; closers are never re-read as openers.
                    (goto-char closer-end)
                  (setq pending (min (or pending (point-max)) start))
                  (goto-char (point-max)))))))))
    (and pending (/= pending (point-max)) pending)))

(defun agent-shell-org-math--conversion-running-p ()
  "Return non-nil when any Org LaTeX preview conversion is running.
Org runs latex/dvisvgm as asynchronous processes whose process
buffer is named after `org-latex-preview--latex-log' or
`--image-log' (org itself uses a live process on the log buffer to
decide whether to start a second one).  A live process on any such
buffer therefore means work is in flight -- and when
`org-latex-preview-process-active-indicator' is nil, overlays in
progress carry NO marker at all, so this is the only fallback signal.
Callers must apply it only to an existing empty overlay: a process in
another buffer cannot own a claim that has no overlay here."
  (seq-some
   (lambda (buf)
     (and (buffer-live-p buf)
          (get-buffer-process buf)
          t))
   (seq-filter
    (lambda (buf)
      (string-match-p "\\`\\*Org Preview \\(LaTeX\\|Convert\\) Output"
                      (buffer-name buf)))
    (buffer-list))))

(defun agent-shell-org-math--process-finished (exit-code _process-buffer
                                                         extended-info)
  "Remember a failed Org preview batch for a later bounded recovery.
EXIT-CODE and EXTENDED-INFO are supplied by
`org-latex-preview-process-finish-functions'.  Only a failed batch
containing one of this mode's overlays marks its originating buffer.
Org runs this hook before its failure callback deletes those overlays;
the next agent-shell renderer pass performs the recovery after the
callback chain has finished."
  (when (/= exit-code 0)
    (when-let* ((buffer (plist-get extended-info :org-buffer))
                ((buffer-live-p buffer)))
      (with-current-buffer buffer
        (when (and agent-shell-org-math-mode
                   (seq-some
                    (lambda (fragment)
                      (when-let* ((ov (plist-get fragment :overlay))
                                  ((overlay-buffer ov)))
                        (agent-shell-org-math--our-overlay-p ov)))
                    (plist-get extended-info :fragments)))
          (setq agent-shell-org-math--recovery-needed t))))))

(defun agent-shell-org-math-render-missing ()
  "Re-render claimed math that shows no image and no error.
Sweeps the whole buffer for our claims whose overlay is missing
(never produced, or removed by a failed compile) and re-places
them in one batch.  Done states: an image, a reported error (the
fringe \"!\" carries it in help-echo), or a conversion IN
PROGRESS (org indicates that with a before-string fringe marker
or the processing face) -- deleting and re-queueing those would
duplicate running conversions.  Whitespace-only claims are left
alone: org intentionally renders nothing for them.  When Org's
active indicator is disabled, an existing empty overlay is treated
as in progress while any Org preview process is active; a completely
missing overlay is always eligible for recovery."
  (interactive)
  (let ((inhibit-read-only t)
        (entries nil)
        (n 0)
        ;; This fallback is intentionally computed once, not once per
        ;; claim.  It is needed only when Org was configured not to mark
        ;; active overlays itself.
        (conversion-running
         (and (not (bound-and-true-p
                    org-latex-preview-process-active-indicator))
              (agent-shell-org-math--conversion-running-p))))
    (save-excursion
      (save-restriction
        (widen)
        (goto-char (point-min))
        (let ((pos (point-min))
              (max (point-max)))
          ;; ONE unconditional advance per iteration: compute the span
          ;; end first, act on the span only when it is ours.  (An
          ;; if/then/else version of this loop once spun forever on
          ;; unclaimed text because the else arm had been mis-parsed
          ;; into the then arm -- this shape cannot do that.)
          (while (< pos max)
            (let ((claim-end
                   (or (next-single-property-change
                        pos 'agent-shell-org-math-claimed nil max)
                       max)))
              (when (get-text-property pos 'agent-shell-org-math-claimed)
                (let* ((value (buffer-substring-no-properties pos claim-end))
                       (ov
                        (seq-find
                         (lambda (o)
                           (and (eq (overlay-get o 'org-overlay-type)
                                    'org-latex-overlay)
                                (<= (overlay-start o) pos)
                                (> (overlay-end o) pos)))
                         (overlays-at pos))))
                  (cond
                   ;; Empty fragment: org renders nothing, by design.
                   ((agent-shell-org-math--empty-fragment-p value))
                   ;; Conversion in progress: do not duplicate work.
                   ((and ov
                         (or (overlay-get ov 'before-string)
                             (eq (overlay-get ov 'face)
                                 'org-latex-preview-processing-face)
                             conversion-running)))
                   ;; Image or reported error: done.
                   ((and ov
                         (or (overlay-get ov 'display)
                             (overlay-get ov 'help-echo))))
                   ;; No overlay, or an overlay showing nothing:
                   ;; (re)place it.
                   (t
                    (when ov (delete-overlay ov))
                    (push (list (copy-marker pos t)
                                (copy-marker claim-end)
                                value)
                          entries)
                    (setq n (1+ n))))))
              ;; ALWAYS advance past this span.
              (setq pos claim-end)))))
      (when entries
        (setq entries (nreverse entries))
        (unwind-protect
            (agent-shell-org-math--flush entries)
          ;; Detach every entry's markers -- walking the very list
          ;; that was flushed (`nreverse' is destructive).
          (mapc (lambda (e)
                  (set-marker (nth 0 e) nil)
                  (set-marker (nth 1 e) nil))
                entries))))
    n))

(provide 'agent-shell-org-math)

;;; agent-shell-org-math.el ends here
