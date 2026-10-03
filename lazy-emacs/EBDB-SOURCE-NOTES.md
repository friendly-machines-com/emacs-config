# EBDB recipient-completion finding

`guix build -S emacs-ebdb` returned `/gnu/store/2rifs9v791kj51z91pb21figfqrzdzlm-ebdb-0.8.22.tar`; inspected sources are under `/tmp/ebdb-source-review/ebdb-0.8.22`. This identifies the current Guix package, not a proven version of the running host profile.

**Yes, EBDB provides recipient completion.** ebdb-message.el:120–138 installs either an EBDB completion-at-point function or entries in message-completion-alist for To/Cc/Bcc/Reply-To/From/etc. It registers on message-mode-hook (185); ebdb-mu4e.el requires ebdb-message (28). ebdb-complete-mail defaults to true; it can instead use CAPF. ebdb-initialize itself only builds record/cache data structures; it is not what installs the composition hooks.

The original config registers EBDB Gnus and mu4e insinuation on gnus-startup-hook. Because Gnus is used for news and mu4e derives from Message/Gnus-related machinery, completion may become available as a side effect of starting Gnus; source inspection alone cannot prove which provider supplied a particular address in the live daemon.

mu4e also independently supplies completion from its indexed-mail contact set (mu4e-compose.el:189–245 in current Guix mu 1.14.3). Removing EBDB would not remove *all* address completion, but could remove addresses/aliases that exist only in the separate EBDB database.

**Final user decision supersedes the earlier conditional-retention discussion: remove EBDB entirely from the replacement configuration.** Keep native mu4e recipient completion and preserve the old EBDB database without loading/modifying it. Do not introduce a new contacts package now; an Org-based option can be considered in a later session. No contact database was read/deleted in this investigation.
