;;; test-gui.el --- Real PGTK daemon/frame regressions on an isolated display -*- lexical-binding: t; -*-
;; The Python runner starts this with --no-init-file and an isolated Xvfb.
;; test-init supplies a separate init/state directory and synthetic Org files.
(require 'json)
(condition-case error-data
    (load (expand-file-name "test-init.el" (file-name-directory load-file-name)) nil t)
  (error
   (with-temp-file (getenv "LC_GUI_REPORT")
     (insert (json-encode `((status . "failed") (phase . "initialization")
                           (error . ,(error-message-string error-data))))))
   (kill-emacs 1)))
(message "GUI_TEST: fixture initialization completed")
(defvar lc-gui-primary-frame nil)
(defun lc-gui-new-frame () (make-frame '((window-system . pgtk) (width . 100) (height . 35))))
(defun lc-gui-delete-fixture-frame (frame)
  "Test cleanup only; assertions use the real close policy."
  (when (frame-live-p frame) (let ((lc--deleting-frame t)) (delete-frame frame t))))
(defun lc-gui-wait-until (predicate &optional seconds)
  (let ((deadline (+ (float-time) (or seconds 2))))
    (while (and (< (float-time) deadline) (not (funcall predicate)))
      (sit-for .02)))
  (funcall predicate))
(ert-deftest lc-gui-real-pgtk-chrome ()
  :tags '(lc-gui)
  (with-selected-frame lc-gui-primary-frame
    (should (eq (framep (selected-frame)) 'pgtk))
    (should (lc-input-frame-p (selected-frame)))
    (should global-tab-line-mode)
    (should (eq tab-line-tab-name-format-function #'lc-tab-name-format))
    (should (stringp (window-tool-bar-string)))
    (should (= (frame-parameter nil 'tool-bar-lines) 0))))
(ert-deftest lc-gui-frame-save-isolated-and-hidden-buffer ()
  :tags '(lc-gui)
  (let* ((first (lc-gui-new-frame)) (second (lc-gui-new-frame))
         (file-a (expand-file-name "frame-a.txt" lc-real-home))
         (file-b (expand-file-name "frame-b.txt" lc-real-home)) buffer-a buffer-b)
    (unwind-protect
        (progn
          (with-selected-frame first
            (setq buffer-a (find-file-noselect file-a))
            (switch-to-buffer buffer-a) (insert "first-frame edit")
            ;; Keep the edit hidden behind another buffer to exercise native history.
            (switch-to-buffer (get-buffer-create "*fixture hidden tab*")))
          (with-selected-frame second
            (setq buffer-b (find-file-noselect file-b))
            (switch-to-buffer buffer-b) (insert "second-frame edit"))
          (lc-close-frame-now first)
          (should-not (frame-live-p first))
          (should (file-exists-p file-a))
          (should-not (file-exists-p file-b))
          (should (buffer-modified-p buffer-b)))
      (dolist (buffer (list buffer-a buffer-b))
        (when (buffer-live-p buffer) (with-current-buffer buffer (set-buffer-modified-p nil)) (kill-buffer buffer)))
      (lc-gui-delete-fixture-frame first) (lc-gui-delete-fixture-frame second))))
(ert-deftest lc-gui-cancelled-save-keeps-frame ()
  :tags '(lc-gui)
  (let ((frame (lc-gui-new-frame)) buffer)
    (unwind-protect
        (progn
          (with-selected-frame frame
            (setq buffer (find-file-noselect (expand-file-name "cancelled.txt" lc-real-home)))
            (switch-to-buffer buffer) (insert "unsaved"))
          ;; Simulate a user cancellation at the public save boundary, not a
          ;; different close implementation or a bypassed last-frame rule.
          (cl-letf (((symbol-function 'save-buffer) (lambda (&rest _) (signal 'quit nil))))
            (lc-close-frame-now frame))
          (should (frame-live-p frame)) (should (buffer-modified-p buffer)))
      (when (buffer-live-p buffer) (with-current-buffer buffer (set-buffer-modified-p nil)) (kill-buffer buffer))
      (lc-gui-delete-fixture-frame frame))))
(ert-deftest lc-gui-last-frame-orphan-work-keeps-gui ()
  :tags '(lc-gui)
  (let ((buffer (generate-new-buffer "fixture orphan note")))
    (unwind-protect
        (progn
          (with-current-buffer buffer (text-mode) (insert "A note not displayed in any frame."))
          (should (= (length (lc-input-frames)) 1))
          (lc-close-frame-now lc-gui-primary-frame)
          (should (frame-live-p lc-gui-primary-frame))
          (should (buffer-modified-p buffer))
          (should (get-buffer-window "*Unsaved work*" lc-gui-primary-frame)))
      (with-current-buffer buffer (set-buffer-modified-p nil)) (kill-buffer buffer))))
(defun lc-gui-prompt-regression (reader)
  "Close a real frame during READER and verify the pending input unwinds."
  (let ((frame (lc-gui-new-frame)) cancelled)
    (unwind-protect
        (progn
          (select-frame-set-input-focus frame)
          (run-at-time .08 nil (lambda () (when (frame-live-p frame) (delete-frame frame))))
          (condition-case nil
              (pcase reader
                ('minibuffer (completing-read "Fixture prompt: " '("one" "two")))
                ('key (read-key "Fixture direct-key question: " 3)))
            (quit (setq cancelled t)))
          (unless (lc-gui-wait-until (lambda () (not (frame-live-p frame))))
            (error "Frame did not close after input cancellation"))
          (unless cancelled (error "Pending %s input did not unwind" reader))
          t)
      (lc-gui-delete-fixture-frame frame))))
(ert-deftest lc-gui-close-during-completing-read ()
  :tags '(lc-gui)
  (should (lc-gui-prompt-regression 'minibuffer)))
(ert-deftest lc-gui-close-during-read-key ()
  :tags '(lc-gui)
  (should (lc-gui-prompt-regression 'key)))
(when (getenv "LC_PREVIEW_TEST")
  (ert-deftest lc-gui-mathml-real-local-renderer ()
    :tags '(lc-gui)
    (require 'lc-mathml)
    (let ((buffer (generate-new-buffer "fixture MathML render")))
      (unwind-protect
          (with-selected-frame lc-gui-primary-frame
            (switch-to-buffer buffer)
            (lc-shr-math '(math nil (mfrac nil (mi nil "x") (mn nil "2"))))
            (lc-preview-drain buffer)
            (should
             (lc-gui-wait-until
              (lambda ()
                (with-current-buffer buffer
                  (seq-some (lambda (overlay) (overlay-get overlay 'display))
                            (overlays-in (point-min) (point-max))))) 20)))
        (with-current-buffer buffer (set-buffer-modified-p nil)) (kill-buffer buffer)))))
(defun lc-gui-report (data)
  (with-temp-file (getenv "LC_GUI_REPORT") (insert (json-encode data))))
(defun lc-gui-run ()
  (condition-case error-data
      (progn
        (message "GUI_TEST: creating real PGTK frame")
        (setq lc-gui-primary-frame (lc-gui-new-frame))
        (message "GUI_TEST: frame created")
        (select-frame-set-input-focus lc-gui-primary-frame)
        (let* ((stats (ert-run-tests-batch '(tag lc-gui)))
               (failures (ert-stats-completed-unexpected stats)))
          ;; Capture only this isolated daemon's test/renderer diagnostics.
          (dolist (buffer (buffer-list))
            (when (or (equal (buffer-name buffer) "*Messages*")
                      (string-prefix-p "*Org Preview" (buffer-name buffer)))
              (with-current-buffer buffer
                (write-region (point-min) (point-max)
                              (expand-file-name
                               (concat (replace-regexp-in-string "[^A-Za-z0-9-]" "_" (buffer-name)) ".log")
                               (file-name-directory (getenv "LC_GUI_REPORT"))) nil 'silent))))
          (lc-gui-report `((status . ,(if (zerop failures) "ready" "failed"))
                           (failures . ,failures)))))
    (error (lc-gui-report `((status . "failed") (error . ,(error-message-string error-data)))))))
;; Let normal daemon/server initialization complete before creating any GUI.
(run-at-time .3 nil #'lc-gui-run)
(message "GUI_TEST: GUI timer scheduled")
