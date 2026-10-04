;;; lc-projects.el --- Projects, environment inheritance and Git entry points -*- lexical-binding: t; -*-
(require 'lc-core)
(require 'lc-ui)
(require 'use-package)
(use-package buffer-env :ensure nil :commands buffer-env-update
  :hook ((hack-local-variables comint-mode) . buffer-env-update)
  :config
  (setq buffer-env-script-name '("environment-variables" ".env" ".envrc"))
  (add-to-list 'buffer-env-command-alist
               '("environment-variables" . "set -a; . \"$0\"; set +a; env -0")))
;; Core lookup must not follow HOME mutations in project process-environment.
(unless (advice-member-p #'lc-global-env-call 'locate-user-emacs-file)
  (advice-add 'locate-user-emacs-file :around #'lc-global-env-call))
;; Keep REPL commands as program names (see defaults.el), so ordinary process
;; lookup uses the current buffer's exec-path/environment at launch time. Do not
;; freeze them to a previous environment's absolute executable, overwrite user
;; choices after an update, or patch envrc internals (0.15 has no update hook).
(use-package projectile :ensure nil
  :commands (projectile-mode projectile-compile-project projectile-run-project projectile-test-project)
  :bind (("<f9>" . projectile-compile-project) ("C-<f9>" . projectile-run-project)
         ("C-S-<f9>" . projectile-test-project) ("M-<f9>" . compile))
  :config
  (projectile-register-project-type 'npm '("package.json") :compile "npm run build" :test "npm test" :run "npm start")
  (projectile-register-project-type 'rails-rspec '("Gemfile" "app" "lib" "db" "config" "spec")
                                    :run "rails server" :test "rspec")
  (projectile-register-project-type 'dub '("dub.json") :compile "dub build" :run "dub run" :test "dub test"))
(defun lc-project-tracking ()
  (when (require 'projectile nil t) (projectile-mode 1))
  (when (require 'back-button nil t) (when (fboundp 'back-button-mode) (back-button-mode 1))))
(add-hook 'find-file-hook #'lc-project-tracking)
(use-package back-button :ensure nil
  :bind (("<mouse-8>" . back-button-global-backward) ("<mouse-9>" . back-button-global-forward)
         ("M-<left>" . back-button-global-backward) ("M-<right>" . back-button-global-forward)))
(use-package treemacs :ensure nil :commands (treemacs treemacs-select-window)
  :config
  (keymap-set treemacs-mode-map "<mouse-1>" #'treemacs-single-click-expand-action)
  (treemacs-display-current-project-exclusively))
(use-package treemacs-projectile :ensure nil :after (treemacs projectile) :demand t)
(use-package treemacs-nerd-icons :ensure nil :after treemacs :demand t
  :config (treemacs-load-theme "nerd-icons"))
(use-package lsp-treemacs :ensure nil :commands lsp-treemacs-symbols)
(use-package magit :ensure nil :commands (magit-status magit-stage-region magit-commit)
  :config
  (dolist (map (list magit-mode-map magit-section-mode-map magit-diff-section-map magit-hunk-section-map))
    (when-let* ((prefix (lookup-key map (kbd "C-c"))))
      (define-key map (kbd "C-d") prefix) (define-key map (kbd "C-c") nil)))
  (setq magit-save-repository-buffers t)
  (add-hook 'after-save-hook #'magit-after-save-refresh-status t))
(use-package forge :ensure nil :after magit :demand t)
(use-package git-rebase :ensure nil :mode ("git-rebase-todo\\'" . git-rebase-mode))
(use-package pr-review :ensure nil :commands pr-review)
(defun mes/pr-review-via-forge ()
  (interactive) (lc-require 'forge) (lc-require 'pr-review)
  (if-let* ((target (forge--browse-target))
            (url (if (stringp target) target (forge-get-url target)))
            (_ (pr-review-url-parse url)))
      (pr-review url) (user-error "No PR to review at point")))
(use-package fj :ensure nil :commands (fj-list-issues fj-list-pulls)
  :config
  (setq fj-host "https://codeberg.org" fj-user "daym")
  (require 'auth-source)
  (setq fj-token (auth-source-pick-first-password :host "codeberg.org/api/v1" :user fj-user)))
(autoload 'lc-generate-guix-commit "lc-git-commit" nil nil)
(add-hook 'git-commit-setup-hook #'lc-generate-guix-commit)
(autoload 'guix-normalize-and-open-build-dir "lc-guix-build" nil t)
(autoload 'guix-ensure-drv-0-directory "lc-guix-build" nil t)
(with-eval-after-load 'compile
  (require 'ansi-color)
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)
  (require 'lc-guix-build))
(use-package guix :ensure nil :commands guix :bind ("s-g" . guix)
  :config
  (let ((copyright (lc-home-file "src/guix/etc/copyright.el")))
    (when (file-readable-p copyright) (load copyright nil t))))
(with-eval-after-load 'prog-mode
  (keymap-set prog-mode-map "C-c s" #'magit-stage-region)
  (keymap-set prog-mode-map "C-c c" #'magit-commit))
(lc-action 'magit "Git" #'magit-status "magit" "Git status")
(lc-register-actions '((git-fetch "Fetch" magit-fetch "refresh") (git-pull "Pull" magit-pull "custom/down")
                  (git-push "Push" magit-push "up-arrow") (git-commit "Commit" magit-commit "data-save")))
(lc-register-actions
 '((pick "Pick" git-rebase-pick "checked") (drop "Drop" git-rebase-drop "delete")
   (reword "Reword" git-rebase-reword "describe") (edit "Edit" git-rebase-edit "mail/flag-for-followup")
   (squash "Squash" git-rebase-squash "spell") (fixup "Fixup" git-rebase-fixup "attach")
   (kill-commit "Kill" git-rebase-kill-line "delete") (noop "Noop" git-rebase-noop "mail/not-spam")
   (exec "Execute" git-rebase-exec "index") (up "Move up" git-rebase-move-line-up "up-arrow")
   (down "Move down" git-rebase-move-line-down "down-arrow")
   (cancel "Cancel" with-editor-cancel "cancel") (finish "Finish" with-editor-finish "save")))
(provide 'lc-projects)
