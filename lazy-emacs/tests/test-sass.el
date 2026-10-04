;;; test-sass.el --- Actual local Sass fixes and compilation boundary -*- lexical-binding: t; -*-
(require 'ert)
(require 'ssass-mode)
(require 'compile)
(ert-deftest lc-sass-regex-data ()
  (should (string-match-p ssass-variable-regex "$foreground"))
  (should (string-match-p ssass-key-regex "\tcolor:"))
  (should (string-match-p ssass-comment-regex "  // comment")))
(ert-deftest lc-sass-refuses-uncontained-build-and-cleans-input ()
  (let ((directory (make-temp-file "/tmp/lc-sass-no-manifest-" t)))
    (unwind-protect
        (with-temp-buffer
          (setq default-directory (file-name-as-directory directory))
          (insert "body\n  color: red\n")
          (should-error (ssass-eval-region (point-min) (point-max)) :type 'user-error)
          (should-not (directory-files directory nil "\\.sass-eval-")))
      (delete-directory directory t))))
(ert-deftest lc-sass-input-lifetime-finish-hook ()
  (let ((directory (make-temp-file "/tmp/lc-sass-lifetime-" t))
        (output (generate-new-buffer " *fixture Sass compiler*")) process)
    (unwind-protect
        (with-temp-buffer
          (setq default-directory (file-name-as-directory directory))
          (insert "body\n  color: red\n")
          ;; This test isolates the input-lifetime contract. The negative test
          ;; above exercises the real configured Guix build boundary separately.
          (setq process (make-process :name "fixture-sass" :buffer output :command '("sleep" "1") :noquery t))
          (cl-letf (((symbol-function 'compilation-start) (lambda (&rest _) output)))
            (ssass-eval-region (point-min) (point-max)))
          (should (= (length (directory-files directory nil "\\.sass-eval-")) 1))
          (with-current-buffer output
            ;; Public compilation completion callbacks receive (BUFFER MESSAGE).
            (run-hook-with-args 'compilation-finish-functions output "finished"))
          (should-not (directory-files directory nil "\\.sass-eval-")))
      (when (and process (process-live-p process)) (delete-process process))
      (when (buffer-live-p output) (kill-buffer output))
      (delete-directory directory t))))
