;;; unbreak.el --- Missing menu entries without eager package loading -*- lexical-binding: t; -*-
;; Replaces the original local menu discovery helper; no debug printing or singleton toolbar spam.
(require 'cl-lib)
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
(defun unbreak--collect (map seen out)
    "Add commands bound in MAP to OUT, walking each keymap in SEEN only once.
Menu-item bindings contribute their command; sub-keymaps, including
old-style (LABEL . KEYMAP) submenus, are walked."
    (when (keymapp map)
      (unless (gethash map seen)
        (puthash map t seen)
        (map-keymap
         (lambda (_event binding)
           (cond
            ((keymapp binding)
             (unbreak--collect binding seen out))
            ((and (consp binding) (eq (car binding) 'menu-item))
             (let ((command (nth 2 binding)))
               (cond ((and (symbolp command) (commandp command))
                      (puthash command t out))
                     ((keymapp command)
                      (unbreak--collect command seen out)))))
            ;; Old-style submenu: (LABEL . KEYMAP).
            ((and (consp binding) (keymapp (cdr binding)))
             (unbreak--collect (cdr binding) seen out))
            ((and (symbolp binding) (commandp binding))
             (puthash binding t out))))
         map))))
(defun unbreak--commands (maps menubar-only)
  "Commands bound in MAPS, or only those in their menu-bar submenus."
  (let ((seen (make-hash-table :test #'eq))
        (out (make-hash-table :test #'eq)))
    (dolist (map maps)
      (unbreak--collect (if menubar-only (lookup-key map [menu-bar]) map)
                        seen out))
    out))
(defun unbreak--all-commands ()
  (let ((out (make-hash-table :test #'eq)))
    (mapatoms (lambda (symbol)
                (when (commandp symbol) (puthash symbol t out))))
    out))
(defun unbreak--build ()
  "Build the Commands menu for the current context.
Walking the active keymaps and their menu-bar submenus avoids calling
`where-is-internal' for every interned symbol.  The old version scanned
~30k symbols per redisplay, taking ~0.19 s and causing a GC; this takes
~0.014 s, so it can run in the menu filter without deferring anything."
  (let* ((maps (current-active-maps))
         (native (unbreak--commands maps t))
         (commands (if unbreak-keybound-only
                       (unbreak--commands maps nil)
                     (unbreak--all-commands)))
         (groups (make-hash-table :test #'equal))
         (menu (make-sparse-keymap "Commands")))
    (maphash
     (lambda (command _)
       (let* ((name (symbol-name command)) (prefix (car (split-string name "-"))))
         (when (and (commandp command) (not (string-match-p "--" name))
                    (not (member prefix unbreak-excluded-prefixes))
                    (not (gethash command native)))
           (push command (gethash prefix groups)))))
     commands)
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
