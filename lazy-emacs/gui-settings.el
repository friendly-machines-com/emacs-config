;;; gui-settings.el --- Emacs-managed Customize output -*- lexical-binding: t; -*-
;; Imported by reading, never evaluating, the previous configuration's files.
;; This is the only settings file; M-x customize owns it from here on.
(custom-set-variables
 '(LaTeX-command "lualatex")
 '(LaTeX-electric-left-right-brace t)
 '(TeX-electric-sub-and-superscript t)
 '(TeX-engine 'luatex)
 '(agent-shell-header-style 'text)
 '(agent-shell-preferred-agent-config '(preselect . loki))
 '(agent-shell-session-restore-verbosity 'full)
 '(ansi-color-for-compilation-mode t)
 '(auth-source-save-behavior nil)
 '(back-button-no-wrap t)
 '(backup-by-copying t)
 '(backup-directory-alist (list (cons "." (lc-home-file "backup/"))))
 '(buffer-env-safe-files
 '(("/home/dannym/src/agent-c/e/rune-os/kernel/manifest.scm"
    . "56b5c94b285f1b8d64ebe7a71d065624543a0756cd64475daba8e9eff492de8c")
   ("/home/dannym/src/agent-c/e/7d/manifest.scm"
    . "a188b054069db09895e96ab758b6c04f2b48b86764c07a870d78207713917f6e")
   ("/home/dannym/src/guix-dev86/manifest.scm"
    . "0b387290e9851813debd81b6e3aa5099f0f17fad1fade821ca1f0928262e56c4")
   ("/home/dannym/src/agent-c/e/fast-lisp-rs/manifest.scm"
    . "a188b054069db09895e96ab758b6c04f2b48b86764c07a870d78207713917f6e")
   ("/home/dannym/src/claude-code/e/rune-os/kernel/manifest.scm"
    . "14c251e231894b6a8a2be77b9fca309eb339a1ee3ec2db153e67f5bdce8d4d73")
   ("/home/dannym/src/mcphas/manifest.scm"
    . "b8553849cd30c15f7ef9236e07b8582fdf58d875a3b6703505f5dfa30b6c8d40")
   ("/home/dannym/src/mcphas/manifest.scm"
    . "06fb17415d5503d1813a605c3914f3b5ed7daa0f9f375db0eccee0e997f9a802")
   ("/home/dannym/src/guix/manifest.scm"
    . "0b387290e9851813debd81b6e3aa5099f0f17fad1fade821ca1f0928262e56c4")
   ("/home/dannym/src/latex-ex/manifest.scm"
    . "5200b8ce405410acc7ad0e4baf5bfaa85b0160bff5815265a305bdc9a7fb70ed")))
 '(code-cells-convert-ipynb-style
 '(("pandoc" "--to" "ipynb" "--from" "org")
   ("pandoc" "--to" "org" "--from" "ipynb") (lambda nil #'org-mode)))
 '(column-number-mode t)
 '(company-idle-delay 0.5)
 '(compilation-scroll-output t)
 '(completion-category-defaults nil)
 '(completion-category-overrides
 '((file (styles basic partial-completion))))
 '(completion-styles '(orderless basic))
 '(consult-narrow-key "<")
 '(cua-auto-tabify-rectangles nil)
 '(cua-keep-region-after-copy t)
 '(dap-python-debugger 'debugpy)
 '(debbugs-browse-url-regexp
 "^https?://\\(debbugs\\.gnu\\.org\\|bugs\\.gnu\\.org\\|issues.guix.gnu.org\\)/\\(cgi/bugreport\\.cgi\\?bug=\\)?\\([[:digit:]]+\\)$")
 '(delete-by-moving-to-trash t)
 '(delete-old-versions t)
 '(dired-listing-switches "-alot --si")
 '(dired-launch-extensions-map '(("xlsx" ("libreoffice")) ("odt" ("libreoffice" "abiword"))) t)
 '(dirvish-attributes
 '(vc-state subtree-state nerd-icons collapse git-msg file-time
	    file-size))
 '(doc-view-resolution 300)
 '(eat-term-name "xterm-256color")
 '(el-job--debug-level 1)
 '(elfeed-feeds
 '("https://the-dam.org/rss.xml"
   ("http://planet.emacslife.com/atom.xml" emacs)
   "https://lwn.net/headlines/rss"
   "https://subscribe.fivefilters.org/?url=http%3A%2F%2Fftr.fivefilters.net%2Fmakefulltextfeed.php%3Furl%3Dhttps%253A%252F%252Fhnrss.org%252Ffrontpage%26max%3D3%26links%3Dpreserve"
   "https://subscribe.fivefilters.org/?url=http%3A%2F%2Fftr.fivefilters.net%2Fmakefulltextfeed.php%3Furl%3Dhttps%253A%252F%252Fwww.nature.com%252Fnmat%252Fcurrent_issue%252Frss%252F%26max%3D3%26links%3Dpreserve"
   "https://subscribe.fivefilters.org/?url=http%3A%2F%2Fftr.fivefilters.net%2Fmakefulltextfeed.php%3Furl%3Dhttps%253A%252F%252Fwww.nature.com%252Fnphys%252Fcurrent_issue%252Frss%252F%26max%3D3%26links%3Dpreserve"
   "https://semianalysis.substack.com/feed"
   "https://slow-journalism.com/blog/feed"
   "http://ftr.fivefilters.net/makefulltextfeed.php?url=https%3A%2F%2Ffeeds.arstechnica.com%2Farstechnica%2Ffeatures&max=3"))
 '(epa-pinentry-mode 'loopback)
 '(eshell-hist-ignoredups t)
 '(eshell-history-size 100000)
 '(eshell-save-history-on-exit t)
 '(flymake-indicator-type 'margins)
 '(flymake-margin-indicators-string
 '((error "!" compilation-error) (warning "?" compilation-warning)
   (note "i" compilation-info)))
 '(flymake-show-diagnostics-at-end-of-line t)
 '(format-all-debug nil)
 '(format-all-show-errors 'errors)
 '(frame-background-mode 'light)
 '(geiser-mode-auto-p nil)
 '(grep-command "rg -nS --no-heading ")
 '(ignored-local-variable-values
 '((gac-debounce-interval . 5) (gac-automatically-push-p . t)
   (eval with-eval-after-load 'git-commit
	 (add-to-list 'git-commit-trailers "Change-Id"))
   (eval progn (require 'lisp-mode)
	 (defun emacs27-lisp-fill-paragraph (&optional justify)
	   (interactive "P")
	   (or (fill-comment-paragraph justify)
	       (let
		   ((paragraph-start
		     (concat paragraph-start
			     "\\|\\s-*\\([(;\"]\\|\\s-:\\|`(\\|#'(\\)"))
		    (paragraph-separate
		     (concat paragraph-separate "\\|\\s-*\".*[,\\.]$"))
		    (fill-column
		     (if
			 (and
			  (integerp emacs-lisp-docstring-fill-column)
			  (derived-mode-p 'emacs-lisp-mode))
			 emacs-lisp-docstring-fill-column
		       fill-column)))
		 (fill-paragraph justify))
	       t))
	 (setq-local fill-paragraph-function
		     #'emacs27-lisp-fill-paragraph))
   (geiser-repl-per-project-p . t)
   (eval with-eval-after-load 'yasnippet
	 (let
	     ((guix-yasnippets
	       (expand-file-name "etc/snippets/yas"
				 (locate-dominating-file
				  default-directory ".dir-locals.el"))))
	   (unless (member guix-yasnippets yas-snippet-dirs)
	     (add-to-list 'yas-snippet-dirs guix-yasnippets)
	     (yas-reload-all))))
   (eval with-eval-after-load 'tempel
	 (if (stringp tempel-path)
	     (setq tempel-path (list tempel-path)))
	 (let
	     ((guix-tempel-snippets
	       (concat
		(expand-file-name "etc/snippets/tempel"
				  (locate-dominating-file
				   default-directory ".dir-locals.el"))
		"/*.eld")))
	   (unless (member guix-tempel-snippets tempel-path)
	     (add-to-list 'tempel-path guix-tempel-snippets))))
   (eval setq-local guix-directory
	 (locate-dominating-file default-directory ".dir-locals.el"))
   (eval add-to-list 'completion-ignored-extensions ".go")
   (eval modify-syntax-entry 43 "'") (eval modify-syntax-entry 36 "'")
   (eval modify-syntax-entry 126 "'")
   (geiser-guile-binary "guix" "repl") (geiser-insert-actual-lambda)))
 '(indent-bars-no-descend-lists t)
 '(indent-bars-treesit-ignore-blank-lines-types '("module"))
 '(indent-bars-treesit-scope
 '((python function_definition class_definition for_statement
	   if_statement with_statement while_statement)))
 '(indent-bars-treesit-support t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(jit-lock-defer-time 0.05)
 '(kept-new-versions 6)
 '(kept-old-versions 2)
 '(large-file-warning-threshold 100000000)
 '(lc-guix-authorized-manifests
 '(("/home/dannym/src/agent-c/e/rune-os/kernel/manifest.scm"
    . "56b5c94b285f1b8d64ebe7a71d065624543a0756cd64475daba8e9eff492de8c")
   ("/home/dannym/src/agent-c/e/7d/manifest.scm"
    . "a188b054069db09895e96ab758b6c04f2b48b86764c07a870d78207713917f6e")
   ("/home/dannym/src/guix-dev86/manifest.scm"
    . "0b387290e9851813debd81b6e3aa5099f0f17fad1fade821ca1f0928262e56c4")
   ("/home/dannym/src/agent-c/e/fast-lisp-rs/manifest.scm"
    . "a188b054069db09895e96ab758b6c04f2b48b86764c07a870d78207713917f6e")
   ("/home/dannym/src/claude-code/e/rune-os/kernel/manifest.scm"
    . "14c251e231894b6a8a2be77b9fca309eb339a1ee3ec2db153e67f5bdce8d4d73")
   ("/home/dannym/src/mcphas/manifest.scm"
    . "b8553849cd30c15f7ef9236e07b8582fdf58d875a3b6703505f5dfa30b6c8d40")
   ("/home/dannym/src/mcphas/manifest.scm"
    . "06fb17415d5503d1813a605c3914f3b5ed7daa0f9f375db0eccee0e997f9a802")
   ("/home/dannym/src/guix/manifest.scm"
    . "0b387290e9851813debd81b6e3aa5099f0f17fad1fade821ca1f0928262e56c4")
   ("/home/dannym/src/latex-ex/manifest.scm"
    . "5200b8ce405410acc7ad0e4baf5bfaa85b0160bff5815265a305bdc9a7fb70ed")))
 '(lc-indent-detection t)
 '(line-move-visual nil)
 '(line-spacing 0.2)
 '(lsp-eldoc-render-all t)
 '(lsp-enable-suggest-server-download nil)
 '(lsp-idle-delay 0.6)
 '(lsp-inlay-hint-enable t)
 '(lsp-rust-analyzer-cargo-watch-command "clippy")
 '(lsp-rust-analyzer-display-chaining-hints t)
 '(lsp-rust-analyzer-display-closure-return-type-hints t)
 '(lsp-rust-analyzer-display-lifetime-elision-hints-enable
 "skip_trivial")
 '(lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names
 nil)
 '(lsp-rust-analyzer-display-parameter-hints nil)
 '(lsp-rust-analyzer-display-reborrow-hints nil)
 '(lsp-tex-server 'digestif)
 '(lsp-treemacs-theme "Iconless")
 '(lsp-ui-doc-enable t)
 '(lsp-ui-doc-show-with-mouse t)
 '(lsp-ui-peek-always-show t)
 '(lsp-ui-sideline-show-hover t)
 '(magit-status-file-list-limit 1000)
 '(mediainfo-mode-file-regexp
 "\\.\\(?:3gp\\|a\\(?:iff\\|vi\\)\\|flac\\|jpg\\|jpeg\\|png\\|gif\\|m\\(?:4a\\|kv\\|ov\\|p[34g]\\)\\|o\\(?:gg\\|pus\\)\\|vob\\|w\\(?:av\\|ebm\\|mv\\)\\)\\'")
 '(mouse-autoselect-window t)
 '(mpv-start-timeout 0.5)
 '(mu4e-compose-switch nil)
 '(mu4e-search-results-limit -1)
 '(org-agenda-custom-commands
 '(("d" "Daily agenda and all TODOs"
    ((tags "PRIORITY=\"A\""
	   ((org-agenda-skip-function
	     '(org-agenda-skip-entry-if 'todo 'done))
	    (org-agenda-overriding-header
	     "High-priority unfinished tasks:")))
     (agenda "" ((org-agenda-span 7)))
     (alltodo ""
	      ((org-agenda-skip-function
		'(or (air-org-skip-subtree-if-priority 65)
		     (air-org-skip-subtree-if-priority 67)
		     (org-agenda-skip-if nil '(scheduled deadline))))
	       (org-agenda-overriding-header
		"ALL normal priority tasks:")))
     (tags "PRIORITY=\"C\""
	   ((org-agenda-skip-function
	     '(org-agenda-skip-entry-if 'todo 'done))
	    (org-agenda-overriding-header
	     "Low-priority Unfinished tasks:"))))
    ((org-agenda-compact-blocks nil)))
   ("j" "James's Super View"
    ((agenda "" ((org-agenda-remove-tags t) (org-agenda-span 7)))
     (alltodo ""
	      ((org-agenda-remove-tags t)
	       (org-agenda-prefix-format "  %t  %s")
	       (org-agenda-overriding-header "CURRENT STATUS")
	       (org-super-agenda-groups
		'((:name "Critical Tasks" :tag "CRITICAL" :order 0)
		  (:name "Currently Working" :todo "IN-PROGRESS"
			 :order 1)
		  (:name "Planning Next Steps" :todo "PLANNING" :order
			 2)
		  (:name "Problems & Blockers" :todo "BLOCKED" :tag
			 "obstacle" :order 3)
		  (:name "Tickets to Create" :tag
			 "@write_future_ticket" :order 4)
		  (:name "Research Required" :tag "@research" :order 7)
		  (:name "Meeting Action Items" :and
			 (:tag "meeting" :priority "A") :order 8)
		  (:name "Other Important Items" :and
			 (:todo "TODO" :priority "A" :not
				(:tag "meeting"))
			 :order 9)
		  (:name "General Backlog" :and
			 (:todo "TODO" :priority "B") :order 10)
		  (:name "Non Critical" :priority<= "C" :order 11)
		  (:name "Currently Being Verified" :todo "VERIFYING"
			 :order 20)))))))))
 '(org-agenda-file-regexp "\\`[^.].*\\.org\\'")
 '(org-agenda-files (list (lc-home-file "doc/org-agenda")))
 '(org-agenda-skip-deadline-if-done t)
 '(org-capture-templates
 `
 (("i" "Capture into ID node" plain #'org-node-capture-target
   ,my-org-header :empty-lines-after 1)
  ("j" "Jump to ID node" plain #'org-node-capture-target
   ,my-org-header :jump-to-captured t :immediate-finish t)
  ("q" "Make quick stub ID node" plain #'org-node-capture-target
   ,my-org-header :immediate-finish t)
  ("n" "Note" entry
   (file+headline ,(lc-home-file "doc/org/notes.org") "Random Notes")
   "** %?" :empty-lines 0)
  ("g" "General To-Do" entry
   (file+headline ,(lc-home-file "doc/org/todos.org") "General Tasks")
   "* TODO [#B] %?\n:Created: %T\n " :empty-lines 0)
  ("c" "Code To-Do" entry
   (file+headline ,(lc-home-file "doc/org/todos.org")
		  "Code Related Tasks")
   "* TODO [#B] %?\n:Created: %T\n%i\n%a\nProposed Solution: "
   :empty-lines 0)
  ("m" "Meeting" entry
   (file+olp+datetree ,(lc-home-file "doc/org/meetings.org"))
   "* %? :meeting:%^g \n:Created: %T\n** Attendees\n*** \n** Notes\n** Action Items\n*** TODO [#A] "
   :tree-type week :clock-in t :clock-resume t :empty-lines 0)
  ("p" "Protocol" entry
   (file+headline (lambda () (expand-file-name "notes.org" org-directory))
		  "Inbox")
   "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
  ("L" "Protocol Link" entry
   (file+headline (lambda () (expand-file-name "notes.org" org-directory))
		  "Inbox")
   "* %? [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\nCaptured On: %U")
  ("w" "Web site" entry (file "")
   "* %a :website:\n\n%U %?\n\n%:initial")))
 '(org-columns-default-format
 "%50ITEM(Task) %10CLOCKSUM %16TIMESTAMP_IA")
 '(org-confirm-babel-evaluate t)
 '(org-default-notes-file (lc-home-file "doc/org/notes.org"))
 '(org-directory (lc-home-file "doc/org"))
 '(org-export-exclude-tags '("confidential"))
 '(org-export-select-tags '("public"))
 '(org-hide-emphasis-markers t)
 '(org-id-link-to-org-use-id 'use-existing)
 '(org-latex-packages-alist
 '(("" "braket" t nil) ("" "esint" t nil) ("" "units" t nil)
   ("" "unicode-math" t nil)))
 '(org-latex-preview-appearance-options
 '(:foreground default :background default :scale 2 :html-foreground
	       "Black" :html-background "Transparent" :html-scale 1.0
	       :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")))
 '(org-latex-preview-process-default 'dvisvgm)
 '(org-log-done 'time)
 '(org-mem-do-sync-with-org-id t)
 '(org-mem-watch-dirs (list (lc-home-file "doc/org-roam/")))
 '(org-modern-hide-stars nil)
 '(org-modern-list '((42 . "•") (43 . "‣")))
 '(org-modern-table nil)
 '(org-msg-convert-citation t)
 '(org-msg-greeting-fmt "Hello%s,")
 '(org-msg-posting-style nil)
 '(org-node-alter-candidates t)
 '(org-node-creation-fn #'org-capture)
 '(org-noter-always-create-frame nil)
 '(org-noter-auto-save-last-location t)
 '(org-noter-notes-search-path (list (lc-home-file "doc/org-roam")))
 '(org-replace-disputed-keys t)
 '(org-return-follows-link t)
 '(org-src-fontify-natively t)
 '(org-src-tab-acts-natively t)
 '(org-startup-folded 'content)
 '(org-startup-with-inline-images t)
 '(org-startup-with-link-previews t)
 '(org-sticky-header-always-show-header t)
 '(org-sticky-header-full-path 'reversed)
 '(org-support-shift-select t)
 '(org-tag-alist
 '((:startgroup) ("@bug" . 98) ("@feature" . 117) ("@spike" . 106)
   (:endgroup) ("WAITING" . 119) ("HOLD" . 104) ("CANCELLED" . 99)
   ("FLAGGED" . 63) ("@write_future_ticket" . 118)
   ("@emergency" . 101) ("@research" . 114) (:startgroup)
   ("big_sprint_review" . 105) ("cents_sprint_retro" . 110)
   ("dsu" . 100) ("grooming" . 103) ("sprint_retro" . 115) (:endgroup)
   ("QA" . 113) ("backend" . 107) ("broken_code" . 66)
   ("frontend" . 102) ("CRITICAL" . 120) ("obstacle" . 111)
   ("HR" . 72) ("general" . 108) ("meeting" . 109) ("misc" . 122)
   ("planning" . 112) ("accomplishment" . 97)))
 '(org-tag-faces
 '(("planning" :foreground "mediumPurple1" :weight bold)
   ("backend" :foreground "royalblue1" :weight bold)
   ("frontend" :foreground "forest green" :weight bold)
   ("QA" :foreground "sienna" :weight bold)
   ("meeting" :foreground "yellow1" :weight bold)
   ("CRITICAL" :foreground "red1" :weight bold)))
 '(org-todo-keywords
 '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i@/!)"
	     "VERIFYING(v!)" "BLOCKED(b@)" "|" "DONE(d!)" "OBE(o@!)"
	     "WONT-DO(w@/!)")))
 '(org-todo-state-tags-triggers
   '(("BLOCKED" ("WAITING" . t))
     (done ("WAITING") ("HOLD"))
     ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
     ("IN-PROGRESS" ("WAITING") ("CANCELLED") ("HOLD"))
     ("OBE" ("CANCELLED" . t)) ("WONT-DO" ("CANCELLED" . t))
     ("DONE" ("WAITING") ("CANCELLED") ("HOLD"))))
 '(outline-indent-ellipsis " ▼ ")
 '(package-selected-packages nil)
 '(proced-auto-update-flag 'visible)
 '(proced-auto-update-interval 1)
 '(proced-descent t)
 '(proced-enable-color-flag t)
 '(proced-filter 'user)
 '(proced-tree-flag t)
 '(pulsar-face 'pulsar-blue)
 '(python-shell-completion-native-disabled-interpreters
 '("python3" "pypy3"))
 '(read-mail-command 'mu4e)
 '(read-process-output-max 1048576)
 '(recentf-max-menu-items 25)
 '(register-preview-delay 0.5)
 ;; Program names are resolved against each buffer's current environment at launch.
 '(inferior-lisp-program "sbcl")
 '(julia-snail-executable "julia")
 '(python-shell-interpreter "python")
 '(geiser-guile-binary "guile")
 '(geiser-racket-binary "racket")
 '(geiser-chicken-binary "csi")
 '(haskell-program-name "ghci")
 '(nodejs-repl-command "node")
 '(jedi:complete-on-dot t)
 '(imaxima-use-maxima-mode-flag t)
 '(request-backend 'url-retrieve)
 '(rust-format-on-save nil)
 ;; Rust mode chooses its parent when the library loads, not per buffer.
 ;; Use Guix-provided grammars only; otherwise keep its classic implementation.
 '(rust-mode-treesitter-derive (treesit-ready-p 'rust t))
 '(rustic-format-on-save nil)
 '(rustic-lsp-client 'lsp-mode)
 '(safe-local-variable-directories
 '("/home/dannym/src/auto/e/guix-mono-team/guix/"))
 '(safe-local-variable-values
 '((eval setq-local bug-reference-bug-regexp
	 (rx
	  (group (seq (32 "guix/guix") (or "#" "!"))
		 (group (one-or-more digit)))))
   (org-emphasis-alist ("/" italic) ("_" underline)
		       ("=" org-verbatim verbatim)
		       ("~" org-code verbatim) ("," org-quote))))
 '(scroll-conservatively 101)
 '(scroll-margin 0)
 '(scroll-preserve-screen-position nil)
 '(solarized-contrast 'normal)
 '(spacious-padding-subtle-frame-lines nil) ; must stay nil: see below
 '(spacious-padding-subtle-mode-line t)
 '(spacious-padding-widths
 '(:internal-border-width 0 :header-line-width 4 :mode-line-width 6
			  :tab-width 5 :right-divider-width 10
			  :scroll-bar-width 8 :fringe-width 12))
 '(tab-always-indent 'complete)
 '(tab-line-close-tab-function 'kill-buffer)
 '(tool-bar-button-margin '(7 . 1))
 '(tool-bar-style 'image)
 '(treemacs-width 25)
 '(version-control t)
 '(vertico-preselect 'prompt)
 '(visible-bell t)
 '(which-key-idle-delay 0.2)
 '(word-wrap t)
 '(xref-search-program 'ripgrep)
 ;; Retained application preferences use Custom, never repeated :config overrides.
 '(agent-shell-loki-acp-command (list (lc-home-file "src/loki/loki-acp")))
 '(TeX-command-extra-options "-no-shell-escape")
 '(org-latex-compiler "lualatex")
 '(org-ditaa-default-exec-mode 'ditaa)
 '(org-ditaa-exec "ditaa")
 '(org-publish-project-alist
   `(("friendly-machines.com"
      :base-directory ,(lc-home-file "doc/org-roam")
      :publishing-directory ,(lc-home-file "friendly-machines.com/www/mirror/public/blog/")
      :base-extension "org" :recursive t :publishing-function org-html-publish-to-html
      :html-doctype "html5" :with-toc nil :section-numbers nil
      :html-head "<link rel=\"stylesheet\" href=\"/css/org.css\" type=\"text/css\"/>"
      :html-preamble nil :html-postamble nil
      :exclude ".*-private\\.org\\|.*-confidential\\.org\\|.*-internal\\.org"
      :select-tags ("public"))))
 '(org-node-seq-defs
   (list (org-node-seq-def-on-filepath-sort-by-basename
          "d" "Daily-files" (lc-home-file "doc/org/daily/") nil t)
         (org-node-seq-def-on-any-sort-by-property "a" "All ID-nodes by CREATED" "CREATED" "n")))
 '(mail-user-agent 'mu4e-user-agent)
 '(message-mail-user-agent t)
 '(message-kill-buffer-on-exit t)
 '(message-signature-file (lc-home-file ".emacs.d/.signature"))
 '(mu4e-update-interval 240)
 '(mu4e-compose-signature-auto-include nil)
 '(mu4e-search-skip-duplicates t)
 '(mu4e-headers-auto-update t)
 '(mu4e-attachment-dir (lc-home-file "Downloads"))
 '(mu4e-use-fancy-chars t)
 '(mu4e-change-filenames-when-moving t)
 '(mu4e-context-policy 'pick-first)
 '(mu4e-compose-context-policy 'ask)
 '(mu4e-bookmarks
   '((:query "flag:unread AND NOT flag:trashed" :name "Unread messages" :key ?u)
     (:query "flag:unread" :name "New messages" :key ?n)
     (:query "date:today..now" :name "Today's messages" :key ?t)
     (:query "date:7d..now" :name "Last 7 days" :key ?w)
     (:query "mime:image/*" :name "Messages with images" :key ?p)))
 '(org-mu4e-convert-to-html t)
 '(mm-verify-option 'known)
 '(gnus-select-method '(nntp "news.gmane.io" (nntp-open-connection-function lc-nntp-starttls) (nntp-port-number 119)))
 '(gnus-startup-file (lc-state-file "newsrc"))
 '(gnus-agent-directory (lc-state-file "gnus-agent/"))
 '(gnus-sum-thread-tree-indent " ")
 '(gnus-sum-thread-tree-root "")
 '(gnus-sum-thread-tree-false-root "")
 '(gnus-sum-thread-tree-single-indent "")
 '(gnus-sum-thread-tree-vertical "|")
 '(gnus-sum-thread-tree-leaf-with-other "+-> ")
 '(gnus-sum-thread-tree-single-leaf "\\-> ")
 '(gnus-summary-line-format "%U%R %-18,18&user-date; %4L:%-25,25f %B%s\n")
 '(gnus-summary-mode-line-format "[%U] %p")
 '(gnus-summary-display-arrow t)
 '(gnus-play-startup-jingle nil)
 '(gnus-gcc-mark-as-read t)
 '(gnus-agent t)
 '(gnus-check-new-newsgroups 'ask-server)
 '(gnus-read-active-file 'some)
 '(gnus-use-dribble-file t)
 '(gnus-always-read-dribble-file t)
 '(gnus-agent-article-alist-save-format 1)
 '(gnus-agent-cache t)
 '(gnus-agent-confirmation-function 'y-or-n-p)
 '(gnus-agent-consider-all-articles nil)
 '(gnus-agent-enable-expiration 'ENABLE)
 '(gnus-agent-expire-all nil)
 '(gnus-agent-expire-days 30)
 '(gnus-agent-mark-unread-after-downloaded t)
 '(gnus-agent-queue-mail t)
 '(gnus-agent-synchronize-flags nil)
 '(gnus-article-browse-delete-temp 'ask)
 '(gnus-article-over-scroll nil)
 '(gnus-article-show-cursor t)
 '(gnus-article-sort-functions '((not gnus-article-sort-by-number) (not gnus-article-sort-by-date)))
 '(gnus-article-truncate-lines nil)
 '(gnus-html-frame-width 80)
 '(gnus-html-image-automatic-caching t)
 '(gnus-inhibit-images t)
 '(gnus-max-image-proportion 0.7)
 '(gnus-treat-display-smileys nil)
 '(gnus-article-mode-line-format "%G %S %m")
 '(gnus-visible-headers '("^From:" "^To:" "^Cc:" "^Subject:" "^Newsgroups:" "^Date:"
                         "Followup-To:" "Reply-To:" "^Organization:" "^X-Newsreader:" "^X-Mailer:"))
 '(gnus-sorted-header-list '("^From:" "^To:" "^Cc:" "^Subject:" "^Newsgroups:" "^Date:"
                           "Followup-To:" "Reply-To:" "^Organization:" "^X-Newsreader:" "^X-Mailer:"))
 '(gnus-article-x-face-too-ugly ".*")
 '(gnus-asynchronous t)
 '(gnus-use-article-prefetch 15)
 '(gnus-level-subscribed 6)
 '(gnus-level-unsubscribed 7)
 '(gnus-level-zombie 8)
 '(gnus-activate-level 1)
 '(gnus-list-groups-with-ticked-articles nil)
 '(gnus-group-sort-function '((gnus-group-sort-by-unread) (gnus-group-sort-by-alphabet) (gnus-group-sort-by-rank)))
 '(gnus-group-line-format "%M%p%P%5y:%B%(%g%)\n")
 '(gnus-group-mode-line-format "%%b")
 '(gnus-topic-display-empty-topics nil)
 '(gnus-auto-select-first nil)
 '(gnus-summary-ignore-duplicates t)
 '(gnus-suppress-duplicates t)
 '(gnus-save-duplicate-list t)
 '(gnus-summary-goto-unread nil)
 '(gnus-summary-make-false-root 'adopt)
 '(gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject)
 '(gnus-summary-gather-subject-limit 'fuzzy)
 '(gnus-thread-sort-functions '((not gnus-thread-sort-by-date) (not gnus-thread-sort-by-number)))
 '(gnus-subthread-sort-functions 'gnus-thread-sort-by-date)
 '(gnus-thread-hide-subtree nil)
 '(gnus-thread-ignore-subject nil)
 '(gnus-user-date-format-alist '(((gnus-seconds-today) . "Today at %R")
                               ((+ (* 60 60 24) (gnus-seconds-today)) . "Yesterday, %R")
                               (t . "%Y-%m-%d %R")))
 '(gnus-ignored-from-addresses "dannym@friendly-machines\\.com")
 '(gnus-summary-to-prefix "To: ")
 '(emms-player-list '(emms-player-mpv) t)
 '(emms-info-functions '(emms-info-libtag) t)
 '(emms-browser-covers #'emms-browser-cache-thumbnail t)
 '(emms-tag-editor-pipe-config '(("mid3iconv <file>" :command "mid3iconv" :arguments (name))) t)
)
(custom-set-faces
 '(default
 ((t
   (:family "Noto Sans Mono" :foundry "GOOG" :slant normal :weight
	    regular :height 110 :width normal))))
 '(fixed-pitch ((t (:family "Noto Mono"))))
 '(lsp-ui-sideline-global
 ((t (:family "Dijkstra Italic" :slant italic :weight regular :height 0.8))))
 '(org-table
 ((t (:foreground "#2aa198" :family "Atkinson Hyperlegible"))))
 '(tab-line
 ((t
   (:height 0.9 :foreground "black" :background "grey85" :inherit
	    variable-pitch))))
)

;;; `spacious-padding-subtle-frame-lines' must stay nil.
;;;
;;; spacious-padding 0.9.0, `spacious-padding--set-face-box-padding' (l.383-385):
;;;
;;;(list :underline
;;;      (list :color (or (spacious-padding--get-face-line-color face fallback subtle-key)
;;;                       (spacious-padding--face-foreground 'default))
;;;            :position t))
;;;
;;; Both fallbacks can return `unspecified'. The second reads `default''s
;;; foreground, which on a headless daemon is the symbol `unspecified'. That
;;; reaches xfaces.c as :color unspecified, is rejected, and fails all later
;;; frame creation. Setting the variable to t reintroduces the failure; the
;;; guard in `lc-graphic-ui' only repairs faces spacious-padding itself uses.
