;;; autoresize.el --- Bounded PDF/DocView window resizing -*- lexical-binding: t; -*-
(require 'lc-core)
(defcustom document-window-max-width 120 "Maximum document window width in characters."
  :type 'integer :group 'lazy-config)
(defvar lc--document-resizing nil)
(defun document-window-enforce-max-width (&rest _)
  "Fit a document's aspect ratio without impossible resize requests.
The public image-size APIs return a (WIDTH . HEIGHT) pixel pair. A not-yet-ready
image is skipped; actual backend errors are not swallowed as a successful resize."
  (interactive)
  (when (and (not lc--document-resizing) (not (window-minibuffer-p))
             (memq major-mode '(pdf-view-mode doc-view-mode)) (not (one-window-p t)))
    (let* ((lc--document-resizing t)
           (window (selected-window))
           (size (if (eq major-mode 'pdf-view-mode)
                     (and (pdf-view-current-image) (pdf-view-image-size))
                   (and (doc-view-current-slice) (image-size (doc-view-current-image) t))))
           (width (car-safe size)) (height (cdr-safe size)))
      (when (and (numberp width) (numberp height) (> height 0))
        (let* ((target (min (* document-window-max-width (frame-char-width))
                            (floor (* width (/ (float (window-body-height window t)) height)))))
               (delta (- target (window-body-width window t) 5))
               (allowed (window-resizable window delta t nil t)))
          (when (and allowed (not (zerop allowed)))
            (window-resize window allowed t nil t)))))))
(add-hook 'pdf-view-after-change-page-hook #'document-window-enforce-max-width)
(add-hook 'doc-view-after-change-page-hook #'document-window-enforce-max-width)
(add-hook 'window-configuration-change-hook #'document-window-enforce-max-width)
(provide 'autoresize)
