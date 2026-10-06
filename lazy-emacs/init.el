;;; init.el --- Lazy PGTK configuration bootstrap -*- lexical-binding: t; -*-
;; Customize owns gui-settings.el, not this file. Guix owns installed packages.
(unless (boundp 'lc-config-root)
  ;; Supports explicit batch -Q loads too; normal --init-directory uses early-init.
  (load (expand-file-name "early-init.el" (file-name-directory load-file-name)) nil t))
(require 'lc-core)
;; Why: global-git-commit-mode is enabled by loading git-commit, and that is
;; also what hooks git-commit-setup to find-file-hook. Without this library
;; nothing loads it -- the docs say it is deliberately NOT autoloaded, and
;; Magit only pulls it in for its own commit buffers. So `git commit` over
;; emacsclient opened .git/COMMIT_EDITMSG in fundamental-mode with no
;; git-commit-mode, and C-c C-c (and wakib's C-d C-c) were simply unbound.
(require 'git-commit)
;; Why: lc-projects.el registers git-rebase-* actions for git-rebase-mode. Like
;; git-commit, git-rebase.el ships no autoloads and nothing else loads it, so
;; every one of those actions was unbound.
(require 'git-rebase)
(require 'use-package)
(setq use-package-always-ensure nil use-package-always-defer t)
(dolist (dir '("vendor/wakib-keys" "vendor/ssass-mode" "vendor/elfeed-tube"))
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
(load (lc-file "private.el") t t)
;; The user explicitly requested these services at startup, not on first use.
(lc-start-ui)
(lc-start-completion)
(lc-start-editing)
(when lc-org-services-enabled (lc-start-org-services))
;; Startup sampling is owned by early-init; never restart/reset it here.
(setq gc-cons-threshold (if (boundp 'lc--normal-gc-threshold)
                            lc--normal-gc-threshold (* 8 1024 1024)))
(setq lc-init-finished t)
(provide 'lc-init)
