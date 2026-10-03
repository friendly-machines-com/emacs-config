;;; lc-guix-build.el --- Preserved build tree navigation -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'subr-x)
(require 'thingatpt)
(defun guix-build-dir-p (name)
  (and (stringp name) (string-match-p "\\`/tmp/guix-build-.*\\.drv-[0-9]+\\(?:/.*\\)?\\'" name)))
(defun guix-ensure-drv-0-directory (directory)
  "Normalize DIRECTORY to its .drv-0 sibling, preserving any subdirectory.
Only explicit confirmation allows deleting an existing destination."
  (interactive "DGuix build directory: ")
  (let ((path (directory-file-name (expand-file-name directory))))
    (unless (string-match "\\`\\(/tmp/guix-build-.*\\.drv-\\)\\([0-9]+\\)\\(/.*\\)?\\'" path)
      (user-error "Not a preserved Guix build tree: %s" path))
    (let* ((prefix (match-string 1 path)) (number (match-string 2 path))
           (suffix (or (match-string 3 path) ""))
           (source (concat prefix number)) (target (concat prefix "0")))
      (unless (equal source target)
        (unless (file-directory-p source) (user-error "Missing build tree: %s" source))
        (when (file-exists-p target)
          (unless (yes-or-no-p (format "Delete existing destination %s? " target))
            (user-error "Normalization cancelled"))
          (delete-directory target t t))
        (rename-file source target))
      (concat target suffix))))
(defun guix-normalize-and-open-build-dir (directory)
  "Normalize explicit DIRECTORY and open it, not an unrelated thing-at-point."
  (interactive (list (or (thing-at-point 'filename t) (read-directory-name "Build directory: "))))
  (dired (guix-ensure-drv-0-directory directory)))
(with-eval-after-load 'compile
  (add-to-list 'compilation-error-regexp-alist-alist
               '(lc-guix-build "note: keeping build directory ['‘]\\([^'’\n]+\\)['’]" 1 nil nil 0))
  (add-to-list 'compilation-error-regexp-alist 'lc-guix-build))
(with-eval-after-load 'embark
  (defun lc-embark-guix-build-target ()
    (when (derived-mode-p 'compilation-mode)
      (when-let* ((path (thing-at-point 'filename t)) (_ (guix-build-dir-p path)))
        (cons 'guix-build-dir path))))
  (defvar-keymap embark-guix-build-dir-map :doc "Actions on preserved Guix build trees."
    "d" #'guix-normalize-and-open-build-dir)
  (add-to-list 'embark-target-finders #'lc-embark-guix-build-target)
  (add-to-list 'embark-keymap-alist '(guix-build-dir . embark-guix-build-dir-map)))
(provide 'lc-guix-build)
