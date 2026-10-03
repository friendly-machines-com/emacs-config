## Scope and interpretation

Read **every line 1–2000** of `custom.el` in chunks, including comments. Its lexical-binding declaration is at line 1. I did not inspect the second half. Line 2000 closes the Org Noter/PDF integration block, so the requested boundary does not split an unfinished form.

References below are to `custom.el` unless another file is named.

**Static configuration is not proof of runtime activation.** In particular:

- An unconditional `load-file` at **650** targets a currently missing copyright file. Ordinarily this stops evaluation there; later settings below describe intended/configured behavior.
- Earlier missing dependencies could stop loading sooner.
- `use-package` loading depends partly on globally configured defaults, which were outside this inspection.
- No secrets or credential contents are reproduced.

## 1. Startup, environment and local loading

### Home-directory protection and file lookup — 5–88, 1233–1247

- Calls `abbreviate-file-name` to prime its home-directory cache, then stores the expanded home in `quux-home`.
- Defines `unbroken-locate-user-emacs-file`: uses that saved home for old-file fallback and directory creation; creates configuration directories with private permissions and emits a once-per-session warning on failure.
- **That replacement is only defined, not installed** in this half.
- Adds the configuration’s `icons` directory to `image-load-path`.
- Defines `wrap-with-global-env`: replaces a function with a wrapper using default/global `process-environment` and `exec-path`, preserving its interactive specification.
- Applies that wrapper to the **existing** `locate-user-emacs-file`, not the `unbroken-…` definition.

### Eager loads and path additions — 32–33, 248–249, 523–697

Explicit early requirements include:

- `org-protocol`, `window-tool-bar`;
- `eshell`, `em-unix`;
- `smartparens-config`, `pulsar`, `treemacs-nerd-icons`, `mh-e`;
- local `guix-workspace.el`, `lisp/unbreak.el`, `modern-fringes.el`;
- `treemacs-projectile`.

Later configured loads include:

- Guix checkout’s `etc/copyright.el`;
- local `dap-gdb`, `ssass-mode`, `bar-cursor`;
- local Elfeed Tube and MPV integration;
- `arei`, Xenops, `ob-python`, `wakib-keys`;
- local `lisp/copilot.el`, `opascal`, `python-django`;
- `request`, `dom`, Org Notify, `autoinsert`;
- Kiwix, `mpv`, SHR Math;
- VLF, LSP/Volar/Vetur, Web Mode, MMM, `ox-publish`, `uniquify`.

Added paths include configuration `lisp/`, package checkout directories, and a Guix profile tree-sitter library directory (**592**).

### Guix snippets and authentication — 631–650

- Deferred Auth Source configuration restricts `auth-sources` to the configuration’s encrypted authinfo file; its contents were not inspected.
- After Yasnippet loads, adds Guix checkout snippets.
- After Tempel loads, adds Guix templates.
- **Bug:** `(listp 'tempel-path)` tests the symbol, not the variable’s value, so the list-normalization branch always executes.
- The unconditional copyright load at **650** points to a file not present locally.

## 2. Editing, completion and display

### Clipboard replacement — 100–121

- Defines a UTF-8 text handler for `yank-media`.
- Remaps `yank` globally to `yank-media`.
- Replaces the default media-handler list with a single UTF-8 plain-text handler.
- **Redefines `yank` itself** to call `yank-media`, ignoring its argument and omitting the normal interactive declaration.
- Consequently ordinary yank prefix behavior and callers expecting standard `yank` semantics change. Replacing the handler list may remove previously registered media handlers.

### Mode hooks — 10–15, 182–235

- Comint and Eshell: `capf-autosuggest-mode`.
- Variable pitch: Org, Rustic, Treemacs, nXML, JS, CSS, HTML, MHTML and Python.
- Emacs Lisp: Outshine.
- Python: `code-cells-mode-maybe`.
- Local cell boundaries: three-or-more semicolons in Emacs Lisp; two-or-more hash marks in Python.
- Notebook conversion uses external Pandoc between Org and IPYNB; comments warn it is not round-trip-safe.
- All programming modes: line numbers and Comment Tags.
- Jupyter: demanded, but gated on both Org and Python being loaded.

### Appearance and window placement — 237–243, 549–610

- Spacious Padding enables its mode and customizes active/inactive mode-line fonts.
- Pulsar uses its blue face and pulses on minibuffer setup.
- Sets default-frame foreground color.
- Loads Treemacs Nerd Icons theme.
- **Replaces** `display-buffer-alist`, rather than extending existing rules:
  - messages and scratch: right side, quarter-width;
  - warnings: reuse/right side;
  - shells: same window, visible-frame reuse;
  - Projectile: intended quarter-height side window, but its action-list nesting looks malformed.
- Then prepends a rule suppressing exact Warnings/Compile-Log buffers, overriding the preceding warnings display rule.
- Disables native Python completion for specified Python/PyPy interpreter names.
- Enables visual bell.

### Later editing/completion — 1563–1616

- Default line spacing becomes `0.2`.
- Form Feed mode hooks: Perl, Python/classic and tree-sitter, Scheme, Lisp, Fortran, JS base, C tree-sitter base, Ruby/classic and tree-sitter, TypeScript/classic and tree-sitter, Java, Go variants, Haskell, C#, Bash tree-sitter, Objective-C, Rustic/Rust, Julia, Org and `elisp-mode`.
- Smartparens hooks: Scheme and `elisp-mode`.
- **Likely ineffective hook:** standard Emacs Lisp uses `emacs-lisp-mode-hook`, not `elisp-mode-hook`.
- Savehist, Vertico and Marginalia are enabled through `after-init` hooks; if installed after that hook already ran, they will not retroactively activate.
- Orderless configuration sets completion styles to `(orderless basic)` and clears category defaults.
- **Typo:** `completion-category-overrride` is not the standard overrides variable.
- `:ensure f` is literal non-nil `f`, not `nil`; package-install consequences depend on the ensure implementation.
- Which-key popup placement is configured at the bottom; this call alone does not enable Which-key.

## 3. Toolbars, menus and global keys

### Permanent toolbar — 125–175

Adds buttons for:

- Consult Ripgrep;
- Embark Act;
- Magit;
- Org Store Link;
- Org Node Find;
- Org Node Grep;
- Org Agenda.

Calls the installer immediately and also registers it on `after-init-hook`. Org Node Find uses the capture icon. No major-mode-change maintenance hook is active.

### Global bindings

| Lines | Binding | Command |
|---|---|---|
| 299 | F10 | Unbound globally |
| 301–304 | Mouse 8 / M-left; Mouse 9 / M-right | Back Button backward; forward |
| 312–324 | C-a; Search; M-Search | Mark whole buffer; Consult Line; Consult Ripgrep |
| 328 | Launch1 | Embark Act |
| 331–337 | F2; F3; C-F3; M-F3 | Save; find file; find file at point; other related file |
| 432 | C-M-down | Forward sexp |
| 441 | F5 | DAP breakpoint toggle |
| 480–484 | F9; C-F9; C-S-F9; M-F9 | Projectile compile; run; test; ordinary compile |
| 514–519 | C-s / C-S-s; C-M-PageUp / PageDown | Save; previous/next form-feed page |
| 521 | C-M-s | Org Node series dispatcher |
| 653 | s-g | Guix |
| 698 | C-. | GPTel send |
| 1618 | C-c r | GPTel rewrite menu |
| 1782–1784 | C-c m / a / c | Org store link / agenda / capture |
| 1862 | M-o | Most-recently-used other window |

Later Org Node configuration changes **M-Search** from Consult Ripgrep to **Org Node Grep**, and adds **C-Search → Org Node Find** (**1277–1278**).

### Mode-specific keys

- NOV, after load: Mouse 8/9 and M-left/right navigate NOV history (**306–310**).
- PDF Tools, after load: Search and C-f run PDF Occur (**314–317**).
- Emacs Lisp: C-down-mouse-1 finds definitions at the mouse (**437**).
- Wakib is enabled globally; its overriding map binds C-f to Consult Line and C-q to quoted insertion (**693–695, 1258–1259**). Its high-precedence map can supersede ordinary global/mode bindings.

## 4. Debugging and project workflows

### Debug-key dispatcher — 339–390

`define-debug-key` chooses:

1. GUD if `gud-minor-mode` is active;
2. otherwise DAP if `dap-tooltip-mode` is active;
3. otherwise displays “No debugger active.”

After Prog Mode loads, its map receives:

| Key | GUD / DAP |
|---|---|
| C-F7 | Evaluate / evaluate |
| C-F3 | Current location / stack frame |
| C-F2 | Kill / disconnect |
| C-F8, C-b, F5 | Breakpoint / toggle breakpoint |
| F11 | Step / step in |
| F10 | Next / next |
| C-F10 | Instruction next / no DAP action |
| F8 | Continue / continue |
| C-F11 | **Watch / add expression** |
| C-F4 | Jump / no DAP action |
| `<?>` | Remove breakpoint / no DAP action |
| F4 | Until / no DAP action |

C-F11 is first assigned instruction-step, then **overwritten by watch**. Prog Mode’s C-F3 overrides global find-file-at-point. DAP detection uses tooltip mode rather than an explicit active-session check.

The separate `eval-after-load 'dap-mode` block at **392–428** contains only commented suggestions: it performs no configuration.

### REPL/environment advice — 1134–1209

- `update-repl-executable-from-env` makes each configured executable variable buffer-local, resolves it through current PATH, and falls back to its program name.
- After `envrc--update`, if Envrc mode is active, updates Julia, SBCL, Python, Guile, Racket, Chicken, GHCi and Node settings.
- Defines Projectile and built-in project-root lookup helpers; neither is called here.
- `my/ensure-line-in-file` inserts an absent line, displays the edited buffer and asks for review; **does not save**.
- Before `envrc-allow`, ensures the environment directory appears in Guix shell authorization configuration, again leaving saving to the user.

After Buffer Env loads (**1250–1256**):

- Recognizes `environment-variables`, `.env`, `.envrc`, not manifests.
- Sources `environment-variables` with export-all behavior and collects NUL-separated environment output.

### Language/project configuration — 1636–1745

- Registers a DAP Python attachment template for loopback port 5678, with workspace PYTHONPATH and integrated terminal.
- Assigns `"ccls"` to the clangd executable variable.
- Replaces Dired Launch mappings for spreadsheet, document and JVX files.
- Python `.py` files explicitly use classic Python Mode; hooks enable Eglot and Flycheck.
- Eagerly loads VLF setup.
- Projectile project types:
  - npm: build/test/start;
  - Rails/RSpec: Rails server and RSpec;
  - Free Pascal: `fpcmake`, with placeholder run/test commands;
  - Lazarus: wildcard marker, generated `lazbuild` command, `lazrun`, `laztest`;
  - D/Dub: build/run/test.
- Lazarus compilation scans filenames using `directory-files`’ regexp argument with wildcard-looking text; matching and missing-file behavior deserve testing.

## 5. Language presentation, Scheme and Vue

### Prettification — 704–754

Hooks **add mappings**, but do not themselves enable Prettify Symbols mode:

- C tree-sitter: comparison, equality/assignment, logical operators, inequality, void, arrow and multiplication.
- C++ tree-sitter: similar, without the active inequality mapping.
- Pascal: begin/end braces and assignment.
- Rust classic mode: equality/assignment, logic, inequality and multiplication.

Some replacements are strings rather than characters; compatibility depends on Prettify Symbols’ accepted composition forms.

### Other integrations

- Disables Geiser automatic activation and requires Arei (**676–677**).
- Enables Bar Cursor globally (**667–668**).
- Xenops scale is `0.6`; LaTeX and Org hooks enable it (**681–687**).
- Requires Python Django and Object Pascal support.
- Defines `genehack-vue-mode`, derived from Web Mode; `.vue` files use it and start LSP (**1805–1815**).
- Requires both Volar and Vetur clients; client-selection conflicts depend on their package configuration.
- MMM global mode is `maybe`; registers HTML/PHP mixed-mode handling (**1817–1819**).
- `.gp` and `.plot` use Gnuplot Mode (**1825–1826**).

## 6. Org configuration

### General behavior — 769–809, 1345–1352, 1747–1802, 1845–1848

- Logs completion timestamps; Return follows links.
- Associates `.org` with Org Mode.
- Hooks enable Org Indent, Sticky Header, variable pitch, Mixed Pitch, Xenops, Form Feed and backlink mode.
- Hides emphasis markers.
- Text modes use Visual Line; explicitly enables it in Messages.
- Native TAB behavior in source blocks and native source fontification.
- Starts Org Notify.
- Agenda files come from a dedicated agenda directory; filenames exclude dotfiles and require `.org`.
- Form-feed indentation fix expands `org-outline-regexp`.
- Loads Org Checklist through Org Contrib.
- Local spelling skips property drawers, tilde/equal verbatim regions and uppercase source-block delimiters.
- Org startup folds to content and shows inline images.
- **Disables Babel evaluation confirmation**, permitting execution without that prompt.

### Org key changes — 783–797, 1786–1802

- Removes Org bindings for M-left, C-S-left/right and S-up/down; M-right removal is commented out.
- Home/End use ordinary beginning/end of line.
- C-c up/down changes priority.
- C-c l inserts a link.
- C-c C-g C-r runs shift-meta-right.
- Org hook removes beginning/end-of-line remappings and sets `line-move-visual` to nil. Since `setq` is used, locality depends on the variable’s existing buffer-local status.

### TODO, capture, tags and agenda — 921–1132

- TODO sequence: TODO, PLANNING, IN-PROGRESS, VERIFYING, BLOCKED; completed states DONE, OBE, WONT-DO, with explicit logging modifiers.
- Capture header includes date, author, `internal` file tag and capture cursor.
- Bracket-transform helper converts square to round brackets for captured descriptions.
- Column format shows task, clock sum and inactive timestamp.

Capture templates:

- `i`: capture into an ID node;
- `j`: jump to an ID node, immediately finish;
- `q`: immediately create a stub ID node;
- `n`: random note;
- `g`: general TODO;
- `c`: code TODO with selection, annotation and proposed solution;
- `m`: weekly meeting datetree, clock-in/resume, attendees/notes/action items;
- `p`: Org Protocol quotation;
- `L`: Org Protocol link;
- `w`: web capture into an empty file target.

**Ordering issue:** protocol targets concatenate `org-directory` before the later Org Node block assigns it; concatenation also assumes a trailing slash.

Tags include exclusive ticket and meeting groups; workflow flags; code areas; critical/obstacle flags; meeting categories; accomplishments. Several shortcut characters are reused across tags.

State-tag triggers reference CANCELLED, WAITING, HOLD and NEXT, although those states are absent from the configured TODO sequence. Colors are assigned to planning, backend, frontend, QA, meeting and CRITICAL.

Agenda commands:

- `d`: unfinished priority A, seven-day agenda, ordinary unscheduled/deadline-free TODOs excluding A/C, unfinished C.
- `j`: seven-day agenda plus TODOs grouped by criticality, workflow, blockers, research, tickets, meeting action items and priority.
- The latter requires Org Super Agenda to be enabled elsewhere; this half only supplies its grouping variable.
- Completed deadlines are skipped.

### Org Node and memory — 1266–1341

- Watches the configured node directory; synchronizes Org Mem with Org IDs.
- Enables memory updater and node cache modes.
- Sets capture-based node creation and altered completion candidates.
- Adds backlinks and prefers visiting reference nodes when opening links.
- Sets Org directory and default notes file.
- Defines two series:
  - daily files: filename dates, calendar prompt, visit/create under the daily directory;
  - all ID nodes by inherited CREATED property: completion over sorted timestamps, visit by ID, create node.
- The CREATED-property creation hook mentioned in comments is **not installed here**.

### Export and publishing — 815–878, 1828–1843

- Registers Elfeed Org links with follow/store/export handlers.
- Export helper looks up the original article and formats HTML, Markdown, LaTeX, Texinfo or plain text.
- **Potential failure:** its fallback references `url` outside the successful `if-let*` branch’s lexical binding.
- Pandoc data directory points into configuration.
- `efe/export-to-docx` enables Pandoc, executes a keyboard macro, then sets its mode variable to nil rather than invoking normal teardown.
- Blog-template command inserts HTML headers, footer navigation and webring markup.
- Defines a recursive HTML5 publishing project, no TOC/section numbering/preamble/postamble, stylesheet, public-tag selection and private/confidential/internal filename exclusions.
- **Quoted project plist contains unevaluated `expand-file-name` forms**, rather than expanded directory strings; publishing likely needs correction.
- Filename/tag exclusions are configuration filters, not a guaranteed confidentiality boundary.

## 7. Media, feeds, web and AI

### Web helpers — 886–915, 1211–1230

- Google command asynchronously requests search HTML using a browser-style user agent, parses a specific result class, and copies the first URL to the kill ring.
- Companion command searches the word at point.
- Behavior depends on Google’s HTML and libxml support.
- NotDeft importer shells through Curl and Pandoc, extracts an Org title and creates a note; prefix asks for destination directory.
- Uses older Pandoc options whose availability depends on installed version.
- Sets `scroll-preserve-screen-position` nil.

### URL handling — 1443–1477

- Requires Kiwix and chooses EWW as its default browser.
- Requires MPV.
- Adds predicates/handlers that open YouTube and MP4/WMV URLs fullscreen through MPV.
- Regexes are loosely anchored and contain unescaped hostname dots; they can match unintended URLs.
- Requires SHR Math, immediately enabling its math renderer.

### EMMS and Mediainfo — 1480–1518

- EMMS config runs `emms-all`, chooses MPV, libtag metadata, cached cover thumbnails and a `mid3iconv` tag-editor pipe.
- Requires Org EMMS.
- After-init hook recursively imports the music directory.
- Mediainfo opens through `emms-play-file`.
- Adds a Play menu and buffer-local toolbar copied from the global toolbar.

### Elfeed and GPTel — 1520–1558

- Redefines Elfeed entry printing: date, constrained-width title with tooltip, tab, feed title and colored tags; assigns that printer.
- GPTel backend is a streaming, local HTTP llama.cpp-compatible endpoint, model `llama`, default Org buffers.
- Local Copilot integration separately uses `llama-cli`; see below.

## 8. Window, buffer and frame utilities

- `other-window-mru` selects the most recently used other window (**1854–1862**).
- In daemon mode, replaces delete-frame event handling: select frame, prompt to save, kill unmodified displayed buffers, delete frame (**1864–1879**). Quitting a save prompt is not necessarily equivalent to cancelling frame deletion.
- `kill-other-buffers` kills other file-visiting buffers, not all buffers as its docstring claims; uses legacy `remove-if-not` without an explicit provider (**1888–1893**).
- Clears autosave filename transforms, allowing adjacent/remote autosave placement rather than transformed local names (**1895–1897**).
- Ignores mouse movement events over modeline, margins/fringes, header, scrollbar, toolbar and menubar as an LSP UI workaround (**1900–1906**).
- Redefines the default tab-name formatter: pathname tooltip, selected-tab window toolbar, normal close-button/face behavior (**1908–1943**). This is effective when the configured tab formatter actually calls that function.
- `mes/pr-review-via-forge` resolves a Forge target, verifies it parses as a PR, and starts PR Review; otherwise errors (**1946–1952**).

## 9. Org Noter/PDF integration — 1960–2000

- Org Noter configuration requires its PDF Tools integration.
- Org PDF Tools link setup runs in Org buffers.
- Redefines precise-note insertion, temporarily toggling no-question behavior with prefix and enabling isearch/freepointer annotation links.
- Redefines start-location setting: prefix removes the stored location; otherwise stores current approximate document location.
- After PDF Annot loads, annotation activation jumps to the corresponding Org note.
- These implementations use private Org Noter APIs and therefore depend on package-version compatibility.

## 10. Local files followed

Whole-file inspection was completed for the explicit available loads and the located primary required files. Xenops’ primary file was read completely, but its substantial transitive module tree received only selected inspection.

### Explicit loads

| File | Behavior and important findings |
|---|---|
| `guix-workspace.el:1–152` | Requires compilation helpers; immediately advises `compilation-start`, defers Agent Shell advice. Finds nearest manifest, checks/prompts Guix authorization, wraps compilation/agent execution in Guix containers. Host resource sharing weakens isolation; compilation extra arguments are not individually shell-quoted; authorization appending lacks newline protection. |
| `lisp/unbreak.el:1–280` | Defines interactive `unbreak`, dynamically generating menu subgroups and singleton toolbar items from currently bound public commands; `find-single-word-commands` lists unhyphenated commands. **Loading does not invoke it.** Active debug printing, legacy/transitive CL dependencies and context-sensitive discovery remain. |
| `lisp/modern-fringes.el:1–185` | Defines customizable replacement fringe bitmaps, initialize/revert/invert functions and global mode. **Loading does not enable the mode.** `left-triange` typo mismatches intended/reverted `left-triangle` (**145,156**). |
| Guix `etc/copyright.el` | Missing; unconditional load at `custom.el:650` normally aborts subsequent evaluation. |
| `dap-gdb/dap-gdb.el:1–84` | Requires DAP and utilities; registers native `gdb -i dap` launch and gdbserver attachment providers/templates. Needs GDB ≥14; retained remote/target fields need validation against native GDB’s schema. |
| `ssass-mode/ssass-mode.el:1–242` | Sass font-lock, indentation, compilation; backtab dedents, C-c C-c/C-r compile buffer/region. No automatic extension association. Deletes temporary compiler input immediately after asynchronous launch (**218–221**), creating a race; several singly escaped regex sequences and undeclared dependencies are suspect. |
| `lisp/copilot.el:1–168` | Local llama-cli completion, not GitHub Copilot. Collects nearby source context, persists prompt/cache sidecars, streams synchronous generation into buffer, cleans Markdown and appends history. Globally binds C-c C-k and adds C/Python hooks. No unnamed-buffer guard; blocking execution, unchecked exit status and persistent source context are material concerns. |

### Required local packages

- **Elfeed Tube main: 1–1185:** metadata/caption/thumbnail fetching, async Curl/Invidious/SponsorBlock processing, transcript rendering, save/refetch/timestamp commands. `elfeed-tube-setup` installs hooks/advice, but **no setup call occurs in this half**. Main risks include fragile external APIs, partial metadata overwrite and error-path handling.
- **Elfeed Tube MPV: 1–326:** eager transcript-keymap integration; play/seek/queue, independent playback, follow timer/overlay and pause binding. Timer/overlay state can interfere across buffers; executable checks become stale after environment changes.
- **Xenops main: 1–447:** eagerly loads Org/AUCTeX helpers and implementation modules; render/reveal/regenerate/resize/copy/delete/execute commands, `C-c ,` prefix and `C-c !` DWIM. Mode adds math/rendering/font/key integration. Selected module inspection found mouse advice removed from the wrong function (`xenops-math.el:98,109`); global advice controlled by buffer-local modes merits care.
- **Wakib Keys: 1–534:** high-precedence emulation map, CUA-like editing, movement/selection/buffer helpers, relocated original C-c/C-x prefixes and binding-description advice. `custom.el` explicitly enables it. Some extension helpers are empty; menu mutation is not reversed.
- **Kiwix: 1–538:** server/library/search commands and frontend-specific completion; dependencies load eagerly, but require alone does not start a server. Found default-path construction, escaping, synchronous requests and process-tracking issues. Its Org companion (**1–165**) was read but is **not loaded here**; setup is explicit.
- **SHR Math: 1–177:** immediately registers MathML→LaTeX→Xenops rendering. Assumes Xenops/TeX state without declaring all dependencies; root/fence/matrix/underscript conversions have correctness issues.
- **Treemacs Projectile and Arei:** no local implementation located in searched configuration/source directories. They may resolve through system/Guix load paths; internal behavior remains unaudited.

## 11. Commented-only configuration

The following are **not active** in this half:

- Popper and C-; popup control;
- header-line window toolbar and shifted toolbar-button removals;
- broad UTF-8 coding-system setup;
- smart text/media yank alternative and paste-function suppression;
- Org Capture toolbar alternative and continuous toolbar maintenance;
- global line numbering, several pitch hooks and Combobulate navigation;
- many Delphi-style shortcut/refactoring/debugger proposals;
- almost all standalone DAP-map examples and Python Uvicorn launch template;
- Paredit arrow-key changes;
- remote clangd client, mouse autoselection and PATH edits;
- Guix prettification/development hooks and Notebook loading;
- Xenops reveal-on-entry and NOV activation;
- Markchars;
- Org agenda lead times, Org-only visual wrapping and Org Roam display template;
- Org Node sequence mode, QEMU integrations and various global-env wrappers;
- Discover My Major and most Which-key options;
- Vala LSP, Company LSP/Jedi additions and alternative Org form-feed fix;
- Vue Eglot/MMM-LSP examples;
- Eshell Smart/maximum-output behavior and alternative TRAMP autosave directory.

**Priority fixes:** missing copyright load, overridden/noninteractive `yank`, publishing directory forms, completion-variable typo, duplicate C-F11, Tempel normalization, Ssass temporary-file race, and Xenops/fringe typos.
