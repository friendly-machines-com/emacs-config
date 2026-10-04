;;; lc-preview.el --- Batched explicit-entry previews in non-Org buffers -*- lexical-binding: t; -*-
(require 'lc-core)
(cl-defstruct (lc-preview-entry (:constructor lc-preview-entry-create))
  "A queued fragment: moving bounds, immutable source, backend and preamble."
  begin end source backend preamble)
(defvar-local lc--preview-queue nil)
(defvar-local lc--preview-timer nil)
(defvar lc--preview-active-buffer nil
  "Buffer whose MathML batch is awaiting the renderer's public finish hook.")
(defun lc-preview-release-entry (entry)
  (set-marker (lc-preview-entry-begin entry) nil)
  (set-marker (lc-preview-entry-end entry) nil))
(defun lc-preview-clear-queue ()
  (when (timerp lc--preview-timer) (cancel-timer lc--preview-timer))
  (setq lc--preview-timer nil)
  (mapc #'lc-preview-release-entry lc--preview-queue)
  (setq lc--preview-queue nil))
(defun lc-preview-schedule ()
  (unless (timerp lc--preview-timer)
    (setq lc--preview-timer (run-at-time .05 nil #'lc-preview-drain (current-buffer)))))
(defun lc-preview-enqueue (begin end source backend preamble)
  "Queue source with markers so subsequent SHR edits do not invalidate bounds."
  (push (lc-preview-entry-create :begin (copy-marker begin t) :end (copy-marker end)
                                 :source source :backend backend :preamble preamble)
        lc--preview-queue)
  (add-hook 'kill-buffer-hook #'lc-preview-clear-queue nil t)
  (lc-preview-schedule))
(defun lc-preview-finished (_exit-code _process-buffer information)
  "Handle Org's documented finish callback and :org-buffer context.
This only coordinates our MathML batches; it does not patch Org processes or
infer their state from private process-buffer names."
  (when (eq (plist-get information :org-buffer) lc--preview-active-buffer)
    (setq lc--preview-active-buffer nil)))
(defun lc-preview-entry-as-org (entry)
  "Org's explicit-entry API consumes (BEG END VALUE), not our internal record."
  (list (marker-position (lc-preview-entry-begin entry))
        (marker-position (lc-preview-entry-end entry))
        (lc-preview-entry-source entry)))
(defun lc-preview-report-error (entries error-data)
  (let ((inhibit-read-only t) (message (error-message-string error-data)))
    (dolist (entry entries)
      (add-text-properties (marker-position (lc-preview-entry-begin entry))
                           (marker-position (lc-preview-entry-end entry))
                           (list 'help-echo message 'face 'warning)))
    (display-warning 'lc-mathml message)))
(defun lc-preview-drain (buffer)
  "Render one homogeneous queued batch using the public explicit-entry API.
The pinned local renderer returns jobs for asynchronous work, nil for cached
work; completion is delivered through org-latex-preview-process-finish-functions."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (setq lc--preview-timer nil)
      (cond
       (lc--preview-active-buffer (when lc--preview-queue (lc-preview-schedule)))
       (lc--preview-queue
        (let* ((batch (nreverse lc--preview-queue)) (first (car batch))
               (backend (lc-preview-entry-backend first))
               (preamble (lc-preview-entry-preamble first)) selected remaining)
          (setq lc--preview-queue nil)
          (dolist (entry batch)
            (if (and (eq (lc-preview-entry-backend entry) backend)
                     (equal (lc-preview-entry-preamble entry) preamble))
                (push entry selected) (push entry remaining)))
          (setq selected (nreverse selected) lc--preview-queue (nreverse remaining))
          (unwind-protect
              (condition-case error-data
                  (progn
                    (require 'org-latex-preview)
                    (add-hook 'org-latex-preview-process-finish-functions #'lc-preview-finished)
                    (setq lc--preview-active-buffer buffer)
                    (unless (org-latex-preview-place backend (mapcar #'lc-preview-entry-as-org selected)
                                                     nil preamble)
                      (setq lc--preview-active-buffer nil)))
                (error (setq lc--preview-active-buffer nil)
                       (lc-preview-report-error selected error-data)))
            (mapc #'lc-preview-release-entry selected))
          (when lc--preview-queue (lc-preview-schedule))))))))
(provide 'lc-preview)
