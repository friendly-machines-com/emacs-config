;;; lc-security.el --- Fail-closed processes and usable input frames -*- lexical-binding: t; -*-
(require 'lc-core)
(defvar lc--input-reading nil)
(defgroup lc-security nil "Execution and daemon input boundaries." :group 'lazy-config)
(defcustom lc-headless-traces nil "Record backtraces for rejected headless prompts."
  :type 'boolean :group 'lc-security)
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
(defun lc-install-security ()
  "Install idempotent policy before any services or user commands."
  (dolist (reader '(read-from-minibuffer read-char read-char-exclusive read-key y-or-n-p))
    (unless (advice-member-p #'lc-guard-input reader)
      (advice-add reader :around #'lc-guard-input)))
  (add-hook 'after-delete-frame-functions #'lc-last-input-frame-deleted)
  )
(provide 'lc-security)
