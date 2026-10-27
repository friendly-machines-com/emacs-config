;;; gui-settings.el --- Emacs-managed Customize output -*- lexical-binding: t; -*-
;; Imported by reading, never evaluating, the previous configuration's files.
;; This is the only settings file; M-x customize owns it from here on.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-command "lualatex")
 '(LaTeX-electric-left-right-brace t)
 '(TeX-command-extra-options "-no-shell-escape")
 '(TeX-electric-sub-and-superscript t)
 '(TeX-engine 'luatex)
 '(agent-shell-header-style 'text)
 '(agent-shell-loki-acp-command (list (lc-home-file "src/loki/loki-acp")))
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
 '(completion-category-defaults nil t)
 '(completion-category-overrides '((file (styles basic partial-completion))))
 '(completion-styles '(orderless basic))
 '(consult-narrow-key "<")
 '(cua-auto-tabify-rectangles nil)
 '(cua-keep-region-after-copy t)
 '(dap-python-debugger 'debugpy)
 '(debbugs-browse-url-regexp
   "^https?://\\(debbugs\\.gnu\\.org\\|bugs\\.gnu\\.org\\|issues.guix.gnu.org\\)/\\(cgi/bugreport\\.cgi\\?bug=\\)?\\([[:digit:]]+\\)$")
 '(delete-by-moving-to-trash t)
 '(delete-old-versions t)
 '(dired-launch-extensions-map
   '(("xlsx" ("libreoffice")) ("odt" ("libreoffice" "abiword"))) t)
 '(dired-listing-switches "-alot --si")
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
 '(emms-browser-covers #'emms-browser-cache-thumbnail t)
 '(emms-info-functions '(emms-info-libtag) t)
 '(emms-player-list '(emms-player-mpv) t)
 '(emms-tag-editor-pipe-config
   '(("mid3iconv <file>" :command "mid3iconv" :arguments (name))) t)
 '(epg-pinentry-mode 'loopback)
 '(eshell-hist-ignoredups t)
 '(eshell-history-size 100000)
 '(eshell-save-history-on-exit t)
 '(flymake-indicator-type 'margins)
 '(flymake-inline-diagnostics t)
 '(flymake-margin-indicators-string
   '((error "!" compilation-error) (warning "?" compilation-warning)
     (note "i" compilation-info)))
 '(format-all-debug nil)
 '(format-all-show-errors 'errors)
 '(frame-background-mode 'light)
 '(geiser-chicken-binary "csi")
 '(geiser-guile-binary "guile")
 '(geiser-mode-auto-p nil)
 '(geiser-racket-binary "racket")
 '(gnus-activate-level 1)
 '(gnus-agent t)
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
 '(gnus-always-read-dribble-file t)
 '(gnus-article-browse-delete-temp 'ask)
 '(gnus-article-mode-line-format "%G %S %m")
 '(gnus-article-over-scroll nil)
 '(gnus-article-show-cursor t)
 '(gnus-article-sort-functions
   '((not gnus-article-sort-by-number) (not gnus-article-sort-by-date)))
 '(gnus-article-truncate-lines nil)
 '(gnus-article-x-face-too-ugly ".*")
 '(gnus-asynchronous t)
 '(gnus-auto-select-first nil)
 '(gnus-check-new-newsgroups 'ask-server)
 '(gnus-gcc-mark-as-read t)
 '(gnus-group-line-format "%M%p%P%5y:%B%(%g%)\12")
 '(gnus-group-mode-line-format "%%b")
 '(gnus-group-sort-function
   '((gnus-group-sort-by-unread) (gnus-group-sort-by-alphabet)
     (gnus-group-sort-by-rank)))
 '(gnus-html-frame-width 80)
 '(gnus-html-image-automatic-caching t)
 '(gnus-ignored-from-addresses "dannym@friendly-machines\\.com")
 '(gnus-inhibit-images t)
 '(gnus-level-subscribed 6 t)
 '(gnus-level-unsubscribed 7 t)
 '(gnus-level-zombie 8 t)
 '(gnus-list-groups-with-ticked-articles nil)
 '(gnus-max-image-proportion 0.7)
 '(gnus-play-startup-jingle nil)
 '(gnus-read-active-file 'some)
 '(gnus-save-duplicate-list t)
 '(gnus-select-method
   '(nntp "news.gmane.io"
          (nntp-open-connection-function lc-nntp-starttls)
          (nntp-port-number 119)))
 '(gnus-sorted-header-list
   '("^From:" "^To:" "^Cc:" "^Subject:" "^Newsgroups:" "^Date:"
     "Followup-To:" "Reply-To:" "^Organization:" "^X-Newsreader:"
     "^X-Mailer:"))
 '(gnus-subthread-sort-functions 'gnus-thread-sort-by-date)
 '(gnus-sum-thread-tree-false-root "")
 '(gnus-sum-thread-tree-indent " ")
 '(gnus-sum-thread-tree-leaf-with-other "+-> ")
 '(gnus-sum-thread-tree-root "")
 '(gnus-sum-thread-tree-single-indent "")
 '(gnus-sum-thread-tree-single-leaf "\\-> ")
 '(gnus-sum-thread-tree-vertical "|")
 '(gnus-summary-display-arrow t)
 '(gnus-summary-gather-subject-limit 'fuzzy)
 '(gnus-summary-goto-unread nil)
 '(gnus-summary-ignore-duplicates t)
 '(gnus-summary-line-format "%U%R %-18,18&user-date; %4L:%-25,25f %B%s\12")
 '(gnus-summary-make-false-root 'adopt)
 '(gnus-summary-mode-line-format "[%U] %p")
 '(gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject)
 '(gnus-summary-to-prefix "To: ")
 '(gnus-suppress-duplicates t)
 '(gnus-thread-hide-subtree nil)
 '(gnus-thread-ignore-subject nil)
 '(gnus-thread-sort-functions
   '((not gnus-thread-sort-by-date) (not gnus-thread-sort-by-number)))
 '(gnus-topic-display-empty-topics nil)
 '(gnus-treat-display-smileys nil)
 '(gnus-use-article-prefetch 15)
 '(gnus-use-dribble-file t)
 '(gnus-user-date-format-alist
   '(((gnus-seconds-today) . "Today at %R")
     ((+ (* 60 60 24) (gnus-seconds-today)) . "Yesterday, %R")
     (t . "%Y-%m-%d %R")))
 '(gnus-visible-headers
   '("^From:" "^To:" "^Cc:" "^Subject:" "^Newsgroups:" "^Date:"
     "Followup-To:" "Reply-To:" "^Organization:" "^X-Newsreader:"
     "^X-Mailer:"))
 '(grep-command "rg -nS --no-heading ")
 '(haskell-program-name "ghci")
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
                       (concat paragraph-separate
                               "\\|\\s-*\".*[,\\.]$"))
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
                                     default-directory
                                     ".dir-locals.el"))
                  "/*.eld")))
             (unless (member guix-tempel-snippets tempel-path)
               (add-to-list 'tempel-path guix-tempel-snippets))))
     (eval setq-local guix-directory
           (locate-dominating-file default-directory ".dir-locals.el"))
     (eval add-to-list 'completion-ignored-extensions ".go")
     (eval modify-syntax-entry 43 "'")
     (eval modify-syntax-entry 36 "'")
     (eval modify-syntax-entry 126 "'")
     (geiser-guile-binary "guix" "repl") (geiser-insert-actual-lambda)))
 '(imaxima-use-maxima-mode-flag t)
 '(indent-bars-no-descend-lists t)
 '(indent-bars-treesit-ignore-blank-lines-types '("module"))
 '(indent-bars-treesit-scope
   '((python function_definition class_definition for_statement
             if_statement with_statement while_statement)))
 '(indent-bars-treesit-support t)
 '(indent-tabs-mode nil)
 '(inferior-lisp-program "sbcl")
 '(inhibit-startup-screen t)
 '(jedi:complete-on-dot t)
 '(jit-lock-defer-time 0.05)
 '(julia-snail-executable "julia")
 '(kept-new-versions 6)
 '(kept-old-versions 2)
 '(large-file-warning-threshold 100000000)
 '(lc-guix-authorized-manifests
   '(("/home/dannym/src/lazarus/pas/guix/manifest.scm"
      . "caf41c2039eb6882dc260f419ba3141ade0f60be6f49b5c552ec30a51c63d65e")
     ("/home/dannym/src/agent-c/e/rune-os/kernel/manifest.scm"
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
 '(lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
 '(lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
 '(lsp-rust-analyzer-display-parameter-hints nil)
 '(lsp-rust-analyzer-display-reborrow-hints nil)
 '(lsp-tex-server 'digestif)
 '(lsp-treemacs-theme "Iconless")
 '(lsp-ui-doc-enable t)
 '(lsp-ui-doc-show-with-mouse t)
 '(lsp-ui-peek-always-show t)
 '(lsp-ui-sideline-show-hover t)
 '(magit-status-file-list-limit 1000)
 '(mail-user-agent 'mu4e-user-agent)
 '(mediainfo-mode-file-regexp
   "\\.\\(?:3gp\\|a\\(?:iff\\|vi\\)\\|flac\\|jpg\\|jpeg\\|png\\|gif\\|m\\(?:4a\\|kv\\|ov\\|p[34g]\\)\\|o\\(?:gg\\|pus\\)\\|vob\\|w\\(?:av\\|ebm\\|mv\\)\\)\\'")
 '(message-kill-buffer-on-exit t)
 '(message-mail-user-agent t)
 '(message-signature-file (lc-home-file ".emacs.d/.signature"))
 '(mm-verify-option 'known)
 '(mml-secure-openpgp-sign-with-sender t)
 '(mouse-autoselect-window t)
 '(mpv-start-timeout 0.5)
 '(mu4e-attachment-dir (lc-home-file "Downloads"))
 '(mu4e-bookmarks
   '((:query "flag:unread AND NOT flag:trashed" :name "Unread messages"
             :key 117 :type bookmarks :count 224699 :unread 224699
             :delta-count 797 :delta-unread 797 :maildir nil
             :effective-query "flag:unread AND NOT flag:trashed")
     (:query "flag:unread" :name "New messages" :key 110 :type
             bookmarks :count 224699 :unread 224699 :delta-count 797
             :delta-unread 797 :maildir nil :effective-query
             "flag:unread")
     (:query "date:today..now" :name "Today's messages" :key 116 :type
             bookmarks :count 573 :unread 569 :delta-count 573
             :delta-unread 569 :maildir nil :effective-query
             "date:today..now")
     (:query "date:7d..now" :name "Last 7 days" :key 119 :type
             bookmarks :count 3074 :unread 2984 :delta-count 798
             :delta-unread 793 :maildir nil :effective-query
             "date:7d..now")
     (:query "mime:image/*" :name "Messages with images" :key 112
             :type bookmarks :count 322 :unread 221 :delta-count 1
             :delta-unread 0 :maildir nil :effective-query
             "mime:image/*")))
 '(mu4e-change-filenames-when-moving t)
 '(mu4e-compose-context-policy 'ask)
 '(mu4e-compose-signature-auto-include nil)
 '(mu4e-compose-switch nil)
 '(mu4e-context-policy 'pick-first)
 '(mu4e-headers-auto-update t)
 '(mu4e-search-results-limit -1)
 '(mu4e-search-skip-duplicates t)
 '(mu4e-update-interval 240)
 '(mu4e-use-fancy-chars t)
 '(nodejs-repl-command "node")
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
                    (:name "Planning Next Steps" :todo "PLANNING"
                           :order 2)
                    (:name "Problems & Blockers" :todo "BLOCKED" :tag
                           "obstacle" :order 3)
                    (:name "Tickets to Create" :tag
                           "@write_future_ticket" :order 4)
                    (:name "Research Required" :tag "@research" :order
                           7)
                    (:name "Meeting Action Items" :and
                           (:tag "meeting" :priority "A") :order 8)
                    (:name "Other Important Items" :and
                           (:todo "TODO" :priority "A" :not
                                  (:tag "meeting"))
                           :order 9)
                    (:name "General Backlog" :and
                           (:todo "TODO" :priority "B") :order 10)
                    (:name "Non Critical" :priority<= "C" :order 11)
                    (:name "Currently Being Verified" :todo
                           "VERIFYING" :order 20)))))))))
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
     (file+headline ,(lc-home-file "doc/org/todos.org")
                    "General Tasks")
     "* TODO [#B] %?\12:Created: %T\12 " :empty-lines 0)
    ("c" "Code To-Do" entry
     (file+headline ,(lc-home-file "doc/org/todos.org")
                    "Code Related Tasks")
     "* TODO [#B] %?\12:Created: %T\12%i\12%a\12Proposed Solution: "
     :empty-lines 0)
    ("m" "Meeting" entry
     (file+olp+datetree ,(lc-home-file "doc/org/meetings.org"))
     "* %? :meeting:%^g \12:Created: %T\12** Attendees\12*** \12** Notes\12** Action Items\12*** TODO [#A] "
     :tree-type week :clock-in t :clock-resume t :empty-lines 0)
    ("p" "Protocol" entry
     (file+headline
      (lambda nil (expand-file-name "notes.org" org-directory))
      "Inbox")
     "* %^{Title}\12Source: %u, %c\12 #+BEGIN_QUOTE\12%i\12#+END_QUOTE\12\12\12%?")
    ("L" "Protocol Link" entry
     (file+headline
      (lambda nil (expand-file-name "notes.org" org-directory))
      "Inbox")
     "* %? [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\12Captured On: %U")
    ("w" "Web site" entry (file "")
     "* %a :website:\12\12%U %?\12\12%:initial")))
 '(org-columns-default-format "%50ITEM(Task) %10CLOCKSUM %16TIMESTAMP_IA")
 '(org-confirm-babel-evaluate t)
 '(org-default-notes-file (lc-home-file "doc/org/notes.org"))
 '(org-directory (lc-home-file "doc/org"))
 '(org-ditaa-default-exec-mode 'ditaa)
 '(org-ditaa-exec "ditaa")
 '(org-export-exclude-tags '("confidential"))
 '(org-export-select-tags '("public"))
 '(org-hide-emphasis-markers t)
 '(org-id-link-to-org-use-id 'use-existing)
 '(org-latex-compiler "lualatex")
 '(org-latex-packages-alist
   '(("" "braket" t nil) ("" "esint" t nil) ("" "units" t nil)
     ("" "unicode-math" t nil)))
 '(org-latex-preview-appearance-options
   '(:foreground default :background default :scale 1 :html-foreground
                 "Black" :html-background "Transparent" :html-scale
                 1.0 :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")
                 :zoom 1.2))
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
 '(org-mu4e-convert-to-html t)
 '(org-node-alter-candidates t)
 '(org-node-creation-fn #'org-capture)
 '(org-node-seq-defs
   (list
    (org-node-seq-def-on-filepath-sort-by-basename "d" "Daily-files"
                                                   (lc-home-file
                                                    "doc/org/daily/")
                                                   nil t)
    (org-node-seq-def-on-any-sort-by-property "a"
                                              "All ID-nodes by CREATED"
                                              "CREATED" "n")))
 '(org-noter-always-create-frame nil)
 '(org-noter-auto-save-last-location t)
 '(org-noter-notes-search-path (list (lc-home-file "doc/org-roam")))
 '(org-publish-project-alist
   `
   (("friendly-machines.com" :base-directory
     ,(lc-home-file "doc/org-roam") :publishing-directory
     ,(lc-home-file "friendly-machines.com/www/mirror/public/blog/")
     :base-extension "org" :recursive t :publishing-function
     org-html-publish-to-html :html-doctype "html5" :with-toc nil
     :section-numbers nil :html-head
     "<link rel=\"stylesheet\" href=\"/css/org.css\" type=\"text/css\"/>"
     :html-preamble nil :html-postamble nil :exclude
     ".*-private\\.org\\|.*-confidential\\.org\\|.*-internal\\.org"
     :select-tags ("public"))))
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
     ("dsu" . 100) ("grooming" . 103) ("sprint_retro" . 115)
     (:endgroup) ("QA" . 113) ("backend" . 107) ("broken_code" . 66)
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
   '(("BLOCKED" ("WAITING" . t)) (done ("WAITING") ("HOLD"))
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
 '(python-shell-completion-native-disabled-interpreters '("python3" "pypy3"))
 '(python-shell-interpreter "python")
 '(read-mail-command 'mu4e)
 '(read-process-output-max 1048576 t)
 '(recentf-max-menu-items 25)
 '(register-preview-delay 0.5)
 '(request-backend 'url-retrieve)
 '(rust-format-on-save nil)
 '(rust-mode-treesitter-derive (treesit-ready-p 'rust t))
 '(rustic-format-on-save nil)
 '(rustic-lsp-client 'lsp-mode)
 '(safe-local-variable-directories '("/home/dannym/src/auto/e/guix-mono-team/guix/"))
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
 '(spacious-padding-subtle-frame-lines nil)
 '(spacious-padding-subtle-mode-line t)
 '(spacious-padding-widths
   '(:internal-border-width 0 :header-line-width 4 :mode-line-width 6
                            :tab-width 5 :right-divider-width 10
                            :scroll-bar-width 8 :fringe-width 12))
 '(tab-always-indent 'complete)
 '(tab-line-close-tab-function 'kill-buffer)
 '(tool-bar-button-margin '(7 . 1) t)
 '(tool-bar-style 'image)
 '(treemacs-width 25)
 '(version-control t)
 '(vertico-preselect 'prompt)
 '(visible-bell t)
 '(which-key-idle-delay 0.2)
 '(word-wrap t)
 '(xref-search-program 'ripgrep))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Noto Sans Mono" :foundry "GOOG" :slant normal :weight regular :height 110 :width normal))))
 '(fixed-pitch ((t (:family "Noto Mono"))))
 '(lsp-ui-sideline-global ((t (:family "Dijkstra Italic" :slant italic :weight regular :height 0.8))))
 '(org-table ((t (:foreground "#2aa198" :family "Atkinson Hyperlegible"))))
 '(tab-line ((t (:height 0.9 :foreground "black" :background "grey85" :inherit variable-pitch)))))

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
