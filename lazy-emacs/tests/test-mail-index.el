;;; test-mail-index.el --- Real mu against an empty, synthetic Maildir -*- lexical-binding: t; -*-
(require 'ert)
(require 'mu4e)
(ert-deftest lc-private-mail-index-init-without-sync ()
  (let* ((temporary (make-temp-file "/tmp/lc-mail-fixture-" t))
         (lc-mail-root (expand-file-name "mail" temporary))
         (mu4e-mu-home (expand-file-name "index" temporary))
         process)
    (unwind-protect
        (progn
          (dolist (name '("cur" "new" "tmp"))
            (make-directory (expand-file-name name lc-mail-root) t))
          (lc-mail-initialize-index)
          (setq process (get-process "lazy-mail-index"))
          (let ((deadline (+ (float-time) 10)))
            (while (and process (process-live-p process) (< (float-time) deadline))
              (accept-process-output process .05)))
          (should (file-directory-p (expand-file-name "xapian" mu4e-mu-home)))
          (when process (should (= (process-exit-status process) 0)))
          ;; Reinitializing existing data is deliberately not offered by this helper.
          (should-error (lc-mail-initialize-index) :type 'user-error)
          (should-not (and (boundp 'mu4e--update-timer) mu4e--update-timer)))
      (when (and process (process-live-p process)) (delete-process process))
      (delete-directory temporary t))))
