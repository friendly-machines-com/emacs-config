;; Run: guix repl lazy-emacs/tools/check-manifest.scm
(use-modules (gnu packages) (ice-9 match))
(define specs
  (call-with-input-file "lazy-emacs/manifest.scm"
    (lambda (port)
      (let loop ()
        (match (read port)
          ((? eof-object?) '())
          (('specifications->manifest ('quote names)) names)
          (_ (loop)))))))
(for-each
 (lambda (spec)
   (catch 'quit
     (lambda () (specification->package spec) (format #t "OK ~a~%" spec))
     (lambda args (format #t "MISSING ~a~%" spec))))
 specs)
