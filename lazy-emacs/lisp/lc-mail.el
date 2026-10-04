;;; lc-mail.el --- Shared MIME, lazy mu4e email and Gnus news -*- lexical-binding: t; -*-
(require 'lc-core)
(require 'lc-ui)
(require 'use-package)
(defgroup lc-mail nil "Mail identity, folders and sync." :group 'lazy-config)
(defun lc-mail-setting-set (symbol value)
  (set-default symbol value)
  (when (featurep 'mu4e-context)
    (lc-mail-context)
    ;; The documented switch command reapplies the rebuilt account's variables.
    (when (mu4e-context-current) (mu4e-context-switch t "friendly-machines.com"))))
(defcustom lc-mail-address "dannym@friendly-machines.com" "Sender identity."
  :type 'string :set #'lc-mail-setting-set :group 'lc-mail)
(defcustom lc-mail-root (lc-home-file "Mail")
  "Maildir used to initialize the isolated mu index. Existing indexes own their maildir."
  :type 'directory :group 'lc-mail)
(defcustom lc-mail-sync-command
  (concat (shell-quote-argument (lc-home-file "src/jma-mail/jma-mail/target/release/jma")) " sync")
  "Command invoked only by the active mu4e service."
  :type 'string :set #'lc-mail-setting-set :group 'lc-mail)
(defcustom lc-mail-shortcuts
  '(("/friendly-machines.com/INBOX" . ?i) ("/friendly-machines.com/Sent" . ?s)
    ("/friendly-machines.com/Trash" . ?t) ("/friendly-machines.com/Archive" . ?a)
    ("/friendly-machines.com/Drafts" . ?d) ("/friendly-machines.com/Hobby/Shellbox" . ?b)
    ("/friendly-machines.com/Work/Friendly_Machines" . ?f)
    ("/friendly-machines.com/Work/Guix/Devel" . ?g) ("/friendly-machines.com/Work/Guix/Patches" . ?h)
    ("/friendly-machines.com/Work/Physics" . ?p) ("/friendly-machines.com/Work/TU_Tieftemperatur" . ?u)
    ("/friendly-machines.com/Work/Oxide" . ?x))
  "Distinct folder shortcut keys; Archive is authoritative."
  :type '(alist :key-type string :value-type character) :set #'lc-mail-setting-set :group 'lc-mail)
(defcustom lc-mail-smtp-settings
  '((smtpmail-smtp-server . "smtp.dreamhost.com") (smtpmail-stream-type . starttls)
    (smtpmail-smtp-service . 587) (smtpmail-auth-supported . (plain login))
    (smtpmail-always-send-ehlo . t) (smtpmail-authenticate-always . t)
    (smtpmail-require-credentials . t))
  "SMTP settings passed to the account context; credentials remain in auth-source."
  :type '(alist :key-type symbol :value-type sexp) :set #'lc-mail-setting-set :group 'lc-mail)
(defun lc-mail-context ()
  "Rebuild the named context from Customize-controlled preferences."
  (require 'mu4e-context)
  (setq mu4e-contexts
        (list
         (make-mu4e-context
          :name "friendly-machines.com"
          :enter-func (lambda () (mu4e-message "Entering friendly-machines.com context"))
          :leave-func (lambda () (mu4e-message "Leaving friendly-machines.com context"))
          :match-func (lambda (message)
                        (and message (mu4e-message-contact-field-matches
                                      message '(:from :to :cc :bcc) lc-mail-address)))
          :vars (append `((user-mail-address . ,lc-mail-address)
                          (smtpmail-smtp-user . ,lc-mail-address)
                          (send-mail-function . smtpmail-send-it)
                          (message-send-mail-function . smtpmail-send-it)
                          (mu4e-sent-messages-behavior . sent)
                          (mu4e-sent-folder . "/friendly-machines.com/Sent")
                          (mu4e-drafts-folder . "/friendly-machines.com/Drafts")
                          (mu4e-trash-folder . "/friendly-machines.com/Trash")
                          (mu4e-refile-folder . "/friendly-machines.com/Archive")
                          (mu4e-get-mail-command . ,lc-mail-sync-command)
                          (mu4e-maildir-shortcuts . ,lc-mail-shortcuts))
                        lc-mail-smtp-settings)))))
(use-package auth-source :ensure nil :defer t
  :config (setq auth-sources (list lc-authinfo-file)))
(autoload 'smtpmail-send-it "smtpmail")
;; Guix autoloads normally define this user agent; this declaration also supports source testing.
(autoload 'mu4e-user-agent "mu4e" nil t)
(use-package mu4e :ensure nil :commands (mu4e mu4e-compose-new mu4e-user-agent)
  :config
  (lc-mail-context)
  (setq mu4e-get-mail-command lc-mail-sync-command)
  (require 'lc-mathml)
  (dolist (hook '(mu4e-view-mode-hook mu4e-headers-mode-hook mu4e-compose-mode-hook))
    (add-hook hook #'lc-buffer-toolbar 95)))
(defun lc-mail-initialize-index ()
  "Initialize and asynchronously populate this instance's private mu index.
This is an explicit user action. It never reinitializes an existing index and
never syncs/sends mail. Maildir contents are read; the index is written under state/."
  (interactive)
  (lc-require 'mu4e)
  (unless (file-directory-p lc-mail-root) (user-error "Maildir does not exist: %s" lc-mail-root))
  (let* ((program (or (executable-find "mu") (user-error "Install the Guix mu package")))
         (directory (or mu4e-mu-home (user-error "Set mu4e-mu-home to an isolated directory")))
         (buffer (get-buffer-create "*Mail index setup*")))
    (when (file-exists-p (expand-file-name "xapian" directory))
      (user-error "Index already exists at %s; use mu4e's update command" directory))
    (make-directory directory t)
    (with-current-buffer buffer (let ((inhibit-read-only t)) (erase-buffer)) (special-mode))
    (unless (zerop (with-current-buffer buffer
                    (let ((inhibit-read-only t))
                      (call-process program nil buffer nil "init" "--muhome" directory
                                    "--maildir" lc-mail-root "--my-address" lc-mail-address))))
      (pop-to-buffer buffer) (user-error "mu init failed; see Mail index setup"))
    (make-process :name "lazy-mail-index" :buffer buffer :noquery t
                  :command (list program "index" "--muhome" directory)
                  :filter (lambda (process text)
                            (when (buffer-live-p (process-buffer process))
                              (with-current-buffer (process-buffer process)
                                (let ((inhibit-read-only t))
                                  (goto-char (point-max)) (insert text)))))
                  :sentinel (lambda (process event)
                              (when (memq (process-status process) '(exit signal))
                                (message "Mail index setup: %s (see *Mail index setup*)" (string-trim event)))))
    (pop-to-buffer buffer)))
(defun lc-message-setup ()
  (auto-fill-mode -1) (setq-local line-move-visual nil)
  (lc-buffer-toolbar))
(add-hook 'message-mode-hook #'lc-message-setup 90)
(use-package gnus :ensure nil :commands gnus
  :config (require 'lc-news))
(use-package bug-reference :ensure nil
  :hook ((gnus-summary-mode gnus-article-mode) . bug-reference-mode)
  :config
  (add-to-list 'bug-reference-setup-from-mail-alist
               '("Guix" nil "\\b\\(bug#\\([0-9]+\\)\\)\\b" "https://debbugs.gnu.org/%s")))
(use-package debbugs :ensure nil :commands (debbugs-gnu debbugs-org)
  :hook ((bug-reference-mode bug-reference-prog-mode) . debbugs-browse-mode)
  :config
  (easy-menu-define lc-debbugs-menu debbugs-org-mode-map "Bug control actions"
    '("Debbugs" ["Change bug status..." debbugs-gnu-send-control-message t]
      ["Display bug status" debbugs-gnu-display-status t])))
(defun lc-news-article-keys ()
  (unless (derived-mode-p 'mu4e-view-mode)
    (keymap-local-set "i" #'gnus-article-show-images)
    (keymap-local-set "s" #'gnus-mime-save-part)
    (keymap-local-set "o" #'gnus-mime-copy-part)))
(add-hook 'gnus-article-mode-hook #'lc-news-article-keys)
(defun lc-mail-commit-marks () (interactive) (call-interactively #'mu4e-mark-execute-all))
(lc-register-actions '((compose "Compose" compose-mail "mail/compose")
                  (reply-all "Reply all" mu4e-compose-wide-reply "mail/reply-all")
                  (reply "Reply" mu4e-compose-reply "mail/reply")
                  (forward "Forward" mu4e-compose-forward "mail/forward")
                  (move "Move" mu4e-headers-mark-for-move "mail/move")
                  (flag "Flag" mu4e-headers-mark-for-flag "mail/flag-for-followup")
                  (trash "Trash" mu4e-headers-mark-for-trash "delete")
                  (execute "Commit marks" lc-mail-commit-marks "mpc/play")
                  (previous "Previous" mu4e-headers-prev "left-arrow")
                  (next "Next" mu4e-headers-next "right-arrow")
                  (refresh "Refresh" mu4e-headers-rerun-search "refresh")
                  (attach "Attach" mml-attach-file "attach") (spell "Spell" ispell-message "spell")
                  (sign "Sign" mml-secure-message-sign "lock")
                  (encrypt "Encrypt" mml-secure-message-encrypt "locked-encrypted")
                  (send "Send" message-send-and-exit "gnus/mail-send")
                  (discard-draft "Discard" message-kill-buffer "gnus/kill-group")
                  (news-post "Post" gnus-summary-post-news "mail/compose")
                  (news-reply-all "Reply all" gnus-summary-wide-reply "mail/reply-all")
                  (news-reply "Reply" gnus-summary-reply "mail/reply")
                  (news-forward "Forward" gnus-summary-post-forward "mail/forward")
                  (verify "Verify" gnus-summary-force-verify-and-decrypt "ezimage/key")))
(provide 'lc-mail)
