;;; shr-tag-math.el --- MathML through the local Org preview -*- lexical-binding: t; -*-
;; Copyright (C) 2024 Danny Milosavljevic
;; License: GPL-3.0-or-later
(require 'dom)
(require 'cl-lib)
(require 'lc-preview)
(defgroup lc-mathml nil "MathML images in mail/news/EWW." :group 'lazy-config)
(defcustom lc-mathml-preamble
  "\\documentclass{article}\n\\usepackage{amsmath}\n\\usepackage{amssymb}\n\\usepackage{mathtools}\n\\usepackage{xcolor}\n"
  "Preamble supplied to the local explicit-entry preview API."
  :type 'string :group 'lc-mathml)
(defcustom lc-mathml-process 'dvisvgm "Org preview backend for MathML."
  :type 'symbol :group 'lc-mathml)
(defun lc-mathml-escape (text)
  "Treat remote MathML text as data, never arbitrary TeX source."
  (mapconcat (lambda (char)
               (pcase char
                 (?\\ "\\backslash{}") (?{ "\\{") (?} "\\}")
                 (?& "\\&") (?% "\\%") (?# "\\#") (?_ "\\_") (?$ "\\$")
                 (?^ "\\hat{}") (?~ "\\sim{}") (_ (char-to-string char))))
             text ""))
(defconst lc-mathml-symbols
  '(("α" . "\\alpha ") ("β" . "\\beta ") ("γ" . "\\gamma ") ("δ" . "\\delta ")
    ("θ" . "\\theta ") ("λ" . "\\lambda ") ("μ" . "\\mu ") ("π" . "\\pi ")
    ("σ" . "\\sigma ") ("φ" . "\\phi ") ("ω" . "\\omega ")
    ("−" . "-") ("×" . "\\times ") ("⋅" . "\\cdot ") ("÷" . "\\div ")
    ("≤" . "\\leq ") ("≥" . "\\geq ") ("≠" . "\\neq ") ("∞" . "\\infty ")
    ("∑" . "\\sum ") ("∫" . "\\int ") ("∏" . "\\prod ")
    ("→" . "\\to ") ("∈" . "\\in ") ("∂" . "\\partial ")
    ("⁡" . "") ("⁢" . "")))
(defun lc-mathml-token (text)
  (mapconcat (lambda (char)
               (let ((s (char-to-string char)))
                 (or (cdr (assoc s lc-mathml-symbols)) (lc-mathml-escape s)))) text ""))
(defun lc-mathml-delimiter (text)
  (cond ((equal text "") ".") ((equal text "{") "\\{") ((equal text "}") "\\}")
        ((member text '("(" ")" "[" "]" "|")) text) (t ".")))
(defun lc-mathml-latex (node)
  "Convert a presentation MathML NODE to safe LaTeX. Pure, no process invocation."
  (if (stringp node) (lc-mathml-token node)
    (let* ((tag (dom-tag node))
           (children (cl-remove-if (lambda (c) (and (stringp c) (string-blank-p c)))
                                   (dom-children node)))
           (parts (mapcar #'lc-mathml-latex children))
           (a (or (nth 0 parts) "")) (b (or (nth 1 parts) "")) (c (or (nth 2 parts) "")))
      (pcase tag
        ((or 'mi 'mn 'mo) (lc-mathml-token (dom-texts node)))
        ((or 'math 'mrow 'mstyle 'mtd 'mpadded 'mphantom) (mapconcat #'identity parts ""))
        ('semantics (lc-mathml-latex (car children)))
        ((or 'annotation 'annotation-xml 'none 'mprescripts) "")
        ((or 'mtext 'ms) (concat "\\text{" (lc-mathml-escape (dom-texts node)) "}"))
        ('mspace "\\, ")
        ('mfrac (format "\\frac{%s}{%s}" a b))
        ('msqrt (concat "\\sqrt{" (mapconcat #'identity parts "") "}"))
        ('mroot (format "\\sqrt[%s]{%s}" b a))
        ('msub (format "{%s}_{%s}" a b))
        ('msup (format "{%s}^{%s}" a b))
        ('msubsup (format "{%s}_{%s}^{%s}" a b c))
        ('munder (format "\\underset{%s}{%s}" b a))
        ('mover (format "\\overset{%s}{%s}" b a))
        ('munderover (format "\\underset{%s}{\\overset{%s}{%s}}" b c a))
        ('mfenced (concat "\\left" (lc-mathml-delimiter (or (dom-attr node 'open) "("))
                          (mapconcat #'identity parts (lc-mathml-token (or (dom-attr node 'separators) ",")))
                          "\\right" (lc-mathml-delimiter (or (dom-attr node 'close) ")"))))
        ('mtable (concat "\\begin{matrix}" (mapconcat #'identity parts "\\\\") "\\end{matrix}"))
        ('mtr (mapconcat #'identity parts " & "))
        ('mlabeledtr (mapconcat #'identity (cdr parts) " & "))
        (_ (mapconcat #'identity parts ""))))))
(defun shr-tag-mathml--convert-to-latex (node) (insert (lc-mathml-latex node)))
(defun lc-shr-math (math)
  "Insert MathML source fallback and asynchronously overlay its Org-rendered image."
  (let* ((beg (point)) (display (equal (dom-attr math 'display) "block"))
         (source (concat (if display "\\[" "\\(") (lc-mathml-latex math)
                         (if display "\\]" "\\)"))))
    (insert source)
    (lc-preview-enqueue beg (point) source lc-mathml-process lc-mathml-preamble)))
(with-eval-after-load 'shr
  ;; Register our namespaced handler; shr.el itself defines shr-tag-math in 31.
  ;; Do not replace that native function or rely on which library loads last.
  (setf (alist-get 'math shr-external-rendering-functions) #'lc-shr-math))
(provide 'shr-tag-math)
