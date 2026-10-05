;;; agent-shell-loki.el --- Loki coding agent configurations -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Alvaro Ramirez

;; Author: Alvaro Ramirez https://xenodium.com
;; URL: https://github.com/xenodium/agent-shell

;; This package is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This package is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This file includes Loki coding agent-specific configurations.
;;
;; This integration requires the loki-acp adapter to be installed.
;;

;;; Code:

(eval-when-compile
  (require 'cl-lib))
(require 'shell-maker)
(require 'acp)

(declare-function agent-shell--indent-string "agent-shell")
(declare-function agent-shell-make-agent-config "agent-shell")
(autoload 'agent-shell-make-agent-config "agent-shell")
(declare-function agent-shell--make-acp-client "agent-shell")
(declare-function agent-shell--dwim "agent-shell")

(defcustom agent-shell-loki-acp-command
  '("loki-acp")
  "Command and parameters for the Loki ACP client.

The first element is the command name, and the rest are command parameters.

Loki requires the loki-acp adapter for ACP integration."
  :type '(repeat string)
  :group 'agent-shell)

(defcustom agent-shell-loki-environment
  nil
  "Environment variables for the Loki client.

This should be a list of environment variables to be used when
starting the Loki client process.

Example usage to set custom environment variables:

  (setq agent-shell-loki-environment
        (`agent-shell-make-environment-variables'
         \"ANTHROPIC_API_KEY\" \"your-key\"
         \"PI_CODING_AGENT_DIR\" \"~/.pi/agent\"))"
  :type '(repeat string)
  :group 'agent-shell)

(defun agent-shell-loki-make-agent-config ()
  "Create a Loki coding agent configuration.

Returns an agent configuration alist using `agent-shell-make-agent-config'."
  (agent-shell-make-agent-config
   :identifier 'loki
   :mode-line-name "Loki"
   :buffer-name "Loki"
   :shell-prompt "Loki> "
   :shell-prompt-regexp "Loki> "
   :icon-name "loki.png"
   :welcome-function #'agent-shell-loki--welcome-message
   :client-maker (lambda (buffer)
                   (agent-shell-loki-make-client :buffer buffer))
   :install-instructions "See Loki installation.
Requires loki-acp adapter for ACP integration."))

;;;###autoload
(defun agent-shell-loki-start-agent ()
  "Start an interactive Loki coding agent shell."
  (interactive)
  (agent-shell--dwim :config (agent-shell-loki-make-agent-config)
                     :new-shell t))

(require 'auth-source)
;(require 'auth-source-pass)  ;; if using pass/passage

(defun my/loki-process-environment ()
  (delq nil
        (mapcar
         (lambda (var)
           (when-let ((val (auth-source-pick-first-password :host var)))
             (format "%s=%s" var val)))
         '("OPENAI_API_KEY"
           "ANTHROPIC_API_KEY"
           "GROQ_API_KEY"
           "OPENCODE_API_KEY"
           "ZHIPU_API_KEY"))))

(cl-defun agent-shell-loki-make-client (&key buffer)
  "Create a Loki client using BUFFER as context."
  (unless buffer
    (error "Missing required argument: :buffer"))
  (when (and (boundp 'agent-shell-loki-command) agent-shell-loki-command)
    (user-error "Please migrate to use agent-shell-loki-acp-command and eval (setq agent-shell-loki-command nil)"))
  (agent-shell--make-acp-client :command (car agent-shell-loki-acp-command)
                                :command-params (cdr agent-shell-loki-acp-command)
                                :environment-variables (append (my/loki-process-environment) agent-shell-loki-environment)
                                :context-buffer buffer))

(defun agent-shell-loki--welcome-message (config)
  "Return Loki welcome message using `shell-maker' CONFIG."
  (let ((art (agent-shell--indent-string 4 (agent-shell-loki--ascii-art)))
        (message (string-trim-left (shell-maker-welcome-message config) "\n")))
    (concat "\n\n"
            art
            "\n\n"
            message)))

(defun agent-shell-loki--ascii-art ()
  "Loki ASCII art."
  (let* ((is-dark (eq (frame-parameter nil 'background-mode) 'dark))
         (text (string-trim "
        ████        ████
         ████      ████
          ████    ████
         ██████████████
        ████████████████
        ████        ████
        ████        ████
" "\n")))
    (propertize text 'font-lock-face (if is-dark
                                         '(:foreground "#ffffff" :inherit fixed-pitch)
                                       '(:foreground "#000000" :inherit fixed-pitch)))))

(provide 'agent-shell-loki)

;;; agent-shell-loki.el ends here
