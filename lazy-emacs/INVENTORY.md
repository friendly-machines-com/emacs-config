# Current configuration functionality inventory

Date: 2026-10-03. Review-stage inventory; no replacement configuration has been implemented. Original files were not changed. Credentials were not decrypted or reproduced.

**Scope update:** this inventory documents the original configuration, not the final retention list. See [confirmed decisions and clarified questions](DECISIONS.md) and [updated plan](PLAN.md) for the user's subsequent removals, mandatory startup reminders/indexing, deferred mail/music, standard mu4e headers and no-extra-toolbar-row requirement.

## How to read this inventory

The inventory is split across this file and the detailed companion reports:

- [GUI-managed init.el: every saved variable/face, procedural setup and file association](INVENTORY-init.md)
- [Hand-managed custom.el lines 1–2000 and local implementations loaded there](INVENTORY-custom-1.md)
- [Additional local modules loaded from init.el](INVENTORY-local-modules.md)
- This file: startup/security, email, custom.el lines 2001–3801, integration/precedence, migration dependencies, and questions.
- [Proposed architecture, modern Emacs APIs and test plan](PLAN.md)

All lines of early-init.el, init.el, custom.el and email.el were read. Explicit local modules were followed. This inventories configuration and its local extensions, not every internal feature of third-party packages. Large vendored dependency implementations are not a comprehensive code/security audit. Source line references refer to the original files at inspection time.

**Configured, actually activated, and still used are different things.** Missing files/packages can stop old loading; conditional/deferred setup and later setters change effective behavior. No old configuration was executed in this investigation, because doing so can start services/processes, read credentials and install global parser advice. In particular, the Guix checkout copyright file at custom.el:650 is absent **in this inspection container**, not proven absent on the normal host. Treat everything after that point as configured functionality to preserve, not as disposable dead code.

Correction to the companion reports: `:ensure f` is not a false argument or simply an unbound-variable case. Macro expansion using the actual Emacs 31.1 built-in use-package produced `(use-package-ensure-elpa 'magit '(f) 'nil)`: it requests package **f**. Use `:ensure nil` for Guix ownership.

## A. Startup and security: early-init.el

| Lines | Configured behavior |
| --- | --- |
| 2–4 | Prepend local org-mode/lisp to load-path. Its version file reports Org 9.8-pre (`release_9.7.39-855-g1ef59f`). This supports new Org preview APIs used by the agent renderer. |
| 6–27 | After agent-shell-anthropic loads, disable client text-file read/write capabilities. Container command examples and old Claude-command setter are comments, not active containment. |
| 29–47 | After agent-shell-loki loads, likewise disable text-file capabilities; set Loki ACP executable to the local source checkout's loki-acp. Runner examples are commented; actual active runner integration is guix-workspace.el. |
| 49–50 | Set debug-on-quit true and start CPU profiler. init.el's final line sets debug-on-quit false, so its final value conflicts with this early setting. |
| 52–106 | Add ~/.emacs.d/icons to image-load-path; require tab-line; construct HiDPI close/new/left/right XPM buttons and force mode-line update. Close uses a evaluated backquote expression; the other quoted image forms contain literal string-append forms, so their intended path calculation requires verification. |
| 108–146 | Global Tools menu additions: View trash (Trashed), LLM conversation (GPTel), street map (OSM), music browser (EMMS), weather (Wttrin), Maxima algebra, serial terminal. Elfeed/emms alternatives are comments. |
| 162–166 | Replace tool-bar-setup so only a scaled separator-image expression is initialized; workaround for a huge separator/icon upsetting HiDPI toolbar layout. |
| 196–207 | Detect a real live user frame, excluding daemon terminal-frame, child and tooltip frames. This active version does not require visibility. |
| 209–241 | On headless input attempts, build backtrace (print-level 12, print-length 100), append to *headless-interaction-backtrace*, emit to external debugging output, and call the reader with inhibit-interaction true. |
| 251–267 | Abort active minibuffer if the last real frame is deleted. After server loads, advise read-from-minibuffer, read-char and read-char-exclusive; register after-delete-frame hook. read-event deliberately excluded (also handles DBus), and comment says read-key can still hang. |

The numerous older daemon/headless variants in comments are not active features. The security policies and prompt guard need early ordering; that does not mean every current menu or tab-image statement must remain in early-init.

## B. High-level configured workflows (combined entry points)

These are all retention candidates, not a proposal to drop rarely used packages:

1. **PGTK GUI and window management:** light Solarized theme; customized fonts/faces; variable/mixed pitch; line spacing; glyphless boxes; spacious padding; modern fringe definitions; bar cursor; visual bell; smooth ultra scrolling; mouse-autoselection; tabs with close/next/previous/full-path tooltip and embedded window toolbar; project-colored mode lines/current line numbers; popup routing/Popper; back/forward mouse buttons; MRU-other-window command; custom daemon frame deletion/save/buffer handling; headless prompt guard.
2. **Everyday editing:** Wakib CUA-like keys and prefix relocation, CUA/transient selection, custom yank-media/plain-text paste, undo-redo, save/file/search/debug function keys, line numbering, form-feed pages, comment tags, Smartparens, Outshine, symbol prettification, indentation detection/guides/outlining, formatting on save, very large file handling, trash/delete-file-and-buffer, automatic file skeleton insertion, backups/autosaves and persistent navigation.
3. **Completion/search/navigation:** Company, Vertico, Marginalia, Orderless, Consult, Embark, Wgrep multi-file editing, ripgrep/Xref, Which-key, shell/comint autosuggestions, snippets/Yasnippet/Tempel, Jinx spelling and some legacy ispell region rules.
4. **Projects/Guix/environment:** Projectile, built-in project.el, Treemacs/projectile/LSP/icons, npm/Rails/Pascal/Lazarus/Dub project types, compilation colors/scrolling, Guix workspace/container wrapping and authorization, buffer-env/envrc environment inheritance, REPL executable resolution, Guix snippets/copyright and build-failure navigation, crate helper commands.
5. **Development:** Tree-sitter routes/grammars, Rust/Rustic/rust-analyzer hints/Clippy, C/C++/ccls, Python/Jedi/Eglot/Flycheck/Django/venvs, Scheme/Arei/Geiser/Guile, SLIME/Common Lisp, JavaScript/TypeScript/Web/Vue/Volar/Vetur/MMM/PHP/Sass, Julia Snail/Jupyter/notebooks, Pascal, Ada, VHDL extensions/LSP/beautification; DAP/debugpy/native GDB/GDBserver plus GUD dispatch. Not every declared server is automatically started in every mode.
6. **Git/forge:** Magit, Forge, PR Review, Codeberg Fj authentication, generated Lisp-aware commit messages, save refresh, staging-region keys, status and rebase toolbars, Wakib conflict fix.
7. **Org task management:** workflow/logging/tags/priority colors; capture templates including IDs, meetings, code tasks and org-protocol; agenda/custom views and super-agenda grouping; clocks/notifications/checklists; source editing and Babel; link handlers; publishing/blog/docx tools.
8. **Knowledge/documents/math:** Org Node/Mem/IDs/backlinks/daily and CREATED series; Org Noter/PDF Tools/annotations/page locations; PDF/EPUB place restoration; Xenops and new Org LaTeX preview; AUCTeX/LuaLaTeX, CD-related packages only where active; Maxima, Gnuplot, PlantUML/Ditaa/Graphviz/Jupyter; MathML in SHR; Kiwix/EWW and web-to-note/search helpers; Wolfram and McPhase-specific tools.
9. **Mail/contacts/news:** mu4e account/folders/bookmarks/mail sync/SMTP/MIME/HTML/Org links; custom vtable headers and toolbars; message composition; EBDB contacts; Gnus/Gmane NNTP/offline agent/threading/scoring-compatible UI and toolbars; Debbugs control/browse and bug-reference integration.
10. **Feeds/media/applications:** Elfeed feeds/custom printer/Org links; Elfeed Tube captions/metadata/MPV follow; EMMS library/player/tags/covers/playlists; Mediainfo mode/file routing; MPV video URL handlers; EAT/Eshell/term/serial, process monitor Proced; street maps/weather/trash GUI entries.
11. **AI:** local GPTel streaming llama endpoint and rewrite; local llama-cli completion (named copilot.el but not GitHub Copilot); agent-shell Loki/Claude-related infrastructure, auth-source environment keys, containment, session restore, agent math rendering, pending-permission/tool-block/process management menus and buttons; Claude Code IDE path setting.

Exact values and individual bindings in the first two entry files are in the companion reports. Remaining detailed behavior follows.

### B1. Additional small workflows and templates

- **Eshell commands** (custom.el:264–295): `e` opens one or more files, with Eshell help/file options and numeric conversions disabled; `nd` creates a directory including parents (or reports it exists), supports verbose/help and then changes into it. Its single-argument signature must be preserved or intentionally repaired.
- **Auto Insert** (1356–1441): globally enabled, `auto-insert` other, no query. Java files get GPL SPDX/header/class/main skeleton; Vala gets GPL SPDX/header/GTK window/button application skeleton; Scheme files get Guix package-definition imports/package/version/source/build/inputs/description/license scaffold; manifest.scm gets a manifest listing Rust/rust-analyzer/ccls/OCaml LSP/GCC/GDB/rr/TeX minted/basic/dvisvgm/Python LSP/tidy-html. Specific manifest registration follows generic Scheme, so priority matters. These templates are live functionality, not scratch notes.
- **Agenda helper** `air-org-skip-subtree-if-priority` supports the custom priority views (1058–1067). **Org spelling command** `endless/org-ispell` runs legacy ispell while skipping property drawers, verbatim and source blocks; Jinx is an additional, not automatically equivalent, workflow (1770–1780).
- **Late-loaded scientific/file-mode behavior**: McPhase reassigns even broad .txt/.dat/.ini/.in/.out extensions globally and supplies filename-specific action sets; Ada defines a custom lightweight ada-mode, overriding that conventional symbol. Keep these associations/implementations unless explicitly changing them. Wolfram provides C-j region evaluation. The additional local-module report enumerates all scientific runners, inputs and toolbar branches.
- **Late-loaded document behavior**: autoresize.el adjusts PDF/DocView window width on page/window-configuration changes, capped at a GUI-customizable 120 characters. This is window geometry, separate from PDF image zoom.
- **Git/Guix helpers**: commit generator replaces/saves qualifying staged-one-Lisp-definition commit messages; failed-build helper recognizes compilation output and offers an Embark directory action that can normalize/rename/delete build directories. These invocation side effects require dedicated tests, not mere lazy file loading.

Further companion-report clarification: disabling the *frame* toolbar does not prevent maps being shown by the selected-tab `window-tool-bar-string` integration. McPhase's toolbar map is therefore part of the configured GUI even though tool-bar-mode is off.

## C. Email module: email.el (all 99 lines)

- `friendly-machines-deliver-to-maildir` actually calls `smtpmail-send-it`; despite its name, it is an SMTP delivery function, not a direct Maildir writer (8–9).
- `mail-user-agent` is mu4e-user-agent; message-mail-user-agent true (11–12).
- Mail root ~/Mail, downloads ~/Downloads, sync executable in the jma-mail source checkout; interval 240 seconds. Headers deduplicated/auto-updated, images and full addresses shown, HTML preferred, fancy characters enabled, filenames changed when moving. Composer signature auto-inclusion disabled; message buffers killed on exit; signature path still ~/.emacs.d/.signature; STARTTLS uses GnuTLS (14–31,82–89).
- One context, friendly-machines.com, matching addresses in from/to/cc/bcc; context entry/exit messages; configured sender, sent/draft/trash/archive folders; sent copy retained (37–80).
- SMTP host smtp.dreamhost.com, port 587, STARTTLS, PLAIN/LOGIN mechanisms, always EHLO/authenticate, credentials required. Both message-send-mail-function and send-mail-function use the SMTP wrapper. No passwords reproduced (47–67).
- Context selection pick-first; composer initially always-ask, then **overridden to ask** at line 89. Per-context sync uses `jma sync`, while base command earlier omits sync (35–36,67,88–89).
- Folder shortcuts: inbox, sent, trash, Archives, drafts, Hobby/Shellbox, Work/Friendly_Machines, Work/Guix/Devel, Work/Guix/Patches, Work/Physics, Work/TU_Tieftemperatur and Work/Oxide. Duplicate s and i keys; Archive vs Archives differs (69–80).
- Org mu4e HTML conversion enabled (91).
- Five bookmarks: unread excluding trashed, all unread, today, last seven days, image MIME messages (93–99).
- SMTP queuing is mentioned only in comments; no active standalone queue configuration here.

## D. Remaining hand-managed custom.el: lines 2001–3801

### D1. Document, file and scrolling utilities

- Redefines Org Noter location page/top/left accessors for integer/page-dot-top/page-top-left locations and PDF Tools sentinel handling (2007–2031). Together with earlier precise insertion/start-location/annotation hooks, this is a version-sensitive Org Noter/PDF compatibility patch, not just preference data.
- `delete-file-and-buffer` asks confirmation, deletes current visited file and kills its buffer; reports when not visiting a file. Global s-Delete binding. Global delete-by-moving-to-trash setting applies (2033–2046).
- Ultra Scroll enabled globally through an evaluated use-package form; scroll-conservatively 101, margin zero. Pixel-scroll-precision-mode is commented (2048–2055).
- Dired hides details by default (2715). Dirvish attributes: VC, subtree, nerd icons, collapse, git message, file time and size; declaration configures Dirvish but does not prove takeover activation (2401–2407).
- JPG/JPEG/GIF/PNG file associations explicitly use mediainfo-mode, not standard image-mode; broader media formats come from its regexp in init.el. A mediainfo file handler is commented because it broke EMMS covers (3022–3035).
- PDF auto-revert hook is registered under `pdf-view-hook`; verify actual package hook name/activation (3279).
- Trashed lazy command; yes/no confirmer, header line, date-deleted reverse sorting, timestamps `%Y-%m-%d %H:%M:%S`. Its current :ensure t conflicts with Guix ownership (2359–2366).
- `my/substitute-unnecessary-latex` is an interactive whole-buffer cleanup intended to unwrap display `\\text{...}` prose (2873–2879).

### D2. Mail UI and vtable

- Eagerly requires mu4e and loads mu4e-vtable.el (2057–2059).
- All message buffers disable auto-fill and set line-move-visual nil (2062–2064).
- mu4e **view toolbar replaces** the local map: reply-all, reply, forward, mark move, mark follow-up flag, mark trash, execute marks, previous/next message. Deletes/other proposed items are commented (2066–2180).
- mu4e **headers toolbar copies** current/global map and adds compose-mail, reply-all/reply/forward, mark move, execute-all marks, mark trash, rerun search. Flag/read/unread/delete alternatives are inactive (2183–2264).
- Composer described as having a good toolbar, but the later message-mode hook also installs a replacement map, so inherited hook/order interactions must be tested (2266–2267,2617–2635).

`mu4e-vtable.el` (all 79 lines):

- Requires vtable; removes header-line face box globally and makes mu4e header highlight weight normal (3–10).
- Buffer-local vtable instance cleared after mu4e header clear (12–18).
- Overrides async header append: create/update table with Date, Flags, From width 20, threaded Subject; rows store message plists (21–47).
- Around message-at-point fetches current vtable object when present, otherwise original function (50–55).
- Overrides update handler: find row by docid, mutate existing plist and update just that object. The is-move/maybe-view arguments are ignored; deletion/move/marking/thread redraw semantics need parity tests, not assumptions (58–71).
- Around header-line generation preserves existing header-line-format (75–79).
- Uses private mu4e APIs; preserve the extension until its intended retention and working operations are confirmed.

### D3. Scheme, feeds, bug tracking and request backend

- Arei use-package declaration with config nil; no additional behavior beyond its earlier require. Scheme toolbar hook makes a copied map but returns nil without assigning it: **currently a no-op**. Guix-build-at-point/REPL buttons are TODOs (2269–2301).
- Elfeed Tube demanded after Elfeed; calls setup; F fetch and save-buffer remap to Tube save in search/show maps. Tube MPV follow on C-c C-f and where on C-c C-w in show map (2303–2323).
- Gnus summary/article buffers enable bug-reference-mode (2325–2328).
- Debbugs adds Org bug view menu for send-control/display-status; eagerly requires Debbugs and bug-reference; registers mail regex `bug#<digits>` linked to debbugs.gnu.org with no header restriction (2330–2348).
- bug-reference normal and programming hooks enable debbugs-browse-mode; init.el's URL regex additionally covers issues.guix.gnu.org (2350–2355).
- Request backend url-retrieve rather than curl; el-job debug level 1 (2357,2368).
- Replaces `debbugs-gnu-send-control-message`: obtains bug ID from current view/local query/fallbacks, builds control message, invokes configured send function, then prints sent body. This supports control messages from Org bug view (3085–3110).

### D4. Org Babel, contacts and Gnus

- Overrides Ditaa executor: require :file, write temp source, invoke executable `ditaa` plus cmdline, optionally run epstopdf, return nil as file output already written. Still checks org-ditaa-jar-path despite invoking a wrapper executable. :java is read but unused; EPS/PDF behavior needs verification (2370–2399).
- Babel languages eagerly enabled: shell, Ditaa, Python, LaTeX, Jupyter, Dot, Gnuplot, PlantUML. Additional languages in comments not active (2413–2425).
- Requires Org, ob-shell, inheritenv and advises **all** org-babel-execute-src-block through inheritenv-apply, to fix buffer-env environment loss/temp-file context (3037–3049).
- EBDB initializes; Gnus startup hooks insinuate Gnus **and mu4e**. Most other contact update/completion suggestions are commented; verify whether mu4e integration waits unintentionally for Gnus (2427–2447).

Gnus (2450–2681):

- News source `news.gmane.io`, NNTP port 119 via nntp-open-network-stream. FIXME explicitly requests forced STARTTLS, but active settings do not enforce it (2575–2578).
- Initially graphical Unicode tree and multi-column summary; **later replaced** by ASCII thread tree and final summary `%U%R %-18,18&user-date; %4L:%-25,25f %B%s\\n`; summary mode line `[%U] %p`. To prefix used for ignored sender; ignored-from-addresses is another person's name, worth confirming (2452–2470,2554–2574).
- Signature verification known; display-arrow on; startup jingle off; GCC marked read; agent on; ask-server new groups; some active file; dribble save/read always (2471–2488).
- Offline agent: uncompressed format, caching on, yes/no confirmations, not all articles, ~/News/agent, expiration ENABLE at 30 days (not all), downloaded articles marked unread, queue mail unplugged, no flag synchronization (2490–2500).
- Articles: ask before deleting browser temp; no overscroll; cursor on; descending number/date sorting; wrap; HTML width 80, automatic image cache, **images inhibited**, max proportion .7; no smileys; custom article mode line; specified visible/sorted headers; all X-Face suppressed (2502–2520).
- Asynchronous fetching, prefetch 15 (2522–2523).
- Group levels subscribed 6/unsubscribed 7/zombie 8/activate 1; ticked groups not force-listed; sort unread/alphabet/rank; custom group row/mode line; omit empty topics (2525–2536).
- Summary: do not auto-select first or jump unread; ignore/suppress/persist duplicates; adopt false roots; fuzzy subject thread gathering; descending date/number thread sort, ascending date subthread sort; no hidden subtree/subject ignore; today/yesterday/ISO date formatting (2538–2557).
- Group hooks: topic mode, selection timestamp. Group/summary/browse buffers highlight current line (2580–2584).
- Article keys: i show images, s save MIME part, o copy part. Group n/p next/prev, M-n/M-p topics. Summary Delete delete article; n/p articles; N/P unread; M-n/M-p threads; C-M-n/C-M-p groups; C-M-^ refer thread (2596–2615).
- Message toolbar replacement: attach, spell, sign, encrypt, send-and-exit, kill buffer; draft button commented (2617–2635).
- Article toolbar replacement: reply-all/reply/forward/force verify-and-decrypt (2637–2652).
- Summary toolbar copy plus new post/reply-all/reply/forward; previous/next TODO (2654–2681).

### D5. Git, keys, compilation and diagnostics

- git-commit-setup-hook calls `my/generate-lisp-commit-message` (2683); generator module loads later from init.el. Preserve registration/load order.
- Wakib Escape overriding binding changed to keyboard-escape-quit (2688).
- Programming map C-c s → magit-stage-region, C-c c → magit-commit; Wakib may relocate/override effective prefix (2717–2719).
- Compilation scrolls output; ansi-color-for-compilation-mode true; filter calls ansi-color-compilation-filter (2721–2728).
- Proced deferred: colors/tree/descent on, user filter, visible auto-update at one second; mode hook toggles auto-update (2736–2748).
- Flymake on Emacs Lisp mode; end-of-line diagnostics, margin indicators `!/?/i` with compilation error/warning/info faces. Other programming modes separately use Flycheck/Eglot/LSP (2750–2759).
- After Magit: relocate C-c prefixes to C-d in mode, section, diff and hunk maps and clear original C-c to preserve Wakib copying at text-property-map precedence (2968–3004).
- Magit status toolbar replacement: fetch, pull, push, commit (3006–3020).
- Magit-mode after-load adds global after-save status refresh (append), and repository save prompting (3350–3352).
- Fj after-load targets Codeberg/daym; obtains token from encrypted auth-source by API host at feature load (3354–3363). No token included here.
- Git rebase eagerly required; replacement toolbar pick/drop/reword/edit/squash/fixup/kill/noop/exec/move-up/move-down/cancel/finish (3547–3576).

### D6. EMMS GUI

- Browser hook tab-line + variable pitch; menu browse album/year/genre/artist/composer/performer, add tracks, add/play, collapse/expand. Toolbar copies current map and adds browser add-and-play. That call has an extra positional symbol argument; verify helper accepts/plist parses it (2761–2785).
- Playlist hook tab-line + variable pitch; menu play-smart, seek back/forward, pause, previous/next, stop, edit tags, external tag pipe (2787–2802,2860–2861).
- Playlist toolbar copies map and adds play/rewind/fast-forward/pause/previous/next/stop (2804–2859).
- Randomization/volume/reordering/editing/save/playlist management toolbar ideas are comments/TODOs, not configured buttons. Native EMMS commands remain available after loading.

### D7. Completion, tabs, chrome and spelling

Consult declaration (3113–3213), all bindings retained:

| Prefix/map | Commands |
| --- | --- |
| C-c | M-x mode-command; h history; k kmacro; m man; i info; remap Info-search |
| C-x | M-: complex-command; b/4 b/5 b/t b buffer destinations; r b bookmark; p b project-buffer |
| registers/yank | M-# load; M-' store; C-M-# register; M-y yank-pop |
| M-g | e compile-error; f flymake; g/M-g goto-line; o outline; m mark; k global-mark; i imenu; I multi-imenu |
| M-s | d find; c locate; g grep; G git-grep; r ripgrep; l line; L line-multi; k keep-lines; u focus-lines; e isearch-history |
| Isearch map | M-e and M-s e history; M-s l/L line searches |
| minibuffer | M-s/M-r history |

- Register preview overridden by consult-register-window with .5s delay; both Xref display functions consult-xref (3173–3184).
- Theme preview debounce .2 seconds; search/man/bookmark/recent/Xref/file sources .4; narrowing `<` (3197–3208).
- Minibuffer C-c C-e invokes `my/grep-edit-results`: if buffer string contains Ripgrep, schedule Embark export then Wgrep editing with zero-delay timers. Other search results ignored (3067–3080).
- Global tab-line demanded/enabled; C-ISO-lefttab previous, C-Tab next; init.el sets close action kill-buffer (3215–3225).
- Built-in project/color required; hash project root or default-directory into HSL→hex; remap active mode line and current-line-number background, white text. Hooks find-file, Dired, change-major-mode and temp-buffer-setup (3253–3278). Repeated remapping may accumulate; modeline color is user-visible behavior.
- Jinx config hooks text/prog/conf/Org, M-$ correct and C-M-$ languages; duplicated generic and Org hooks are harmless but should be consolidated (3281–3286).
- Project/Org-clock custom mode-line constructs show selected-buffer clock marker and project name; marked risky-local-variable; assigned to **dummy-mode-line-format**, not mode-line-format, so no display is proven (2881–2922).
- Tools menu cleanup on startup removes rgrep/EDE/Semantic/directory search/simple calculator/games in favor of the chosen alternatives (3051–3065).

### D8. Org appearance/math/tag maintenance

- Org text scaling +1 at every org-mode hook invocation (2690–2697).
- Xenops converters: lualatex with shell-escape to DVI, then dvipng or dvisvgm; SVG sizing 1.7×1.5, PNG 1×1; PDF/pdflatex→ImageMagick fallback also shell-escape (3295–3324). This is externally executable content, not only a face preference.
- Org Modern Indent hook depth 90; Org Modern on Org and agenda finalize, hide-stars nil, no table styling, *→bullet and +→triangular bullet. Current :ensure t must become nil for Guix (3326–3342).
- Org tags maintenance commands: remove FILETAGS duplicates in entry, whole buffer, directory (directory saves/kills files); collect unique tags across a directory and display *Org Tags* (3380–3429).
- `jupyter-session-with-random-ports` override: run `jupyter kernel` via start-file-process (TRAMP-capable), parse connection file, read info, interrupt/wait cleanup/delete process, replace key with new UUID, return jupyter-session. Private Jupyter API and macro dependencies must be loaded before use/byte compilation (2924–2966).

### D9. Environment, terminals, language specifics and one-off helpers

- `guix-move-crate-definitions`: interactive repository-specific transformation using a fixed checkout/grep-results.txt; moves unique rust definitions from crates-build.scm to target files and saves them. It is active M-x functionality, even if it looks like a historical one-off (3431–3486).
- EAT: xterm-256color, customized ANSI bright blue, enable Eshell terminal/visual integration (3488–3496).
- Hooks installed after buffer-env-autoloads loads: hack-local-variables/comint → buffer-env-update. The autoload feature-name assumption may make registration fragile across Guix package versions (3498–3505).
- Org Download eagerly required; enables drag/drop in Dired (3507–3509).
- Claude Code IDE CLI points to the local agent-c node_modules .bin/claude after feature load (3511–3512).
- VHDL tree-sitter → lsp-deferred and vhdl-ext-mode. Extension features font-lock/hierarchy/LSP/beautify/navigation/template/imenu/which-func/hideshow/time-stamp/ports; setup invoked on load. Classic VHDL hook removes format-all-buffer locally and adds native beautifier before save; remapping to TS may bypass classic hook (3514–3535).

### D10. Agent Shell and mathematical rendering

- Eager loads agent-shell-loki.el and agent-shell-org-math.el (3578–3579).
- Agent Shell header style text, full restore verbosity; register Loki config, preferred `(preselect . loki)`; every agent buffer enables Org math minor mode (3581–3604).
- Older visibility/headless variants in lines 3606–3671 are wholly commented. Active headless safeguard is in early-init.
- `my-agent-shell-kill-process-at-point`: kill live text-property agent-shell-process, else choose among process names prefixed agent-shell; errors if none. Its fallback can include a session process rather than a specific tool, so desired semantics require verification (3674–3694).
- Agent menu: stop turn/jobs, kill process, jump pending permission, next/previous tool blocks, switch/new session, list all processes, clear buffer (3699–3725).
- Agent replacement toolbar: stop-all, kill-one, pending action, previous/next tool, switch agent, new agent (3730–3801). Global launcher actions disappear under replacement rather than composition.

`agent-shell-loki.el` (all 144 lines):

- Requires shell-maker, ACP and auth-source; autoloads agent config maker.
- GUI-customizable command/environment; config identifier loki, Loki prompt/buffer/modeline/icon, welcome banner and client factory; public `agent-shell-loki-start-agent` starts new shell (41–89).
- Retrieves API-key variables from auth-source by host key, supplies OPENAI/ANTHROPIC/GROQ/OPENCODE/ZHIPU values only when present, appends user-defined environment. Secrets looked up at client creation, not inventory/startup (94–115).
- Rejects obsolete agent-shell-loki-command, validates buffer, uses agent-shell--make-acp-client where guix-workspace containment advice operates. Banner face references fixed-lokitch (likely typo for fixed-pitch) (106–140).

`agent-shell-org-math.el` (all 812 lines):

- Requires agent-shell-markdown plus lightweight libraries; minor mode loads org-latex-preview and demands `org-latex-preview-place`, not merely a numeric version label (68–83,149–182).
- Customizable fenced language list default math (not general latex documents); single-dollar inline enabled; AMS/math/bm/xcolor preamble; dvisvgm default or dvipng/imagemagick (85–123).
- Claims raw $$, bracket display, parenthesized inline and guarded single-dollar math; ignores escaped delimiters/currency/code/fences/empty fragments; completed math fences become equation*/align* (or retain explicit environments). Preserves agent transcript field/text properties and original Markdown for copy-as-markdown (308–613).
- Registers external Markdown renderer and Org finish hooks; uses markers/captured text and serial timer queue so streaming and cached synchronous completions don't recurse/shift claims. Holds streaming watermark at unclosed math, respects code spans (157–182,213–289,615–689).
- Caches through Org preview, adopts surrounding colors; errors remain fringe/help-echo. Recovery queues missing images without duplicating in-flight conversion; deactivation removes only owned overlays and timers, leaves frozen source claims (184–211,691–808).
- Public commands `agent-shell-org-math-render-missing` and `agent-shell-org-math-clear-error-markings`; latter clears error indications only from owned previews already showing images (291–306,732–808).
- Separate `agent-shell-xenops-math.el` exists but is **not loaded by these entry points**. Do not discard without asking about manual use.

## E. Guix workspace containment detail

`guix-workspace.el` (all 152 lines):

- Nearest parent manifest.scm defines workspace; helpers resolve manifest and authorization-file path (30–43).
- Physical absolute directory exact-match authorization against shell-authorized-directories; skips blank/comment/relative lines. Interactive authorization appends directory to file (45–89).
- Guix runner list uses `-C -N -W`, manifest and -- separator. Unapproved workspace errors; no manifest returns nil (91–101).
- Compiler command wrapping uses /bin/sh inside Guix and shell-quotes manifest/command, but joins extra args unquoted. **Compilation without a manifest runs unchanged on the host**; this is current policy, not necessarily an agent policy (103–127).
- Global compilation-start advice installed idempotently. After agent-shell loads, client factory gets configured runner or manifest-derived runner; if neither exists, errors **before creating the client** (129–142).
- Extra arguments share Claude/Codex/Loki config and source, host Emacs socket, Guix logs/store state and /tmp, preserve names ending _KEY/_TOKEN/_PAT, and include emacs-minimal/Claude ACP/Codex ACP/Python/ripgrep. Some shares explicitly marked dangerous in source. This containment isn't equivalent to no host access; preserve only after confirming the intended boundary (7–28).
- Both authorization and environment-mutating buffer-env hooks matter to this workflow. Security setup must precede client instantiation even when UI/package setup becomes lazy.

## F. Persistence, assets, package ownership and exclusions

### Keep or decide migration explicitly

- Credentials encrypted `.authinfo.gpg` (do not decrypt in documentation); signature; auth-source preferences and trust decisions.
- `abbrev_defs`, bookmarks, EBDB contacts; Org ID locations/Org persist state; saved PDF/EPUB locations; recent files, history, shell histories, project lists/frecency/bookmarks; Forge DB; EMMS playlists/history/scores and caches with user decisions; Transient state; network-security decisions; LSP/DAP session/breakpoint state if wanted. These are not automatically disposable scratch.
- Live icons, including tabs/mail/McPhase assets; local snippets/templates; external Guix snippets/templates/copyright; required modified Org/Xenops/Elfeed Tube/Wakib/etc. checkout versions. Test state must not share writable SQLite files with an existing Emacs.
- Fonts: Noto Sans Mono/Noto Mono, Atkinson Hyperlegible, Dijkstra Italic plus Nerd Icons; symbols and GUI icon/HiDPI dependencies.
- External tools include Guix, authorized manifests; ripgrep; compiler/build/project executables; ccls/rust-analyzer/debugpy/GDB; Lisp/Scheme/Julia/Python/Jupyter kernels; Pandoc/Curl; TeX/latex/lualatex/pdflatex/dvisvgm/dvipng/ImageMagick/epstopdf; Ditaa/Dot/Gnuplot/PlantUML; MPV/libtag/mid3iconv/Mediainfo; mu/jma/SMTP/GPG; Kiwix/ZIMs; Maxima/Wolfram/McPhase. Missing tools should be diagnosed per feature, not installed by use-package.

### Not automatically migrate

- Crash core, autosave/backup variants, most ALL-CAPS notes, temporary debugging transcripts, local elpa/eln/autofmt generated caches, obsolete database backups, inactive experimental variants (`old-*`, `*2.el`, etc.), source-side prompt/cache sidecars.
- Important exception: a file that looks experimental may supply an M-x command or be manually loaded. Ask about desired functionality rather than deleting on appearance alone.
- Guix owns normal package installation; use-package is only declaration/loading orchestration. Current init manually initializes package.el with empty archives/signature checking disabled, but later :ensure t/bare :ensure/:ensure f declarations conflict with that intent.

## G. Questions before implementing the replacement

Please answer in groups; unmentioned active features will be retained by default.

1. **Usage scope:** Is the default “retain every active/configured workflow above” right? Specifically still used: Gnus/Gmane; EBDB; Kiwix; McPhase; Wolfram; Pascal/Lazarus; Ada; local llama-cli completion; local GPTel llama endpoint; Claude Code IDE alongside Loki? Any that can be explicitly omitted?
2. **Manual/one-off commands:** Keep the crate-moving helper, redundant-Org-tag cleaners, Google-result-to-kill-ring, web-to-NotDeft importer, DOCX keyboard-macro export/blog template, dynamic `unbreak` menu builder and optional modern-fringes mode? Is inactive agent-shell-xenops-math or another scratch-looking module manually used?
3. **Containment:** Keep present Guix runner shares (especially host Emacs socket, /tmp, Guix state and AI config directories)? Should Loki perform its own containment in addition to guix-workspace? Should compilation remain host-allowed without a manifest? Agent clients currently fail closed without a runner; that should remain invariant.
4. **Daemon:** Do you use PGTK via a daemon/emacsclient as these guards suggest, and should the save/kill-buffer-on-frame-close behavior remain? Should invisible real frames count as input-capable? Keep always-on CPU profiler/backtrace instrumentation or make profiling opt-in?
5. **Mail:** Keep the vtable header replacement? Does marking/trashing/moving/threading/selection presently work as intended? Resolve Archive vs Archives and duplicate folder shortcut letters; composer ask vs always-ask; signature location. Must 240-second mail polling begin at startup or only after first mail use?
6. **Background timing:** Must Org Notify, Org Node/Mem indexing and recursive EMMS music import happen on startup, or may each start on first use? Deferring them changes background semantics unless approved.
7. **Language stacks:** Keep Python Eglot+Jedi+Flycheck and Rust/LSP as they stand, or choose one completion/diagnostics/formatting policy per language? Keep both Vue clients? Are current Tree-sitter mappings with “doesn't work” comments now useful? Retain the global LSP booster bytecode advice, or replace/remove it as a deliberate security change?
8. **GUIs/toolbars:** Keep global actions everywhere plus buffer-context actions, and the selected-tab-embedded placement? Prefer a separate composed toolbar row? Which global items/order are mandatory? Tabs and sticky Org heading must coexist, not overwrite each other.
9. **Trust/export:** Preserve no-confirmation Babel and shell-escape LaTeX? Gnus STARTTLS needs explicit decision. Keep current safe directory/local-variable/manifest-hash approvals? Publishing exclusions are not an assurance of confidentiality.
10. **Persistent state/testing:** Use fresh isolated state while testing, then migrate selected durable data at final switch? Any history/databases/bookmarks you specifically do not want retained?
11. **Known inconsistencies:** May obvious bugs be corrected as separately documented intentional changes (completion-category typo, Tempel list test, literal publishing-directory forms, quoted tab image paths, :ensure f, duplicate C-F11 assignment, nonstandard yank replacement, ineffective elisp hooks)? Otherwise preserve observed behavior until individually approved.

## H. What has and has not been verified

Verified with the Guix-resolved PGTK binary: Emacs 31.1/build features, built-in use-package/window-tool-bar, Custom saved-setting behavior from implementation, new user-lisp/frame/lookup APIs, Guix site-start ordering/code, and syntax balance/nonexecuting reading of the four principal files.

Not yet verified: current real GUI startup time, actual host package/profile resolution, live use of every feature, GUI rendering parity, email delivery, external service behavior, containment runtime behavior, or whether any compatibility patch is now unnecessary. Those require the implementation/test phase after the questions above.
