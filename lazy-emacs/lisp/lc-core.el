;;; lc-core.el --- Configuration paths and small services -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'subr-x)
(defgroup lazy-config nil "PGTK configuration owned by the user and Guix." :group 'environment)
(defvar lc-config-root (file-name-as-directory (expand-file-name user-emacs-directory)))
(defvar lc-real-home (file-name-as-directory (expand-file-name "~")))
(defvar lc-global-environment (copy-sequence process-environment))
(defvar lc-global-exec-path (copy-sequence exec-path))
(defun lc-file (name) (expand-file-name name lc-config-root))
(defun lc-home-file (name) (expand-file-name (string-remove-prefix "~/" name) lc-real-home))
(defun lc-global-env-call (function &rest args)
  "Call FUNCTION with the non-project environment captured at startup."
  (let ((process-environment (copy-sequence lc-global-environment))
        (exec-path (copy-sequence lc-global-exec-path)))
    (apply function args)))
(defun lc-authinfo-set (symbol value)
  (set-default symbol value)
  (when (featurep 'auth-source) (setq auth-sources (list value))))
(defcustom lc-authinfo-file (lc-home-file ".config/emacs/.authinfo.gpg")
  "Existing encrypted credential file. Copy/move it deliberately at final cutover."
  :type 'file :set #'lc-authinfo-set :group 'lazy-config)
(defcustom lc-profile-startup nil "Start the CPU profiler for startup diagnostics."
  :type 'boolean :group 'lazy-config)
(defvar lc-init-finished nil)
(defun lc-org-services-set (symbol enabled)
  (set-default symbol enabled)
  (when lc-init-finished
    (if enabled (lc-start-org-services) (lc-stop-org-services))))
(defcustom lc-org-services-enabled t
  "Start reminders and Org Node/Mem indexing with the daemon.
Disabling this explicitly disables reminders; it is not a performance default."
  :type 'boolean :set #'lc-org-services-set :group 'lazy-config)
(defcustom lc-indent-detection t "Detect project indentation in programming buffers."
  :type 'boolean :group 'lazy-config)
(defun lc-require (feature)
  "Load FEATURE or explain that Guix, not package.el, supplies dependencies."
  (unless (require feature nil t)
    (user-error "Missing %s; install the matching Guix package (see manifest.scm)" feature)))
(defun lc-setup-storage ()
  (setq custom-file (lc-file "gui-settings.el")))
(defun lc-diagnostics ()
  "Show paths, versions and unresolved Guix dependencies without starting services."
  (interactive)
  (with-help-window "*Lazy configuration diagnostics*"
    (princ (format "Emacs %s (%s)\nConfig: %s\nStartup: %s\n"
                   emacs-version system-configuration-features lc-config-root
                   (emacs-init-time)))
    (dolist (lib '(org org-latex-preview org-notify org-node org-mem mu4e
                      agent-shell jinx lsp-mode format-all emms unbreak))
      (princ (format "%s: %s%s\n" lib (or (locate-library (symbol-name lib)) "MISSING")
                     (if (featurep lib) " [loaded]" " [deferred]"))))))
(provide 'lc-core)
