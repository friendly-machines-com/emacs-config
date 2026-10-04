;;; init.el --- Lazy PGTK configuration bootstrap -*- lexical-binding: t; -*-
;; Customize owns gui-settings.el, not this file. Guix owns installed packages.
(unless (boundp 'lc-config-root)
  ;; Supports explicit batch -Q loads too; normal --init-directory uses early-init.
  (load (expand-file-name "early-init.el" (file-name-directory load-file-name)) nil t))
(require 'lc-core)
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
;; Seed exactly once. GUI set/save/reset owns all future changes.
(unless (file-exists-p custom-file)
  (copy-file (lc-file "defaults.el") custom-file)
  (set-file-modes custom-file #o600))
(load custom-file nil t)
(lc-register-deferred-custom)
(load (lc-file "private.el") t t)
;; The user explicitly requested these services at startup, not on first use.
(lc-start-ui)
(lc-start-completion)
(lc-start-editing)
(when lc-org-services-enabled (lc-start-org-services))
(when lc-profile-startup (require 'profiler) (profiler-start 'cpu))
(setq gc-cons-threshold (if (boundp 'lc--normal-gc-threshold)
                            lc--normal-gc-threshold (* 8 1024 1024)))
(setq lc-init-finished t)
(provide 'lc-init)
