;;; early-init.el --- Early PGTK daemon policy -*- lexical-binding: t; -*-

;(profiler-start 'cpu)
;
;(add-hook 'emacs-startup-hook
;          (lambda ()
;            (profiler-report)
;            (profiler-stop)))

(defun my/time-call (orig-fn feature &rest args)
  (let* ((t0 (float-time))
         (res (apply orig-fn feature args))
         (elapsed (- (float-time) t0)))
    (when (> elapsed 0.03) ;; Only log loads taking longer than 30ms
      (message "[LOAD] %-25s took %.3fs" feature elapsed))
    res))

(advice-add 'require :around #'my/time-call)
            
;; Check the running executable, not the version available from Guix channels.
;; Fail before changing startup state when the validated runtime is not present.
(unless (and (version<= "31.1" emacs-version) (fboundp 'frame-initial-p))
  (error "lazy-emacs requires Emacs 31.1+ with frame-initial-p; running %s. Use guix shell -m %s -- emacs --init-directory=%s"
         emacs-version
         (expand-file-name "manifest.scm" (file-name-directory load-file-name))
         (file-name-directory load-file-name)))

;;; Mitigate TERRIBLE autoload storm on startup

;; Less gc on startup.
;; Maximize GC threshold during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Reset to a sensible value (e.g., 16MB) after startup finishes
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq gc-cons-threshold (* 16 1024 1024)
          gc-cons-percentage 0.1)))

(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
  (lambda ()
    (setq file-name-handler-alist default-file-name-handler-alist)))

;;; End mitigate TERRIBLE autoload storm on startup


(defvar lc-config-root (file-name-directory (or load-file-name buffer-file-name)))
(defvar lc-real-home (file-name-as-directory (expand-file-name "~")))
(defvar lc-global-environment (copy-sequence process-environment))
(defvar lc-global-exec-path (copy-sequence exec-path))
(setq user-emacs-directory lc-config-root
      package-enable-at-startup nil
      user-lisp-auto-scrape nil)
;; Guix puts many package directories ahead of Emacs's own Lisp directories.
;; Searching those for every built-in dependency made gnus-sum take 1.18s;
;; searching built-ins first reduced it to 0.16s in the same environment.
;; Stable-partition the existing path (no duplicates or removed directories).
;; Add our intentional local overrides afterwards so they still take precedence.
(let ((builtin-root (file-name-as-directory
                     (expand-file-name "../lisp" data-directory)))
      builtin-path package-path)
  (dolist (directory load-path)
    (if (and (stringp directory)
             (string-prefix-p builtin-root
                              (file-name-as-directory (expand-file-name directory))))
        (push directory builtin-path)
      (push directory package-path)))
  (setq load-path (append (nreverse builtin-path) (nreverse package-path))))
(add-to-list 'load-path (expand-file-name "lisp" lc-config-root))
(add-to-list 'load-path (expand-file-name "user-lisp" lc-config-root))
;; Matching local Org modules must win over both the built-in and Guix Org.
(add-to-list 'load-path (expand-file-name "vendor/org/lisp" lc-config-root))
;; Compile local Org before configuration/services load it. ARG=0 includes
;; missing .elc files; without FORCE, unchanged files are skipped. Measured
;; Org + agenda loading fell from 1.49s to 0.43s; an unchanged check took 0.10s.
;; The first run compiles everything (~7.55s). Shared macro changes may require
;; a manual forced rebuild because this check tracks timestamps, not dependencies.
(require 'bytecomp)
(byte-recompile-directory (expand-file-name "vendor/org/lisp" lc-config-root) 0)
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
