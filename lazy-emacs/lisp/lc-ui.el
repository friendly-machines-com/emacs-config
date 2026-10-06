;;; lc-ui.el --- One tab row, composed contextual actions -*- lexical-binding: t; -*-
(require 'lc-core)
(require 'use-package)
(defgroup lc-ui nil "GUI chrome and discoverable actions." :group 'lazy-config)
(defvar lc-actions (make-hash-table :test #'eq))
(defvar lc-global-toolbar (make-sparse-keymap))
(defvar-local lc--native-toolbar nil)
(defvar-local lc--composed-toolbar nil)
(defun lc-toolbar-option-set (symbol value)
  (set-default symbol value)
  (when (fboundp 'lc-refresh-toolbars) (lc-refresh-toolbars)))
(defcustom lc-global-actions '(ripgrep embark magit store-link node-find node-grep agenda)
  "Persistent actions available alongside each buffer's native/context actions."
  :type '(repeat symbol) :set #'lc-toolbar-option-set :group 'lc-ui)
(defcustom lc-mode-actions
  '((mu4e-view-mode reply-all reply forward move flag trash execute previous next)
    (mu4e-headers-mode compose reply-all reply forward move execute trash refresh)
    (mu4e-compose-mode attach spell sign encrypt send discard-draft)
    (message-mode attach spell sign encrypt send discard-draft)
    (gnus-article-mode news-reply-all news-reply news-forward verify)
    (gnus-summary-mode news-post news-reply-all news-reply news-forward)
    (magit-status-mode git-fetch git-pull git-push git-commit)
    (git-rebase-mode pick drop reword edit squash fixup kill-commit noop exec up down cancel finish)
    (emms-browser-mode add-play)
    (emms-playlist-mode play rewind ffwd pause music-prev music-next stop)
    (mediainfo-mode media-play)
    (agent-shell-mode agent-stop agent-kill agent-pending agent-prev agent-next agent-switch agent-new))
  "Per-mode action IDs, most specific mode first. Edit with Customize."
  :type '(alist :key-type symbol :value-type (repeat symbol))
  :set #'lc-toolbar-option-set :group 'lc-ui)
(defun lc-action (id label command icon help &rest properties)
  "Register a lightweight action without requiring COMMAND's package."
  (puthash id (append (list :label label :command command :icon icon :help help) properties)
           lc-actions))
(defun lc-register-actions (specifications)
  "Register documented action records (ID LABEL COMMAND ICON).
The label also supplies the default tooltip; use lc-action directly for richer
properties such as a buffer-state :enable expression."
  (dolist (specification specifications)
    (pcase specification
      (`(,id ,label ,command ,icon) (lc-action id label command icon label))
      (_ (error "Invalid action record (expected ID LABEL COMMAND ICON): %S" specification)))))
(defun lc-action-map (ids)
  (let ((map (make-sparse-keymap)))
    (dolist (id (reverse ids))
      (when-let* ((action (gethash id lc-actions)))
        (let ((command (plist-get action :command)))
          (tool-bar-local-item (or (plist-get action :icon) "index") command id map
                               :label (plist-get action :label) :help (plist-get action :help)
                               :enable (or (plist-get action :enable) t)))))
    map))
(defun lc-buffer-toolbar ()
  (when (and (featurep 'tool-bar) (featurep 'window-tool-bar))
    (unless (eq tool-bar-map lc--composed-toolbar)
      (setq lc--native-toolbar tool-bar-map))
    (let ((ids (cdr (seq-find (lambda (entry) (derived-mode-p (car entry))) lc-mode-actions))))
      ;; window-tool-bar-string consumes a flat menu map. Canonicalize using
      ;; Emacs's public API when context/options change, not during redisplay.
      (setq lc--composed-toolbar
            (keymap-canonicalize
             (make-composed-keymap (delq nil (list (lc-action-map ids)
                                                   lc--native-toolbar lc-global-toolbar)))))
      (setq-local tool-bar-map lc--composed-toolbar
                  window-tool-bar-string--cache nil))))
(defun lc-refresh-toolbars ()
  (when (featurep 'tool-bar)
    (setq lc-global-toolbar (lc-action-map lc-global-actions))
    (dolist (buffer (buffer-list)) (with-current-buffer buffer (lc-buffer-toolbar)))
    (force-mode-line-update t)))
(defun lc-invalidate-toolbar (&rest _)
  (when (boundp 'window-tool-bar-string--cache)
    (setq window-tool-bar-string--cache nil))
  (force-mode-line-update))
(defun lc-tab-name-format (tab tabs)
  "Stock tab semantics plus actions in the selected tab, no extra row."
  (let* ((buffer-p (bufferp tab))
         (selected-p (if buffer-p (eq tab (window-buffer)) (cdr (assq 'selected tab))))
         (buffer (if buffer-p tab (cdr (assq 'buffer tab))))
         (name (if buffer-p (funcall tab-line-tab-name-function tab tabs) (cdr (assq 'name tab))))
         (face (if selected-p (if (mode-line-window-selected-p) 'tab-line-tab-current 'tab-line-tab)
                 'tab-line-tab-inactive)))
    (dolist (fn tab-line-tab-face-functions) (setq face (funcall fn tab tabs face buffer-p selected-p)))
    (apply #'propertize
           (concat (propertize (string-replace "%" "%%" name)
                               'keymap tab-line-tab-map 'follow-link 'ignore
                               'help-echo (and (buffer-live-p buffer) (buffer-file-name buffer)))
                   (if selected-p (window-tool-bar-string) "")
                   (or (and (or buffer-p (assq 'buffer tab) (assq 'close tab))
                            tab-line-close-button-show
                            (not (eq tab-line-close-button-show (if selected-p 'non-selected 'selected)))
                            tab-line-close-button) ""))
           `(tab ,tab ,@(when selected-p '(selected t)) face ,face mouse-face tab-line-highlight))))
(defun lc-project-color ()
  (require 'project) (require 'color)
  (let* ((project (project-current nil))
         (hash (sxhash (if project (project-root project) default-directory)))
         (rgb (color-hsl-to-rgb (/ (mod hash 1000) 1000.0)
                               (+ .3 (* .1 (mod (/ hash 1000) 3)))
                               (+ .4 (* .05 (mod (/ hash 1000000) 4))))))
    (apply #'color-rgb-to-hex (append rgb '(2)))))
(defvar-local lc--project-face-cookies nil)
(defun lc-color-buffer ()
  (require 'face-remap)
  (mapc #'face-remap-remove-relative lc--project-face-cookies)
  (setq lc--project-face-cookies nil)
  (let ((color (lc-project-color)))
    (dolist (face '(mode-line-active line-number-current-line))
      (push (face-remap-add-relative face :background color :foreground "white")
            lc--project-face-cookies))))
(use-package spacious-padding :ensure nil :commands spacious-padding-mode)
(use-package pulsar :ensure nil :hook (minibuffer-setup . pulsar-pulse-line))
(use-package ultra-scroll :ensure nil :commands ultra-scroll-mode)
(use-package popper :ensure nil
  :bind (("C-`" . popper-toggle) ("M-`" . popper-cycle) ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers '("\\*Messages\\*" "Output\\*$" "\\*Async Shell Command\\*"
                                   help-mode compilation-mode "\\*eshell.*\\*" eshell-mode
                                   "\\*shell.*\\*" shell-mode term-mode vterm-mode)))
(use-package solarized-theme :ensure nil :defer t)
(autoload 'modern-fringes-mode "modern-fringes" nil t)
(autoload 'unbreak "unbreak" nil t)
(defun lc-graphic-ui (frame)
  "Apply GUI-only modes to an actual PGTK frame, never the daemon bootstrap."
  (when (and (frame-live-p frame) (display-graphic-p frame)
             (not (frame-initial-p frame)) (not (frame-parent frame)))
    (with-selected-frame frame
      (when (require 'spacious-padding nil t)
        ;; Why: a daemon has no window system, so `default''s foreground and the
        ;; frame's background-color/foreground-color are all "unspecified-fg".
        ;; spacious-padding 0.9.0, `spacious-padding--face-attribute', tries to
        ;; paper over exactly this (its own comment names "running Emacs as a
        ;; daemon, connecting via emacsclient"), but its fallbacks are the frame
        ;; colors and then `background-mode' -- and `background-mode' is nil
        ;; until a real frame exists. Every clause then fails and it returns nil.
        ;;
        ;; That nil reaches `spacious-padding-set-face-box-padding', which builds
        ;; (:underline (:color (or ... (spacious-padding--face-foreground 'default))
        ;;                    :position t)). xfaces.c rejects :color unspecified,
        ;; so `make-frame' aborts, `server.el' swallows the error and answers
        ;; -window-system-unsupported, and `emacsclient -c' exits 0 with no
        ;; window. Giving `default' a real color makes the FIRST clause of
        ;; --face-attribute succeed, so no padding code path can emit nil.
        ;;
        ;; Do NOT "fix" this by setting spacious-padding-subtle-frame-lines to
        ;; nil: that only disables the feature. The bug is an unresolvable face.
        ;; Do NOT set the foreground from the face's own current value either --
        ;; on a daemon that value is the bogus "unspecified-fg" string.
        (dolist (face '(default header-line-inactive mode-line-active mode-line-inactive))
          (let ((current (face-attribute face :foreground frame)))
            (unless (and (stringp current)
                         (not (member current '("unspecified-fg" "unspecified-bg"))))
              ;; Resolve against `default', which themes do give a real color,
              ;; rather than inheriting this face's own unset value.
              (set-face-attribute face frame :foreground (face-foreground 'default)))))
        (spacious-padding-mode 1))
      (when (require 'ultra-scroll nil t) (ultra-scroll-mode 1))
      (when (require 'bar-cursor nil t) (bar-cursor-mode 1)))))
(defun lc-start-ui ()
  (require 'tab-line) (require 'tool-bar) (require 'window-tool-bar)
  (add-to-list 'image-load-path (lc-file "assets/icons"))
  ;; Emacs 31's window toolbar draws its own fixed-width separators. With the
  ;; frame toolbar disabled, the legacy tool-bar-setup override is unnecessary.
  (tool-bar-mode -1)
  (setq-default tab-line-tab-name-format-function #'lc-tab-name-format)
  (global-tab-line-mode 1)
  (keymap-global-set "C-<iso-lefttab>" #'tab-line-switch-to-prev-tab)
  (keymap-global-set "C-<tab>" #'tab-line-switch-to-next-tab)
  ;; Native 31 tab images already scale correctly; keep local paths for custom artwork.
  (lc-refresh-toolbars)
  (add-hook 'after-change-major-mode-hook #'lc-buffer-toolbar 95)
  (add-hook 'find-file-hook #'lc-color-buffer)
  (add-hook 'dired-mode-hook #'lc-color-buffer)
  (add-hook 'temp-buffer-setup-hook #'lc-color-buffer)
  (update-glyphless-char-display 'glyphless-char-display-control
                                '((format-control . empty-box) (no-font . empty-box)))
  (load-theme 'solarized t)
  (add-hook 'after-make-frame-functions #'lc-graphic-ui)
  (when (require 'popper nil t) (popper-mode 1) (popper-echo-mode 1))
  (unbreak)
  (dolist (id '(rgrep ede semantic directory-search simple-calculator games))
    (define-key global-map (vector 'menu-bar 'tools id) nil))
  ;; Tools menu records are (EVENT LABEL COMMAND); EVENT is a stable keymap ID.
  (dolist (entry '((trashed "View trash" trashed) (osm "View street map" osm)
                   (emms "Browse music" emms-smart-browse) (wttrin "Check weather" wttrin)
                   (maxima "Computer algebra (Maxima)" maxima) (serial "Serial terminal" serial-term)
                   (agent "Coding agent" agent-shell) (django "Django project manager" python-django-open-project)
                   (treemacs "Project tree" treemacs) (feeds "Read feeds" elfeed)
                   (mail-index "Initialize isolated mail index" lc-mail-initialize-index)
                   (diagnostics "Configuration diagnostics" lc-diagnostics)
                   (menus "Refresh missing command menus" unbreak)))
    (pcase-let ((`(,event ,label ,command) entry))
      (define-key global-map (vector 'menu-bar 'tools event) (cons label command)))))
(provide 'lc-ui)
