;;; unbreak.el --- Missing menu entries without eager package loading -*- lexical-binding: t; -*-
;; Replaces the original local menu discovery helper; no debug printing or singleton toolbar spam.
(require 'cl-lib)
(require 'seq)
(defgroup unbreak nil "Discover commands omitted from package menus." :group 'convenience)
(defcustom unbreak-keybound-only t "Discover public commands bound in the current context."
  :type 'boolean :group 'unbreak)
(defcustom unbreak-excluded-prefixes
  '("menu" "mouse" "self" "keyboard" "undefined" "pgtk" "scroll" "forward"
    "backward" "next" "previous" "beginning" "end" "window" "frame" "handle"
    "insert" "delete" "kill" "yank" "copy" "undo" "cua" "mwheel" "digit"
    "negative" "universal" "gptel" "xenops" "ebdb" "kiwix" "mcphas")
  "Prefixes with native editing affordances, or deliberately removed integrations."
  :type '(repeat string) :group 'unbreak)
(defvar unbreak--generation 0)
(defvar unbreak--building nil
  "Non-nil while this menu's own key-binding queries are in progress.")
(defvar-local unbreak--cache nil)
(defun unbreak--changed (&rest _) (cl-incf unbreak--generation))
(defun unbreak--native-menu-p (command)
  (seq-some (lambda (key)
              (and (vectorp key) (> (length key) 0) (eq (aref key 0) 'menu-bar)
                   (not (eq (and (> (length key) 1) (aref key 1)) 'lc-unbreak))))
            (where-is-internal command nil nil nil)))
(defun unbreak--build ()
  (let ((groups (make-hash-table :test #'equal)) (menu (make-sparse-keymap "Commands")))
    (mapatoms
     (lambda (command)
       (let* ((name (symbol-name command)) (prefix (car (split-string name "-"))))
         (when (and (commandp command) (not (string-match-p "--" name))
                    (not (member prefix unbreak-excluded-prefixes))
                    (or (not unbreak-keybound-only) (where-is-internal command nil t))
                    (not (unbreak--native-menu-p command)))
           (push command (gethash prefix groups))))))
    (dolist (prefix (sort (hash-table-keys groups) #'string-lessp))
      (let ((group (make-sparse-keymap prefix)))
        (dolist (command (sort (gethash prefix groups)
                              (lambda (a b) (string-lessp (symbol-name a) (symbol-name b)))))
          (let ((name (symbol-name command)))
            (define-key group (vector command)
              `(menu-item ,(capitalize (replace-regexp-in-string "-" " " name))
                          ,command :help ,(concat "Run " name)))))
        (define-key menu (vector (intern prefix)) (cons (capitalize prefix) group))))
    menu))
(defun unbreak--filter (_)
  "Build only when a menu is opened in a new package/mode context."
  ;; where-is-internal traverses menus and can invoke this filter again. Our
  ;; incomplete menu must not recursively trigger another scan of every command.
  (if unbreak--building (make-sparse-keymap)
    (let ((stamp (list unbreak--generation major-mode)) (unbreak--building t))
      (unless (equal stamp (car-safe unbreak--cache))
        (setq unbreak--cache (cons stamp (unbreak--build))))
      (cdr unbreak--cache))))
;;;###autoload
(defun unbreak ()
  "Enable/refresh a Commands menu for missing package actions.
Autoloaded commands remain autoloaded; discovery never executes them."
  (interactive)
  (unbreak--changed)
  (define-key global-map [menu-bar lc-unbreak]
    '(menu-item "Commands" ignore :filter unbreak--filter))
  (force-mode-line-update t))
(defun find-single-word-commands ()
  "Display public commands with no hyphen."
  (interactive)
  (let (commands)
    (mapatoms (lambda (s) (when (and (commandp s) (not (string-match-p "-" (symbol-name s))))
                           (push (symbol-name s) commands))))
    (with-help-window "*Single Word Commands*"
      (princ (mapconcat #'identity (sort commands #'string-lessp) "\n")))))
(add-hook 'after-load-functions #'unbreak--changed)
(provide 'unbreak)
