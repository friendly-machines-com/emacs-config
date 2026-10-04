;;; check-elisp.el --- Non-evaluating checks of maintained config source -*- lexical-binding: t; -*-
;; Run from the original config root with emacs -Q --batch -l this file.
(defvar lc-check-root (expand-file-name "../" (file-name-directory load-file-name)))
(let ((files (mapcar (lambda (name) (expand-file-name name lc-check-root))
                     '("early-init.el" "init.el" "defaults.el"))))
  (dolist (directory '("lisp" "user-lisp" "tests"))
    (setq files (append files (directory-files (expand-file-name directory lc-check-root) t "\\.el\\'"))))
  (dolist (file files)
    (with-temp-buffer
      (insert-file-contents file)
      (emacs-lisp-mode)
      (condition-case error-data
          (check-parens)
        (error (error "%s:%s: %s" file (line-number-at-pos) (error-message-string error-data))))))
  (princ (format "Balanced source files: %d\n" (length files))))
