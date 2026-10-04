;;; test-gui-bare.el --- Control: PGTK frame creation without this configuration -*- lexical-binding: t; -*-
(require 'json)
(setq debug-on-error nil)
(run-at-time
 .3 nil
 (lambda ()
   (message "BARE_GUI: creating PGTK frame")
   (condition-case error-data
       (let ((frame (make-frame '((window-system . pgtk)))))
         (message "BARE_GUI: created")
         (with-temp-file (getenv "LC_GUI_REPORT")
           (insert (json-encode `((status . "ready") (frame . ,(symbol-name (framep frame))))))))
     (error
      (with-temp-file (getenv "LC_GUI_REPORT")
        (insert (json-encode `((status . "failed") (error . ,(error-message-string error-data))))))))))
