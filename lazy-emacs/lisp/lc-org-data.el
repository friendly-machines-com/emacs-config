;;; lisp/lc-org-data.el --- Retained definitions/data -*- lexical-binding: t; -*-
(require 'lc-core)
(defun transform-square-brackets-to-round-ones (string-to-transform)
  "Convert `[' into `(' and `]' into `)' of STRING-TO-TRANSFORM.  That's especially for arxiv."
  (concat
   (mapcar #'(lambda (c) (if (equal c 91) 40 (if (equal c 93) 41 c)))
	   string-to-transform)))

(defun air-org-skip-subtree-if-priority (priority)
  "Skip an agenda subtree if it has a priority of PRIORITY.\n\n  PRIORITY may be one of the characters ?A, ?B, or ?C."
  (let
      ((subtree-end (save-excursion (org-end-of-subtree t)))
       (pri-value (* 1000 (- org-lowest-priority priority)))
       (pri-current (org-get-priority (thing-at-point 'line t))))
    (if (= pri-value pri-current) subtree-end nil)))

(provide 'lc-org-data)
