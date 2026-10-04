;;; lc-noter-compat.el --- Public Org Noter/PDFTools integration -*- lexical-binding: t; -*-
(require 'org-noter)
(require 'org-noter-pdftools)
;; The supplied integration installs the module's location parsing/conversion/
;; navigation hooks. Keep stock coordinate getters and start-location behavior.
;; org-noter 1.6.1 already contains the historical start-location fix.
(defun org-noter-pdftools-insert-precise-note (&optional toggle-no-questions)
  "Use the stock precise-note command with PDF search/annotation options.
A prefix toggles questioning, preserving this local helper's historical intent;
the stock command's different prefix meaning (highlight toggle) is not forwarded."
  (interactive "P")
  (let ((org-noter-insert-note-no-questions
         (if toggle-no-questions (not org-noter-insert-note-no-questions)
           org-noter-insert-note-no-questions))
        (org-pdftools-use-isearch-link t)
        (org-pdftools-use-freepointer-annot t)
        (current-prefix-arg nil))
    (call-interactively #'org-noter-insert-precise-note)))
(with-eval-after-load 'pdf-annot
  (add-hook 'pdf-annot-activate-handler-functions #'org-noter-pdftools-jump-to-note))
(provide 'lc-noter-compat)
