;;; early-init.el --- Early PGTK daemon policy -*- lexical-binding: t; -*-

(defvar lc-config-root (file-name-directory (or load-file-name buffer-file-name)))
(defvar lc-real-home (file-name-as-directory (expand-file-name "~")))
(defvar lc-global-environment (copy-sequence process-environment))
(defvar lc-global-exec-path (copy-sequence exec-path))
(setq user-emacs-directory lc-config-root
      package-enable-at-startup nil
      user-lisp-auto-scrape nil)
(add-to-list 'load-path (expand-file-name "lisp" lc-config-root))
(add-to-list 'load-path (expand-file-name "user-lisp" lc-config-root))
;; Matching local Org modules must win over both the built-in and Guix Org.
(add-to-list 'load-path (expand-file-name "vendor/org/lisp" lc-config-root))
(setq agent-shell-text-file-capabilities nil)
(require 'lc-core)
(require 'lc-security)
(lc-install-security)
;; Modest, temporary tuning. Always restored, including after an init error.
(defvar lc--normal-gc-threshold gc-cons-threshold)
(setq gc-cons-threshold (* 64 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold lc--normal-gc-threshold)) 90)
(setq default-frame-alist
      (append '((tool-bar-lines . 0) (foreground-color . "#505050"))
              default-frame-alist))
(provide 'lc-early-init)
