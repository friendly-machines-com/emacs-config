;;; early-init.el --- Early PGTK daemon policy -*- lexical-binding: t; -*-

;(profiler-start 'cpu)
;
;(add-hook 'emacs-startup-hook
;          (lambda ()
;            (profiler-report)
;            (profiler-stop)))

;; Container execution policy. This must be in force before any service, buffer
;; or user command can spawn a process, so it lives here rather than in a module
;; loaded later. A malformed setq below is reported as a warning, not a failure
;; (verified: `emacs --init-directory` continues after one), so nothing here may
;; rely on evaluation order alone to stop an uncontained run.
(defvar lc/guix-shell-extra-args
  (list "-C" "-N" "-W"
        "--expose=/usr/bin/env"
        (concat "--expose=" (expand-file-name "~/.config/loki"))
        (concat "--share=" (expand-file-name "~/.config/loki/credentials"))
        (concat "--share=" (expand-file-name "~/.local/state/loki"))
        (concat "--expose=" (expand-file-name "~/src/loki"))
        "--expose=/var/log/guix"
        "--share=/var/guix" ; sigh
        "--preserve=_KEY$"
        "--preserve=_TOKEN$"
        "--preserve=_PAT$"
        "emacs-minimal"
        "python"
        "ripgrep")
  "Extra args passed to `guix shell` containerization when wrapping commands.")

(defun lc-workspace-root ()
  "Local directory containing the nearest manifest, independently of its target."
  (when (file-remote-p default-directory)
    (user-error "Guix execution requires a local workspace; refusing host/remote fallback"))
  (let ((root (locate-dominating-file default-directory "manifest.scm")))
    (unless root
      (user-error "No manifest.scm for %s; refusing uncontained execution" default-directory))
    (file-name-as-directory (file-truename root))))

(defun lc--manifest ()
  (let ((file (file-truename (expand-file-name "manifest.scm" (lc-workspace-root)))))
    (unless (file-regular-p file) (user-error "Not a regular manifest: %s" file))
    file))

(defun lc-guix-command (kind)
  "Produce an argument list for trusted Guix execution of KIND (agent/compile)."
  (unless (executable-find "guix") (user-error "Guix unavailable; refusing host fallback"))
  (let* ((manifest (lc--manifest))
         (agent (eq kind 'agent))
         (workspace (lc-workspace-root))
         (working-directory (if agent (file-truename default-directory) workspace))) ; FIXME
    (append (list "guix" "shell")
            lc/guix-shell-extra-args
            (list "--no-cwd"
                  (concat "--share=" workspace)
                  (concat "--cwd=" working-directory)
                  "-m" manifest "--"))))

(defun lc-wrap-compilation (function command &rest args)
  "All compilation-start commands are contained, or fail."
  (let* ((runner (lc-guix-command 'compile))
         (default-directory (lc-workspace-root))
         (wrapped (mapconcat #'shell-quote-argument
                             (append runner (list "/bin/sh" "-c" command)) " ")))
    (apply function wrapped args)))
(advice-add 'compilation-start :around #'lc-wrap-compilation)

(defun lc-agent-command-prefix (buffer)
  "agent-shell-command-prefix: the contained agent argv for BUFFER."
  (unless (buffer-live-p buffer)
    (user-error "No live agent execution buffer"))
  (with-current-buffer buffer (lc-guix-command 'agent)))

;;; To prevent the agent running inside the container to access your local
;;; file-system altogether, disable the "read/write text file" client capabilities.
(with-eval-after-load 'agent-shell-anthropic
  (setq agent-shell-text-file-capabilities nil))
(with-eval-after-load 'agent-shell-loki
  (setq agent-shell-text-file-capabilities nil))

;; If the variable is missing when agent-shell loads, that is fatal: it means
;; agents would run on the host.
(with-eval-after-load 'agent-shell
  (unless (boundp 'agent-shell-command-prefix)
    (kill-emacs "agent-shell lacks agent-shell-command-prefix; refusing to run agents uncontained"))
  (setq agent-shell-text-file-capabilities nil
        agent-shell-command-prefix #'lc-agent-command-prefix))

;(defun my/time-call (orig-fn feature &rest args)
;  (let* ((t0 (float-time))
;         (res (apply orig-fn feature args))
;         (elapsed (- (float-time) t0)))
;    (when (> elapsed 0.03) ;; Only log loads taking longer than 30ms
;      (message "[LOAD] %-25s took %.3fs" feature elapsed))
;    res))
;
;(advice-add 'require :around #'my/time-call)
            
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
;; Remember Guix's Transient (including its frame-close patch) before the
;; built-in-first sorting below.  Pinning its directory lets Magit/Forge load
;; it on demand instead of requiring it during every startup.
(defvar lc-transient-directory
  (let ((library (locate-library "transient")))
    (and library (file-name-directory library))))
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
(when lc-transient-directory
  (add-to-list 'load-path lc-transient-directory))
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
(defvar lc--normal-gc-threshold (* 16 1024 1024)
  "Runtime GC threshold, not the temporarily raised startup value.")
(setq gc-cons-threshold (* 64 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold lc--normal-gc-threshold)) 90)
(setq default-frame-alist
      (append '((tool-bar-lines . 0) (foreground-color . "#505050"))
              default-frame-alist))
(provide 'lc-early-init)
