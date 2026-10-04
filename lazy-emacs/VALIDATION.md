# Validation results

Validation used actual **Guix Emacs PGTK 31.1**, not emacs-minimal. Dependencies were provisioned through the editor manifest; channel pins are recorded in guix/channels.scm. No original init was evaluated and no real mail/model session was opened.

| Check | Result |
| --- | --- |
| Maintained Lisp non-evaluating syntax/parens checks | Passed |
| Core regressions (paths, policy, approvals, save scope, helpers) | **16 passed** |
| Actual-package integration, fixture Org indexing/reminders, Custom, actions, Babel declarations, MathML queue, native Noter/Jupyter, language-mode routing, publishing privacy, Sass lifecycle, isolated mu index | **25 passed** |
| Real PGTK daemon/frame assertions on isolated Xvfb | **6 passed** |
| Same GUI suite with actual local Org MathML conversion and image overlay, managed LuaLaTeX/dvisvgm | **7 passed** |
| Pending completing-read inside a real emacsclient server filter, then another request | Passed |
| Pending read-key inside a real emacsclient server filter, then another request | Passed |
| Actual disposable Guix container /usr/bin/env profile symlink | Passed (`CONTAINER_ENV_OK`) |
| Public Gmane NNTP STARTTLS and verified certificate | Passed: **TLSv1.3 / TLS_AES_256_GCM_SHA384** |

The NNTP check sent greeting/capability/STARTTLS commands only—no authentication, groups or articles. Its encryption-required configuration has no automatic plaintext fallback.

The real mail-index test used an empty synthetic Maildir in /tmp. It initialized only an isolated index, waited for actual mu indexing completion, verified an existing index cannot be reinitialized through the helper, and confirmed no mail polling started. No jma sync, SMTP send or private message retrieval was run.

The actual MathML test displayed a synthetic fraction in a real PGTK buffer, ran the retained local org-latex-preview backend using Guix-provided TeX, and waited for an image overlay. Conversion and cached/asynchronous queue contracts also have separate tests; no Xenops or foreign major-mode switch was used.

Warm explicit source init with two fixture Org files measured approximately **2.1–2.6 seconds**. This does not include Guix provisioning and is not a cold/Wayland/full-user-corpus benchmark or a measured comparison against the original configuration.

## Test environment versus production

Fixtures supply valid Org directories/files outside hidden ancestor paths, which Org Mem deliberately excludes. They do not install advice on its private scanner, filter production data or suppress missing production paths. A regression assertion prevents that rejected helper/advice from reappearing.

GUI runs allocate a separate display, named daemon/socket, source/state fixture and caches. A bare PGTK control first verified the display setup. The missing-menu filter's own recursive introspection bug was diagnosed separately and fixed in its implementation; no native key-lookup patch was installed.

Preferred user font families remain settings; fallback fonts make a clean profile usable. LANG=C does not select a Jinx dictionary automatically; that warning is visible rather than addressed by changing production language preferences. English/German dictionaries are supplied. Local Org's deprecated when-let/if-let warnings and optional missing DjVu support are visible too, not hidden behind production error suppression.

## Not claimed as validated

- The user's Wayland compositor, HiDPI scaling, exact fonts, full GUI/menu/click/focus workflows.
- Real private reminders/mail/news state, email delivery, provider authentication/agent turn, real project LSP/debugger sessions, publication output or remote Jupyter kernels.
- Universal host-process sandboxing or protection from arbitrary mutable Scheme/transitive code in a trusted Guix recipe.
- Survival of PGTK display/compositor disconnection (different from frame closure).

Review these on the host before final cutover. The old directory remains the rollback; credentials/database migration is explicit, not performed over running writers.
