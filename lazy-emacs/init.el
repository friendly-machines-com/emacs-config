;;; init.el --- Lazy PGTK configuration bootstrap -*- lexical-binding: t; -*-
;; Customize owns gui-settings.el, not this file. Guix owns installed packages.
(unless (boundp 'lc-config-root)
  ;; Supports explicit batch -Q loads too; normal --init-directory uses early-init.
  (load (expand-file-name "early-init.el" (file-name-directory load-file-name)) nil t))
(require 'lc-core)
;; Why: git-commit ships no autoload for its mode, and Magit only loads it for
;; its own commit buffers.  `git commit` over emacsclient used to open
;; .git/COMMIT_EDITMSG in fundamental-mode with no git-commit-mode, so C-c C-c
;; (and wakib's C-d C-c) were unbound.  Loading the library eagerly also pulls
;; in Magit, Forge and their subprocess probes (~1s per start).  Install the
;; same find-file check as an autoload; it loads git-commit only when a buffer
;; is actually visited.
(autoload 'git-commit-setup-check-buffer "git-commit"
  "Set up a commit-message buffer when appropriate." nil)
(add-hook 'find-file-hook #'git-commit-setup-check-buffer)
;; git-rebase-mode is autoloaded by its package and lc-projects registers the
;; `git-rebase-todo' mode association, so an eager (require 'git-rebase) is no
;; longer needed; it used to pull Magit in before any rebase buffer existed.
(require 'use-package)
(setq use-package-always-ensure nil use-package-always-defer t)
(dolist (dir '("vendor/ssass-mode" "vendor/elfeed-tube"))
  (add-to-list 'load-path (lc-file dir)))
(lc-setup-storage)
(require 'lc-frames)
(lc-install-frame-policy)
;; Declaration files register entry points/integrations, not their large packages.
(dolist (module '(lc-completion lc-ui lc-editing lc-projects lc-programming
                   lc-org lc-documents lc-mail lc-media lc-agents))
  (require module))
;; gui-settings.el is the only settings file, and GUI set/save/reset owns it.
(load custom-file nil t)
(lc-start-ui)
(lc-start-completion)
(lc-start-editing)
;; The user explicitly requested these services at startup, not on first use.
;; Keep them eager: deferring them to an idle timer only races the user and
;; hides the cost.  The synchronous part is small (~0.07s here); if the real
;; corpus makes it significant, make the initial index build asynchronous
;; (el-job) rather than moving the call.
(when lc-org-services-enabled (lc-start-org-services))
;; Startup sampling is owned by early-init; never restart/reset it here.
(setq gc-cons-threshold (if (boundp 'lc--normal-gc-threshold)
                            lc--normal-gc-threshold (* 8 1024 1024)))
(setq lc-init-finished t)
(provide 'lc-init)
