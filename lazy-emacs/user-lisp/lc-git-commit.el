;;; lc-git-commit.el --- Conservative Guix package-add commit messages -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'subr-x)
(defun lc-guix-message-from-diff (lines)
  "Return a message for one new define-public in LINES, otherwise nil.
Reject removals, multiple files/hunks/forms and malformed Lisp. Never evaluate it."
  (let ((files nil) (hunks 0) (added nil) removed)
    (dolist (line lines)
      (cond ((string-prefix-p "+++ " line) (push (substring line 4) files))
            ((string-prefix-p "@@ " line) (cl-incf hunks))
            ((and (string-prefix-p "-" line) (not (string-prefix-p "--- " line))) (setq removed t))
            ((string-prefix-p "+" line) (push (substring line 1) added))))
    (when (and (= (length files) 1) (= hunks 1) (not removed))
      (condition-case nil
          (let* ((text (mapconcat #'identity (nreverse added) "\n"))
                 (read-result (read-from-string text)) (form (car read-result))
                 (tail (substring text (cdr read-result))))
            (when (and (string-blank-p tail) (eq (car-safe form) 'define-public)
                       (symbolp (cadr form)) (= (length form) 3))
              (let* ((variable (symbol-name (cadr form)))
                     (version (and (string-match "\\`\\(.+\\)-\\([0-9][0-9.a-z-]*\\)\\'" variable)
                                   (match-string 2 variable)))
                     (name (if version (match-string 1 variable) variable)))
                (format "gnu: Add %s%s.\n\n* %s (%s): New variable.\n"
                        name (if version (concat "@" version) "") (car files) variable))))
        (error nil)))))
(defun lc-generate-guix-commit ()
  "Seed only an otherwise empty commit buffer, never overwrite user prose."
  (when (and (fboundp 'magit-anything-staged-p) (magit-anything-staged-p)
             (string-blank-p (replace-regexp-in-string "^#.*$" "" (buffer-string))))
    (when-let* ((message (lc-guix-message-from-diff
                         (magit-git-lines "diff" "--cached" "--no-ext-diff" "--no-prefix" "--unified=0"))))
      (erase-buffer) (insert message)
      (when buffer-file-name (save-buffer)))))
(provide 'lc-git-commit)
