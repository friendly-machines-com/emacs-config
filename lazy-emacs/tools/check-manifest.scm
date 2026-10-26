;; Run: guix repl lazy-emacs/tools/check-manifest.scm
(use-modules (guix profiles))
;; Evaluate the real manifest, including its recursive package transformation;
;; scanning for a quoted specifications->manifest list would silently check
;; nothing once the manifest contains a package-level patch.
(define manifest
  (load (string-append (dirname (current-filename)) "/../manifest.scm")))
(unless (manifest? manifest)
  (error "manifest.scm did not return a Guix manifest"))
(for-each
 (lambda (entry)
   (format #t "OK ~a ~a~%" (manifest-entry-name entry) (manifest-entry-version entry)))
 (manifest-entries manifest))
