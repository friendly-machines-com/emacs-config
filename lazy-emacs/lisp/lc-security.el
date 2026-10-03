;;; lc-security.el --- Fail-closed processes and usable input frames -*- lexical-binding: t; -*-
(require 'lc-core)
(defvar agent-shell-text-file-capabilities)
(defvar agent-shell-command-prefix)
(defvar lc--input-reading nil)
(defgroup lc-security nil "Execution and daemon input boundaries." :group 'lazy-config)
(defcustom lc-headless-traces nil "Record backtraces for rejected headless prompts."
  :type 'boolean :group 'lc-security)
(defcustom lc-agent-share-host-emacs nil
  "Allow newly launched agent containers to control host Emacs.
This permits arbitrary HOST Lisp evaluation, not just project-file access."
  :type 'boolean :group 'lc-security)
(defcustom lc-agent-share-tmp nil
  "Share host /tmp writable with newly launched agents. Default is no access."
  :type 'boolean :group 'lc-security)
(defcustom lc-agent-extra-shares nil
  "Explicit writable host directories for new agents. No automatic home/config shares."
  :type '(repeat directory) :group 'lc-security)
(defcustom lc-agent-extra-exposes nil
  "Explicit read-only host paths for new agents."
  :type '(repeat file) :group 'lc-security)
(defcustom lc-agent-program-directories (list (lc-home-file "src/loki"))
  "Read-only source/runtime directories necessary to execute the Loki adapter.
No credentials/config directory is included. Prefer a Guix-packaged adapter later."
  :type '(repeat directory) :group 'lc-security)
(defcustom lc-host-emacs-socket-directory
  (expand-file-name "emacs" (or (getenv "XDG_RUNTIME_DIR")
                               (format "/run/user/%s" (user-uid))))
  "Host daemon socket directory, shared only with explicit opt-in."
  :type 'directory :group 'lc-security)
(defcustom lc-guix-agent-packages '("python" "ripgrep")
  "Additional Guix packages for agents. Add another ACP adapter if using it."
  :type '(repeat string) :group 'lc-security)
(defcustom lc-guix-compilation-packages nil
  "Additional packages beyond a workspace manifest for compilation containers."
  :type '(repeat string) :group 'lc-security)
(defcustom lc-guix-authorized-manifests nil
  "Manifest path and SHA256 approvals. Editing a manifest invalidates approval.
Unlike broad directory trust, this approval applies to exact file contents."
  :type '(alist :key-type file :value-type string) :group 'lc-security)
(defun lc-input-frame-p (frame)
  "Whether FRAME can provide user input (initial/dummy frames cannot)."
  (and (frame-live-p frame)
       (not (frame-initial-p frame))
       (eq (framep frame) 'pgtk)
       (not (frame-parent frame))
       (not (frame-parameter frame 'tooltip))
       (not (frame-parameter frame 'server-dummy-buffer))
       (memq (frame-visible-p frame) '(t icon))))
(defun lc-input-frames () (cl-remove-if-not #'lc-input-frame-p (frame-list)))
(defun lc-guard-input (function &rest args)
  "Never wait for human input on the daemon's dummy frame.
Batch mode uses Emacs's existing noninteractive/inhibit-interaction semantics."
  (if (or noninteractive (lc-input-frames))
      (let ((lc--input-reading t)) (apply function args))
    (when lc-headless-traces
      (with-current-buffer (get-buffer-create "*headless-interaction-backtrace*")
        (goto-char (point-max))
        (insert (format "\nRejected headless prompt: %S\n" function))
        (let ((standard-output (current-buffer))) (backtrace))))
    (signal 'inhibited-interaction (list function))))
(defun lc-last-input-frame-deleted (_frame)
  "Fallback for external frame deletion, never a place for save prompts."
  (when (and (not noninteractive) (null (lc-input-frames))
             (active-minibuffer-window) (> (recursion-depth) 0))
    (abort-recursive-edit)))
(defun lc--manifest ()
  (when (file-remote-p default-directory)
    (user-error "Guix execution requires a local workspace; refusing host/remote fallback"))
  (let ((root (locate-dominating-file default-directory "manifest.scm")))
    (unless root
      (user-error "No manifest.scm for %s; refusing uncontained execution" default-directory))
    (let ((file (file-truename (expand-file-name "manifest.scm" root))))
      (unless (file-regular-p file) (user-error "Not a regular manifest: %s" file)) file)))
(defun lc--manifest-hash (file)
  (with-temp-buffer (set-buffer-multibyte nil) (insert-file-contents-literally file)
                    (secure-hash 'sha256 (current-buffer))))
(defun lc-authorize-manifest (file)
  "Approve exact FILE contents interactively; save approval through Customize."
  (let ((hash (lc--manifest-hash file)))
    (unless (equal hash (cdr (assoc file lc-guix-authorized-manifests)))
      (unless (yes-or-no-p (format "Trust Guix manifest code %s (SHA256 %s)? " file hash))
        (user-error "Manifest not approved; refusing execution"))
      (setf (alist-get file lc-guix-authorized-manifests nil nil #'equal) hash)
      (customize-save-variable 'lc-guix-authorized-manifests lc-guix-authorized-manifests))
    hash))
(defun lc--mount-arguments (paths flag)
  (mapcar (lambda (path)
            (let ((file (file-truename (expand-file-name path lc-real-home))))
              (unless (file-exists-p file) (user-error "Missing permitted mount: %s" file))
              (when (equal file "/") (user-error "Refusing a host-root mount"))
              (concat flag file))) paths))
(defun lc-guix-command (kind)
  "Produce an argument list for trusted Guix execution of KIND (agent/compile).
No implicit Guix state/logs, /tmp, credentials or host Emacs mounts."
  (unless (executable-find "guix") (user-error "Guix unavailable; refusing host fallback"))
  (let* ((manifest (lc--manifest))
         (hash (lc-authorize-manifest manifest))
         (agent (eq kind 'agent))
         (args (append (list "guix" "shell" "--container" "--network" "--pure"
                             "--expose=/usr/bin/env" "-m" manifest)
                       (if agent lc-guix-agent-packages lc-guix-compilation-packages))))
    ;; Close the approval/read race as far as the client can; no directory-level bypass.
    (unless (equal hash (lc--manifest-hash manifest))
      (user-error "Manifest changed during approval; refusing execution"))
    (when agent
      (setq args (append args
                         (lc--mount-arguments
                          (append lc-agent-program-directories lc-agent-extra-exposes) "--expose=")
                         (lc--mount-arguments lc-agent-extra-shares "--share=")))
      (when lc-agent-share-host-emacs
        (setq args (append args (lc--mount-arguments
                                (list lc-host-emacs-socket-directory) "--share=")
                           '("emacs-minimal"))))
      (when lc-agent-share-tmp (setq args (append args '("--share=/tmp")))))
    ;; Only explicitly injected provider secrets survive --pure; no _KEY/_TOKEN sweep.
    (when agent
      (dolist (name '("OPENAI_API_KEY" "ANTHROPIC_API_KEY" "GROQ_API_KEY"
                      "OPENCODE_API_KEY" "ZHIPU_API_KEY"))
        ;; The ACP client injects these after constructing this argument list.
        (push (concat "--preserve=^" name "$") args)))
    (append args '("--"))))
(defun lc-wrap-compilation (function command &rest args)
  "All compilation-start commands are contained, or fail."
  (let* ((runner (lc-guix-command 'compile))
         (default-directory (file-name-directory (lc--manifest)))
         (wrapped (mapconcat #'shell-quote-argument
                             (append runner (list "/bin/sh" "-c" command)) " ")))
    (apply function wrapped args)))
(defun lc-wrap-agent-client (function &rest args)
  "Enforce the actual runner at the client-creation boundary."
  (setq agent-shell-text-file-capabilities nil)
  (let ((agent-shell-text-file-capabilities nil)
        (default-directory (file-name-directory (lc--manifest))))
    (apply function args)))
(defun lc-build-agent-command (command)
  "Enforce containment for ACP creation AND subsequent client shell commands."
  (append (lc-guix-command 'agent) command))
(defun lc-install-security ()
  "Install idempotent policy before any services or user commands."
  (dolist (reader '(read-from-minibuffer read-char read-char-exclusive read-key y-or-n-p))
    (unless (advice-member-p #'lc-guard-input reader)
      (advice-add reader :around #'lc-guard-input)))
  (add-hook 'after-delete-frame-functions #'lc-last-input-frame-deleted)
  (with-eval-after-load 'compile
    (unless (advice-member-p #'lc-wrap-compilation 'compilation-start)
      (advice-add 'compilation-start :around #'lc-wrap-compilation)))
  (with-eval-after-load 'agent-shell
    (setq agent-shell-text-file-capabilities nil)
    (unless (fboundp 'agent-shell--build-command-for-execution)
      (error "This agent-shell lacks the tested command-wrapping API"))
    (unless (advice-member-p #'lc-build-agent-command 'agent-shell--build-command-for-execution)
      (advice-add 'agent-shell--build-command-for-execution :override #'lc-build-agent-command))
    (unless (advice-member-p #'lc-wrap-agent-client 'agent-shell--make-acp-client)
      (advice-add 'agent-shell--make-acp-client :around #'lc-wrap-agent-client))))
(provide 'lc-security)
