
;;; Mitigate TERRIBLE autoload storm on startup

;; Less gc on startup.
;; Maximize GC threshold during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
  (lambda ()
    (setq file-name-handler-alist default-file-name-handler-alist)))

;;; End mitigate TERRIBLE autoload storm on startup

    
;; Override org.
(add-to-list 'load-path (expand-file-name "org-mode/lisp" user-emacs-directory))
;(add-to-list 'load-path "/home/dannym/.config/emacs/org-mode")

(with-eval-after-load 'agent-shell-anthropic
  ;; Prefixes the command that starts the agent, or a shell command that should be run so it is executed inside the container.
  ;; It's extremely dangerous if this isn't set (because of a config error, say), so keep this here and at the beginning.
  ;; see guix-workspace.el for where this is set.
;  (setq agent-shell-container-command-runner
;        (list "guix" "shell"
;             "-C" "-N" "-W"
;              "-m" "manifest.scm"
;              "--expose=/usr/bin/env"
;              ;"--preserve=ANTHROPIC_API_KEY" ; optional
;              ;"--perserve=ACP_PERMISSION_MODE" ; optional bypassPermissions|acceptEdits|default
;              (concat "--share=" (expand-file-name "~/.claude"))
;              (concat "--share=" (expand-file-name "~/.claude.json"))
;              "--"))
  ;; To prevent the agent running inside the container to access your local file-system altogether and to have it read/modify files inside the container directly, in addition to setting the resolver function, disable the “read/write text file” client capabilities.
  (setq agent-shell-text-file-capabilities nil)

; "please migrate away"
;  (setq agent-shell-anthropic-claude-command
;        (list "claude-agent-acp"))

        )

(with-eval-after-load 'agent-shell-loki
  ;; Prefixes the command that starts the agent, or a shell command that should be run so it is executed inside the container.
  ;; It's extremely dangerous if this isn't set (because of a config error, say), so keep this here and at the beginning.
  ;; see guix-workspace.el for where this is set.
;  (setq agent-shell-container-command-runner
;        (list "loki-contain" ; "guix" "shell"
;             "-C" "-N" "-W"
;              "-m" "manifest.scm"
;              "--expose=/usr/bin/env"
;              ;"--preserve=ANTHROPIC_API_KEY" ; optional
;              ;"--perserve=ACP_PERMISSION_MODE" ; optional bypassPermissions|acceptEdits|default
;              (concat "--share=" (expand-file-name "~/.claude"))
;              (concat "--share=" (expand-file-name "~/.claude.json"))
;              "--"))
  ;; To prevent the agent running inside the container to access your local file-system altogether and to have it read/modify files inside the container directly, in addition to setting the resolver function, disable the “read/write text file” client capabilities.
  (setq agent-shell-text-file-capabilities nil)

  (setq agent-shell-loki-acp-command
        (list "/home/dannym/src/loki/loki-acp")))

(setq debug-on-quit t)
;(profiler-start 'cpu)

(setq local-icon-directory (expand-file-name "~/.emacs.d/icons"))

(add-to-list 'image-load-path local-icon-directory)

;; Newer emacs already has that.
(require 'tab-line) ; keymap
(setq tab-line-close-button
      (propertize " x"
                  'display `(image :type xpm
                                   :file (string-append local-icon-directory "/tabs/close.xpm")
                                   :face shadow
                                   :height (1.4 . em)
                                   :margin (2 . 0)
                                   :ascent center)
                  'keymap tab-line-tab-close-map
                  'mouse-face 'tab-line-close-highlight
                  'help-echo "Click to close tab"))

(setq tab-line-new-button
  (propertize " + "
              'display '(image :type xpm
                               :file (string-append local-icon-directory "/tabs/new.xpm")
                               :face shadow
                               :height (1.4 . em)
                               :margin (2 . 0)
                               :ascent center)
              'keymap tab-line-add-map
              'mouse-face 'tab-line-highlight
              'help-echo "Click to add tab"))

(setq tab-line-left-button
  (propertize " <"
              'display '(image :type xpm
                               :file (string-append local-icon-directory "/tabs/left-arrow.xpm")
                               :face shadow
                               :height (1.4 . em)
                               :margin (2 . 0)
                               :ascent center)
              'keymap tab-line-left-map
              'mouse-face 'tab-line-highlight
              'help-echo "Click to scroll left"))

(setq tab-line-right-button
  (propertize "> "
              'display '(image :type xpm
                               :file (string-append local-icon-directory "/tabs/right-arrow.xpm")
                               :face shadow
                               :height (1.4 . em)
                               :margin (2 . 0)
                               :ascent center)
              'keymap tab-line-right-map
              'mouse-face 'tab-line-highlight
              'help-echo "Click to scroll right"))

(force-mode-line-update)  ; Force an update to see the change

;; TODO: Report bug with trashed upstream that this is missing.
(define-key global-map
  [menu-bar tools trashed]
  '("View trash" . trashed))

;; TODO: Report bug with gptel upstream that this is missing.
(define-key global-map
  [menu-bar tools gptel]
  '("Talk to Large Language Model" . gptel))

;; TODO: Report bug with osm upstream that this is missing.
(define-key global-map
  [menu-bar tools osm]
  '("View street map" . osm))

;; emms-smart-browse shows that anyway.
;(define-key global-map
;  [menu-bar tools emms]
;  '("Play music..." . emms))

;; TODO: Report bug with emms upstream that this is missing.
(define-key global-map
  [menu-bar tools emms-smart-browse]
  '("Browse music" . emms-smart-browse))

;; TODO: Report bug with wttrin upstream that this is missing.
(define-key global-map
  [menu-bar tools wttrin]
  '("Check weather" . wttrin))

;; TODO: Report bug with emacs upstream that this is missing.
(define-key global-map
  [menu-bar tools maxima]
  '("Do computer algebra via Maxima" . maxima))

;; TODO: Report bug with emacs upstream that this is missing.
(define-key global-map
  [menu-bar tools serial-term]
  '("Start serial terminal" . serial-term))

;; TODO: Report bug with elfeed upstream that this is missing.
;(define-key global-map
;  [menu-bar tools elfeed]
;  '("Read news" . elfeed))

;; TODO: where is enwc

;; TODO: Report bug with emacs upstream that org major mode (org.el) doesn't have menu items for org-insert-last-stored-link.

;; orgmode:
;; Install ‘cdlatex.el’ and ‘texmathp.el’ (the latter comes also with AUCTeX) from NonGNU ELPA with the Emacs packaging system or alternatively from https://staff.fnwi.uva.nl/c.dominik/Tools/cdlatex/.
;; Do not use CDLaTeX mode itself under Org mode, but use the special version Org CDLaTeX minor mode that comes as part of Org.
;(add-hook 'org-mode-hook #'turn-on-org-cdlatex)

;; Otherwise hidpi displays with small toolbar icons would have one HUGE icon fucking up the layout.
(defun tool-bar-setup ()
  (setq tool-bar-separator-image-expression
    (tool-bar--image-expression "separator"))
  nil)

;(setq package-enable-at-startup nil)
;(setq use-package-defaults '(:ensure t :defer t))

;;; Prevent emacs daemon hang if it tries to ask a question while no frame is open.

;(defun my-input-capable-frame-p ()
;      (when (and (frame-live-p frame)
;                 ;; Exclude the daemon's internal terminal frame.
;                 (not (and (daemonp)
;                           ;; Ignore internal log frame.
;                           (eq frame terminal-frame)))
;                 ;; t means visible; `icon' means recoverably iconified.
;                 (frame-visible-p frame)
;                 ;; Exclude child/tooltip frames.
;                 (not (frame-parameter frame 'parent-frame))
;                 (not (frame-parameter frame 'tooltip)))
;        (throw 'found t)))

;(defun my-server-inhibit-headless-interaction (function &rest arguments)
;  (let ((inhibit-interaction
;         (or inhibit-interaction
;             (not (my-input-capable-frame-p)))))
;    (apply function arguments)))

;(with-eval-after-load 'server
;  (advice-add 'server-execute
;              :around #'my-server-inhibit-headless-interaction))

(defun my/user-frame-available-p ()
    "Return non-nil when a real input frame exists."
    (catch 'available
      (dolist (frame (frame-list))
        (when (and (frame-live-p frame)
                   ;; The daemon bootstrap frame is not an input frame.
                   (not (and (daemonp)
                             (eq frame terminal-frame)))
                   ;; Child and tooltip frames cannot replace a user frame.
                   (not (frame-parameter frame 'parent-frame))
                   (not (frame-parameter frame 'tooltip)))
          (throw 'available t)))))

(defun my/backtrace-string ()
    (with-temp-buffer
      (let ((standard-output (current-buffer))
            (print-level 12)
            (print-length 100))
        (mapbacktrace
         (lambda (&rest frame)
           (prin1 frame)
           (terpri))))
      (buffer-string)))

(defun my/inhibit-interaction-when-headless (function &rest arguments)
    (if (my/user-frame-available-p)
        (apply function arguments)
      (let ((trace
             (concat
              "\n\nHEADLESS INTERACTION ATTEMPT\n"
              "Function: " (prin1-to-string function) "\n"
              (my/backtrace-string))))

        ;; Preserve it for inspection from a later frame.
        (with-current-buffer
            (get-buffer-create "*headless-interaction-backtrace*")
          (goto-char (point-max))
          (insert trace))

        ;; Also write it to the daemon's stderr/journal.
        (princ trace 'external-debugging-output))

      ;; The original reader sees this binding and signals
      ;; `inhibited-interaction` before waiting.
      (let ((inhibit-interaction t))
        (apply function arguments))))

; not instrumented:
;(defun my/inhibit-interaction-when-headless (function &rest arguments)
;    "Call FUNCTION, inhibiting user interaction if no real frame exists."
;    (let ((inhibit-interaction
;           (or inhibit-interaction
;               (not (my/user-frame-available-p)))))
;      (apply function arguments)))

(defun my/abort-minibuffer-after-last-frame-deleted (_deleted-frame)
    "Abort an existing minibuffer if its last real frame disappeared."
    (when (and (active-minibuffer-window)
               (not (my/user-frame-available-p)))
      (abort-recursive-edit)))

(with-eval-after-load 'server
  ;; Cover minibuffer prompts and direct character/event questions.
  ;; Note: read-key can still hang everything.
  (dolist (function '(read-from-minibuffer read-char read-char-exclusive
  ; bad idea since it also does dbus etc: read-event
  ))
    (advice-add function
                :around #'my/inhibit-interaction-when-headless))

  (add-hook 'after-delete-frame-functions
            #'my/abort-minibuffer-after-last-frame-deleted))

;;; End: Prevent emacs daemon hang if it tries to ask a question while no frame is open.

;(require 'org)
;(require 'org-latex-preview)
