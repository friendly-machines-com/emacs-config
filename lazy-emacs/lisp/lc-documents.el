;;; lc-documents.el --- Document modes and lazy Org/PDF links -*- lexical-binding: t; -*-
(require 'lc-core)
(require 'use-package)
(use-package pdf-tools :ensure nil :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
  :config
  (require 'saveplace-pdf-view) (require 'autoresize)
  (keymap-set pdf-view-mode-map "<Search>" #'pdf-occur)
  (keymap-set pdf-view-mode-map "C-f" #'pdf-occur)
  (add-hook 'pdf-view-mode-hook #'auto-revert-mode))
(use-package nov :ensure nil :mode ("\\.epub\\'" . nov-mode)
  :config
  (dolist (entry '(("<mouse-8>" . nov-history-back) ("<mouse-9>" . nov-history-forward)
                   ("M-<left>" . nov-history-back) ("M-<right>" . nov-history-forward)))
    (keymap-set nov-mode-map (car entry) (cdr entry)))
  (require 'lc-mathml))
(use-package org-noter :ensure nil :commands org-noter
  :config
  (lc-require 'org-noter-pdftools)
  (require 'lc-noter-compat))
(use-package org-pdftools :ensure nil :commands org-pdftools-setup-link)
(with-eval-after-load 'org
  (dolist (type '("pdf" "pdftools"))
    (let ((type type))
      (org-link-set-parameters
       type :follow
       (lambda (path arg)
         (lc-require 'org-pdftools) (org-pdftools-setup-link)
         (let ((follow (org-link-get-parameter type :follow)))
           (unless (symbolp follow)
             (user-error "Org PDF integration did not register %s links" type))
           (funcall follow path arg)))))))
(use-package dirvish :ensure nil :commands (dirvish dirvish-side))
(use-package dired-launch :ensure nil :commands dired-launch-mode)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(provide 'lc-documents)
