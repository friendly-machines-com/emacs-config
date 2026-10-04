;;; test-modes.el --- Real mode entry points without starting external servers -*- lexical-binding: t; -*-
(require 'ert)
(require 'eglot)
(require 'lsp-mode)
(require 'rustic)
(ert-deftest lc-language-entry-points ()
  ;; These tests concern mode routing and hook availability. Stub the documented
  ;; server-entry commands, never package parsing or production path handling.
  (cl-letf (((symbol-function 'eglot-ensure) #'ignore)
            ((symbol-function 'lsp) #'ignore)
            ((symbol-function 'lsp-deferred) #'ignore))
    ;; Records are (FILENAME MODE-SAMPLE EXPECTED-MODE-ANCESTOR).
    (dolist (sample '(("sample.py" "print('fixture')\n" python-base-mode)
                      ("sample.rs" "fn main() {}\n" rust-mode)
                      ("sample.tex" "\\documentclass{article}\n" LaTeX-mode)
                      ("sample.vue" "<template><div /></template>\n" web-mode)
                      ("sample.sass" "body\n  color: red\n" ssass-mode)
                      ("sample.yaml" "key: value\n" yaml-mode)))
      (pcase-let ((`(,filename ,text ,expected-mode) sample))
        (with-temp-buffer
          (setq buffer-file-name (expand-file-name filename lc-real-home))
          (insert text) (set-buffer-modified-p nil)
          (set-auto-mode)
          (unless (derived-mode-p expected-mode)
            (ert-fail (format "%s selected %s, expected ancestor %s" filename major-mode expected-mode))))))))
