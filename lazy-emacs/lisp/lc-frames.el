;;; lc-frames.el --- Save work in the closing frame, never on a dummy frame -*- lexical-binding: t; -*-
(require 'lc-security)
(defgroup lc-frames nil "Frame-local work and daemon closing." :group 'lazy-config)
(defcustom lc-save-on-frame-close t "Save this frame's modified files before closing it."
  :type 'boolean :group 'lc-frames)
(defcustom lc-protect-last-frame t
  "Keep the last input frame open when any unsaved user work remains."
  :type 'boolean :group 'lc-frames)
(defvar lc--deleting-frame nil)
(defvar lc--closing-frames (make-hash-table :test #'eq :weakness 'key))
(defun lc-frame-buffers (frame)
  "Live buffers actually associated with FRAME, including hidden tab history."
  (delete-dups
   (cl-remove-if-not
    #'buffer-live-p
    (append (frame-parameter frame 'lc-work-buffers)
            (cl-mapcan (lambda (window)
                         (cons (window-buffer window)
                               (append (mapcar #'car (window-prev-buffers window))
                                       (window-next-buffers window))))
                       (window-list frame 'no-minibuffer))))))
(defun lc-track-frame (frame)
  (when (and (frame-live-p frame) (not (frame-initial-p frame))
             (not (frame-parent frame)))
    (set-frame-parameter frame 'lc-work-buffers (lc-frame-buffers frame))))
(defun lc-track-window (window &rest _)
  (lc-track-frame (window-frame (or window (selected-window)))))
(defun lc-user-work-p (buffer)
  "Whether BUFFER contains modified user work, not ordinary process/log output."
  (and (buffer-live-p buffer)
       (with-current-buffer buffer
         (and (buffer-modified-p) (not (minibufferp))
              (or buffer-file-name buffer-offer-save
                  (and (not buffer-read-only) (not (get-buffer-process buffer))
                       (not (string-prefix-p " " (buffer-name)))
                       (or (derived-mode-p 'text-mode 'lisp-interaction-mode
                                           'message-mode)
                           (equal (buffer-name) "*scratch*"))))))))
(defun lc-unsaved-work (buffers) (cl-remove-if-not #'lc-user-work-p buffers))
(defun lc-save-frame-work (buffers)
  "Save the explicit BUFFERS set. Cancellation/errors escape and keep the frame."
  (dolist (buffer (lc-unsaved-work buffers))
    (with-current-buffer buffer
      (if buffer-file-name
          (save-buffer)
        (pop-to-buffer-same-window buffer)
        (if (yes-or-no-p (format "Save unsaved buffer %s before closing? " (buffer-name)))
            (call-interactively #'write-file)
          (user-error "Frame kept open: unsaved buffer %s" (buffer-name)))))))
(define-derived-mode lc-unsaved-review-mode tabulated-list-mode "Unsaved work"
  "Review orphaned edits before closing the final GUI. RET visits a buffer."
  (setq tabulated-list-format [("Buffer" 32 t) ("File / draft" 60 t)]
        tabulated-list-padding 2)
  (tabulated-list-init-header))
(defun lc-review-unsaved-visit ()
  (interactive)
  (let ((buffer (tabulated-list-get-id)))
    (when (buffer-live-p buffer) (switch-to-buffer buffer))))
(keymap-set lc-unsaved-review-mode-map "RET" #'lc-review-unsaved-visit)
(defun lc-review-unsaved (buffers)
  "Present BUFFERS in the still-live closing frame; never save them implicitly."
  (pop-to-buffer-same-window (get-buffer-create "*Unsaved work*"))
  (lc-unsaved-review-mode)
  (setq tabulated-list-entries
        (mapcar (lambda (buffer)
                  (list buffer (vector (buffer-name buffer)
                                       (or (buffer-file-name buffer) "unsaved note/draft"))))
                buffers))
  (tabulated-list-print t)
  (message "Frame kept open. RET visits work; save it or explicitly discard, then close again."))
(defun lc-close-frame-now (frame)
  "Save FRAME's work and close only when saving and last-frame review succeed."
  (when (and (frame-live-p frame) (lc-input-frame-p frame))
    (puthash frame t lc--closing-frames)
    (unwind-protect
        (condition-case err
            (with-selected-frame frame
              (lc-track-frame frame)
              (when lc-save-on-frame-close (lc-save-frame-work (lc-frame-buffers frame)))
              (let ((remaining (lc-unsaved-work (lc-frame-buffers frame)))
                    (orphans (and lc-protect-last-frame
                                  (= (length (lc-input-frames)) 1)
                                  (lc-unsaved-work (buffer-list)))))
                (cond (remaining (lc-review-unsaved remaining))
                      (orphans (lc-review-unsaved orphans))
                      (t (let ((lc--deleting-frame t)) (delete-frame frame t))))))
          (quit (message "Frame close cancelled; work and GUI retained"))
          (error (display-warning 'lazy-config
                                  (format "Frame kept open: %s" (error-message-string err)))))
      (remhash frame lc--closing-frames))))
(defun lc-request-frame-close (frame)
  "Unwind pending input before doing any new save interaction."
  (if (gethash frame lc--closing-frames)
      (signal 'quit nil)
    (if (or (active-minibuffer-window) (> (recursion-depth) 0)
            ;; This also catches direct key questions outside a recursive edit.
            lc--input-reading)
        (progn
          (run-at-time 0 nil #'lc-close-frame-now frame)
          (if (> (recursion-depth) 0) (abort-recursive-edit) (signal 'quit nil)))
      (lc-close-frame-now frame))))
(defun lc-handle-delete-frame (event)
  (interactive "e")
  (let ((frame (posn-window (event-start event))))
    ;; lc--input-reading is dynamically bound around all covered question readers,
    ;; including read-key (which has no native inhibit-interaction check).
    (lc-request-frame-close frame)))
(defun lc-delete-frame-advice (function &optional frame force)
  (let ((frame (or frame (selected-frame))))
    (if (or lc--deleting-frame noninteractive (not (daemonp))
            (not (lc-input-frame-p frame)))
        (funcall function frame force)
      (lc-request-frame-close frame))))
(defun lc-install-frame-policy ()
  (add-hook 'window-buffer-change-functions #'lc-track-frame)
  (add-hook 'after-make-frame-functions #'lc-track-frame)
  (unless (advice-member-p #'lc-track-window 'set-window-buffer)
    (advice-add 'set-window-buffer :after #'lc-track-window))
  (unless (advice-member-p #'lc-delete-frame-advice 'delete-frame)
    (advice-add 'delete-frame :around #'lc-delete-frame-advice))
  (when (daemonp) (define-key special-event-map [delete-frame] #'lc-handle-delete-frame)))
(provide 'lc-frames)
