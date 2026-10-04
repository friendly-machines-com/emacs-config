;;; lc-agents.el --- Contained coding agents and local Org math -*- lexical-binding: t; -*-
(require 'lc-core)
(require 'lc-ui)
(require 'use-package)
(use-package agent-shell :ensure nil :commands (agent-shell agent-shell-switch-buffer)
  :config
  (require 'agent-shell-loki)
  (require 'agent-shell-org-math)
  (add-to-list 'agent-shell-agent-configs #'agent-shell-loki-make-agent-config)
  (add-hook 'agent-shell-mode-hook #'agent-shell-org-math-mode)
  (easy-menu-define lc-agent-menu agent-shell-mode-map "Agent controls"
    '("Agent"
      ["Stop current turn/jobs" agent-shell-interrupt t]
      ["Kill exposed subprocess at point" lc-agent-kill-process
       (let ((process (get-text-property (point) 'agent-shell-process)))
         (and (processp process) (process-live-p process)))]
      ["Pending permission" agent-shell-jump-to-latest-permission-button-row t]
      ("Tool calls" ["Next" agent-shell-ui-forward-block t] ["Previous" agent-shell-ui-backward-block t])
      ("Sessions" ["Switch..." agent-shell-switch-buffer t] ["New..." agent-shell t]
       ["List processes" list-processes t])
      ["Clear transcript" agent-shell-clear-buffer t])))
(defun agent-shell-loki-start-agent ()
  "Load the public agent command before entering the Loki adapter.
The provider subsequently supplies its normal interactive entry point."
  (interactive)
  (lc-require 'agent-shell)
  (lc-require 'agent-shell-loki)
  (call-interactively #'agent-shell-loki-start-agent))
(defun lc-agent-kill-process ()
  "Kill an exposed subprocess, never guess and accidentally kill the ACP session."
  (interactive)
  (let ((process (get-text-property (point) 'agent-shell-process)))
    (unless (and (processp process) (process-live-p process))
      (user-error "No exposed tool subprocess at point; use Stop turn or List processes"))
    (delete-process process)))
(lc-register-actions
 '((agent-stop "Stop all" agent-shell-interrupt "cancel")
   (agent-pending "Pending action" agent-shell-jump-to-latest-permission-button-row "jump-to")
   (agent-prev "Previous tool" agent-shell-ui-backward-block "up-arrow")
   (agent-next "Next tool" agent-shell-ui-forward-block "down-arrow")
   (agent-switch "Switch agent" agent-shell-switch-buffer "refresh")
   (agent-new "New agent" agent-shell "new")))
(lc-action 'agent-kill "Kill process" #'lc-agent-kill-process "delete"
           "Kill only an exposed subprocess, never guess the session process"
           :enable '(let ((process (get-text-property (point) 'agent-shell-process)))
                      (and (processp process) (process-live-p process))))
(provide 'lc-agents)
