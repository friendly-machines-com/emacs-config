;;; lc-core.el --- Configuration paths and small services -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'subr-x)
(defgroup lazy-config nil "PGTK configuration owned by the user and Guix." :group 'environment)
(defvar lc-config-root (file-name-directory (directory-file-name user-emacs-directory)))
(defvar lc-real-home (file-name-as-directory (expand-file-name "~")))
(defvar lc-global-environment (copy-sequence process-environment))
(defvar lc-global-exec-path (copy-sequence exec-path))
(defun lc-file (name) (expand-file-name name lc-config-root))
(defun lc-home-file (name) (expand-file-name (string-remove-prefix "~/" name) lc-real-home))
(defun lc-state-file (name) (lc-file (concat "state/" name)))
(defun lc-cache-file (name) (lc-file (concat "cache/" name)))
(defun lc-global-env-call (function &rest args)
  "Call FUNCTION with the non-project environment captured at startup."
  (let ((process-environment (copy-sequence lc-global-environment))
        (exec-path (copy-sequence lc-global-exec-path)))
    (apply function args)))
(defcustom lc-authinfo-file (lc-home-file ".config/emacs/.authinfo.gpg")
  "Existing encrypted credential file. Copy/move it deliberately at final cutover."
  :type 'file :group 'lazy-config)
(defcustom lc-profile-startup nil "Start the CPU profiler for startup diagnostics."
  :type 'boolean :group 'lazy-config)
(defcustom lc-org-services-enabled t
  "Start reminders and Org Node/Mem indexing with the daemon.
Disabling this explicitly disables reminders; it is not a performance default."
  :type 'boolean :group 'lazy-config)
(defcustom lc-indent-detection t "Detect project indentation in programming buffers."
  :type 'boolean :group 'lazy-config)
(defun lc-require (feature)
  "Load FEATURE or explain that Guix, not package.el, supplies dependencies."
  (unless (require feature nil t)
    (user-error "Missing %s; install the matching Guix package (see manifest.scm)" feature)))
(defun lc-setup-storage ()
  "Give this instance private state and cache paths, never the old daemon's DBs."
  (dolist (dir '("state" "cache" "state/eshell" "state/server" "cache/org-persist"))
    (let ((path (lc-file dir)))
      (make-directory path t) (set-file-modes path #o700)))
  (setq custom-file (lc-file "gui-settings.el")
        savehist-file (lc-state-file "history")
        save-place-file (lc-state-file "places")
        recentf-save-file (lc-state-file "recentf")
        bookmark-default-file (lc-state-file "bookmarks")
        abbrev-file-name (lc-state-file "abbrev_defs")
        eshell-directory-name (lc-state-file "eshell")
        projectile-known-projects-file (lc-state-file "projectile-bookmarks.eld")
        projectile-cache-file (lc-cache-file "projectile.cache")
        projectile-project-search-path nil
        project-list-file (lc-state-file "projects")
        forge-database-file (lc-state-file "forge.sqlite")
        org-id-locations-file (lc-state-file "org-id-locations")
        org-persist-directory (lc-cache-file "org-persist")
        org-clock-persist-file (lc-state-file "org-clock-save.el")
        org-node-cache-file (lc-cache-file "org-node-cache.el")
        emms-directory (lc-state-file "emms/")
        transient-history-file (lc-state-file "transient-history.el")
        transient-values-file (lc-state-file "transient-values.el")
        transient-levels-file (lc-state-file "transient-levels.el")
        lsp-session-file (lc-state-file "lsp-session")
        dap-breakpoints-file (lc-state-file "dap-breakpoints")
        tramp-persistency-file-name (lc-state-file "tramp")
        network-security-level 'medium
        nsm-settings-file (lc-state-file "network-security.data")
        nov-save-place-file (lc-state-file "nov-places")
        url-configuration-directory (lc-cache-file "url/")
        elfeed-db-directory (lc-state-file "elfeed/")
        server-name "lazy-emacs"
        server-socket-dir (lc-state-file "server"))
  (when (fboundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache (lc-cache-file "eln/"))))
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
