# Inventory of `init.el`

Read all 859 lines; EOF confirmed. No files changed, and **`custom.el` was not inspected**. References below are to `/home/dannym/.config/emacs/init.el`. Credential values are omitted.

This file mixes a GUI-generated Custom block (105–283) with explicit Lisp configuration. Hand-managed `custom.el` is loaded near the end, so it and the other loaded files may override earlier settings.

## 1. Packages, loading, and compilation

### Variables
| Variable | Value | Lines |
|---|---|---|
| `package-enable-at-startup` | `nil`; initialization instead invoked explicitly | 3, 57–58 |
| `package-check-signature` | `nil` | 5 |
| `package-archives` | Empty list; comment says Guix-managed | 10–11 |
| `package-selected-packages` | `nil` | 252 |
| `package-native-compile` | `t` | 568 |

### Active load forms
- Explicit `require`: `nerd-icons` (13), `lsp-treemacs` (37), `package` (57), `vc` (97), `eglot` (424), `web-mode` (434), `dap-python` (464 and 542), `lsp-mode` (537), `slime` (559), `solarized-theme` (576), `pdf-tools` (599), `bookmark` (604), `saveplace-pdf-view` (605), `format-all` (650), `auctex` (721), `json` inside advice installation (741), `mpv` (821).
- `package-initialize` (58).
- `use-package` declarations:
  - `rust-mode`, `rustic`, `projectile`, `pyvenv` (60–75).
  - `treesit` (294–325).
  - `lsp-mode`, `lsp-ui`, `company`, `yasnippet`, `flycheck` (467–522).
  - `org-mime`, `vertico`, `marginalia`, `magit`, `forge`, `which-key`, `rainbow-delimiters` (611–648).
  - `popper`, `eshell`, `outline-indent` (668–706, 791–800).
- `yasnippet` and `flycheck` use bare `:ensure` (515–522).
- `vertico`, `marginalia`, `magit`, `forge`, `which-key`, `outline-indent` use **`:ensure f`**, not `:ensure nil` (613–645, 791–792).
- `rustic` loads after `rust-mode`; `forge` after `magit` (66–67, 631–633).
- AUCTeX: `(load "auctex.el" nil t t)`—missing file errors, suppresses load message, uses exact suffix (719).
- Maxima autoloads: `maxima-mode`, `imaxima`, `maxima`, `imath-mode` (723–726).
- Optional local loads, all with a non-nil NOERROR argument:
  - `custom.el` (824–825).
  - `email.el` (826–827).
  - `git-commit-message.el` (830–831).
  - `guix-build-failure3.el` (832–833).
  - `autoresize.el` (834–835).
  - `wolfram.el` (836–837).
  - `mcphas.el` (840–841).
  - `ada.el` (842–843).

Their contents and effects are outside this inventory.

## 2. Security, trust, and persistence

### Security/trust variables
- `package-check-signature = nil`: package signature verification disabled (5).
- `auth-source-save-behavior = nil`: disables auth-source credential saving (113).
- `canlock-password`: credential configured; **value redacted** (134).
- `epa-pinentry-mode = 'loopback`: pinentry handled through loopback; preceded by a `defvar` declaration (682–684).
- `LaTeX-command = "lualatex -shell-escape"`: permits external-command execution by LaTeX (110).
- `buffer-env-safe-files`: nine trusted path/hash pairs (115–133):
  - `~/src/agent-c/e/rune-os/kernel/manifest.scm`
  - `~/src/agent-c/e/7d/manifest.scm`
  - `~/src/guix-dev86/manifest.scm`
  - `~/src/agent-c/e/fast-lisp-rs/manifest.scm`
  - `~/src/claude-code/e/rune-os/kernel/manifest.scm`
  - `~/src/mcphas/manifest.scm`, with two different approved hashes
  - `~/src/guix/manifest.scm`
  - `~/src/latex-ex/manifest.scm`
  
  Hashes are content-trust identifiers, not reproduced here.
- `safe-local-variable-directories = '("/home/dannym/src/auto/e/guix-mono-team/guix/")` (254).
- `safe-local-variable-values` approves (255–262):
  - An `eval` setting buffer-local `bug-reference-bug-regexp` through `rx`; its group matches **32 repetitions** of `"guix/guix"`, followed by `#` or `!` and digits.
  - An `org-emphasis-alist` with `/` italic, `_` underline, `=` verbatim, `~` code, and `,` quote.
- `ignored-local-variable-values`: these forms are **ignored, not executed or approved** by this list (155–210):
  - `gac-debounce-interval = 5`, `gac-automatically-push-p = t`.
  - Git commit trailer addition `"Change-Id"`.
  - An Emacs-27-style paragraph-filling function and buffer-local `fill-paragraph-function`.
  - `geiser-repl-per-project-p = t`.
  - Guix Yasnippet and Tempel directory setup, including mutations of `yas-snippet-dirs` and `tempel-path`.
  - Buffer-local `guix-directory` discovery.
  - Addition of `.go` to `completion-ignored-extensions`.
  - Syntax modifications for character codes 43, 36, 126.
  - `geiser-guile-binary = ("guix" "repl")`.
  - `(geiser-insert-actual-lambda)`.
- `load-theme 'solarized t` bypasses theme confirmation (586).
- LSP booster advice executes bytecode read from JSON input when that input begins with `#`; this is a significant process-output trust boundary (733–746).
- Booster command wrapping is conditional on local files, `lsp-use-plists`, absence of native JSON-RPC according to its check, an available executable, and a non-test invocation (747–759).
- TRAMP after-load form sets process environment `SHELL=/bin/sh` (731).

### Persistence and deletion
| Variable/action | Value | Lines |
|---|---|---|
| `backup-by-copying` | `t` | 21 |
| `backup-directory-alist` | All files → expanded `~/backup/` | 22–23 |
| `delete-old-versions` | `t` | 24 |
| `kept-new-versions` | `6` | 25 |
| `kept-old-versions` | `2` | 26 |
| `version-control` | `t` | 27 |
| `delete-by-moving-to-trash` | `t` | 138 |
| `save-place-mode` | Enabled | 606 |
| `org-noter-auto-save-last-location` | `t` | 245 |
| `eshell-history-size` | `100000` | 702 |
| `eshell-save-history-on-exit` | `t` | 703 |
| `eshell-hist-ignoredups` | `t` | 704 |
| `recentf-mode` | Enabled | 856 |
| `recentf-max-menu-items` | `25` | 857 |

Shell history, recent-file lists, backups, and saved reading locations can retain sensitive activity. No encryption or alternate storage paths for these are configured here beyond the backup directory.

## 3. General editing, navigation, and UI

| Variable | Value | Lines |
|---|---|---|
| `tab-always-indent` | `'complete` | 33 |
| `cua-auto-tabify-rectangles` | `nil` | 46 |
| `cua-keep-region-after-copy` | `t` | 48 |
| Default `word-wrap` | `t` | 53 |
| `back-button-no-wrap` | `t` | 114 |
| `column-number-mode` | `t` | 135 |
| `dtrt-indent-global-mode` | `t` | 140 |
| `indent-tabs-mode` | `nil`, through Custom | 211 |
| `inhibit-startup-screen` | `t` | 212 |
| `large-file-warning-threshold` | `100000000` bytes | 215 |
| `line-move-visual` | `nil` | 216 |
| `mouse-autoselect-window` | `t` | 223 |
| `tab-line-close-tab-function` | `'kill-buffer` | 270 |
| `tool-bar-style` | `'image` | 271 |
| `tool-bar-button-margin` | `(7 . 1)` | 286 |
| `left-fringe-width` | `160` | 420 |
| Fringe style | `(20 . 12)` | 421 |
| `which-key-idle-delay` | `0.2` seconds | 645 |
| `debug-on-quit` | `nil` | 859 |

### Enabled/disabled modes and keys
- Toolbar disabled: `tool-bar-mode -1` (39).
- `global-prettify-symbols-mode` enabled (41).
- `cua-mode` enabled, despite “replaced by wakib-keys” comment (45).
- `transient-mark-mode` enabled (47).
- Global `C-y` → `undo-redo`, replacing normal yank (49).
- `projectile-mode` enabled (69–71).
- `(pyvenv-mode nil)` called (73–75); see ambiguity below.
- `vertico-mode` called in both the Vertico and Marginalia configurations (613–621).
- `which-key-mode` called and diminished (640–645).
- `popper-mode` and `popper-echo-mode` enabled (679–680).
- `tooltip-mode` enabled after `dap-mode` loads (547–550).

### Spacious padding
- `spacious-padding-subtle-frame-lines = t` (264).
- `spacious-padding-subtle-mode-line = t` (265).
- `spacious-padding-widths` (266–269):
  - Internal border 0; header line 4; mode line 6; tab 5.
  - Right divider 10; scrollbar 8; fringe 12.
- No explicit `spacious-padding-mode` activation here.

### Popup buffers
`popper-reference-buffers` initially contains Messages, names ending in `Output*`, Async Shell Command, `help-mode`, and `compilation-mode` (673–678). It is extended with name patterns and major modes for Eshell, Shell, Term, and Vterm (711–717).

Keys: `C-\`` toggle, `M-\`` cycle, `C-M-\`` change popup type (669–671).

## 4. Faces and theme

| Face | Attributes/action | Lines |
|---|---|---|
| `glyphless-char` | Background `"purple"` | 95 |
| `default` | Noto Sans Mono, foundry GOOG, normal slant/width, regular weight, height 110 | 279 |
| `fixed-pitch` | Family Noto Mono | 280 |
| `lsp-ui-sideline-global` | Dijkstra Italic, `:italic t`, regular weight, height `0.8` | 281 |
| `org-table` | Foreground `#2aa198`, Atkinson Hyperlegible | 282 |
| `tab-line` | Height `0.9`, black foreground, grey85 background, inherits `variable-pitch` | 283 |
| `default` | Height explicitly reset to 110 | 285 |
| `mmm-default-submode-face` | Background cleared to `nil` on `mmm-mode-hook` | 664–666 |

Additional display settings:
- `glyphless-char-display-control`: `format-control` and `no-font` both `empty-box`, applied using `update-glyphless-char-display` (92).
- `frame-background-mode = 'light` (153).
- `solarized-contrast = 'normal` (263).
- `solarized-termcolors = 256` (577).
- Terminal parameter `background-mode = 'light` (578).
- Solarized theme loaded after the explicit face settings (576–586); effective precedence depends on theme/custom-face handling.

## 5. Completion, searching, snippets, and formatting

| Variable | Value | Lines |
|---|---|---|
| `grep-command` | `"rg -nS --no-heading "` | 154 |
| `xref-search-program` | `'ripgrep` | 273 |
| `vertico-preselect` | `'prompt` | 272 |
| `company-idle-delay` | `0.5` seconds | 503 |
| `format-all-debug` | `nil` | 151 |
| `format-all-show-errors` | `'errors` | 152 |
| Eshell-local `completion-styles` | `'(basic partial-completion)` | 689 |
| Buffer-local `tab-always-indent` in Eshell package `:config` | `'complete` | 701 |

Hooks and actions:
- `after-init-hook` → `global-company-mode` (507).
- Company active-map: `C-n` next, `C-p` previous, `M-<` first, `M->` last (509–513).
- Yasnippet reloads all snippets; enabled on `prog-mode-hook` and `text-mode-hook` (518–520).
- Flycheck package declared, but no active explicit Flycheck enable hook (522–525).
- `rainbow-delimiters-mode` on programming modes (647–648).
- `format-all-ensure-formatter` and `format-all-mode` on programming modes (654–655).
- Eshell hook sets completion styles and binds history `M-r` → `consult-history` (686–706).
- `outline-indent-ellipsis = " ▼ "` (800).
- Outline-indent hooks for ordinary/tree-sitter Python and YAML; specified both in `use-package` and repeated explicitly (795–808).

## 6. Language modes, Tree-sitter, and filename routing

### Tree-sitter variables
- `treesit-extra-load-path`: expanded `~/.guix-home/profile/lib/tree-sitter/` as a one-element list (324).
- `treesit-auto-install = 'prompt` (325).

`major-mode-remap-alist` additions (303–321):
- `sh-mode → bash-ts-mode`
- `c-mode → c-ts-mode`
- `clojure-mode → clojure-ts-mode`
- `css-mode → css-ts-mode`
- `go-mode → go-ts-mode`
- `go-mod-mode → go-mod-ts-mode`
- `java-mode → java-ts-mode`
- `javascript-mode → js-ts-mode`
- `js-json-mode → json-ts-mode`
- `typescript-mode → tsx-ts-mode`
- `vhdl-mode → vhdl-ts-mode`
- `yaml-mode → yaml-ts-mode`

Go and Go module mappings remain active despite “doesn't work” comments.

### `auto-mode-alist` additions
- Anchored `.cs` → `csharp-tree-sitter-mode` (432).
- Web Mode (435–442): `.phtml`, `.tpl.php`, `.[agj]sp`, `.as[cp]x`, `.erb`, `.mustache`, `.djhtml`, `.html?`, all end-anchored.
- Unanchored patterns (445–449):
  - `\.jl` → `julia-snail-mode`
  - `\.rs` → `rustic-mode`
  - `\.cs` → `csharp-mode`
  - `\.js` → `js2-mode`
- Anchored `.pdf` and `.PDF` → `pdf-view-mode`; `.epub` → `nov-mode` (456–458).
- Anchored `.c` → `c-ts-mode`; `.cpp`, `.cc`, `.ixx` → `c++-ts-mode` (459–462).
- Anchored `.mac` / `.max` → `maxima-mode` (728).

### Symbol prettification
Hooks mutate `prettify-symbols-alist`:
- Scheme (333–338): `lambda* → λ*`, `lambda → λ`.
- Python (340–370):
  - `in → ∈`, `True → ⊨`, `False → ⊭`, `is → ≡`, `is not → ≢`.
  - `__add__ → +`, `__sub__ → -`, `__mul__ → *`, `__mod__ → %`.
  - `__truediv__ → /`, `__floordiv__ → //`.
  - `__gt__ → >`, `__ge__ → >=`, `__lt__ → <`, `__le__ → <=`, `__eq__ → ==`, `__ne__ → !=`.
  - `issubset → ⊆`, `issuperset → ⊇`.
- Lean hook exists but has no effective body beyond its string/comments (376–388).
- Rust (394–409): `add/sub/mul/div/not/gt/ge/lt/le/eq/ne` → `+/-/*///!/>/>=/</<=/==/!=`, respectively.

## 7. Rust, LSP, Eglot, debugging, and Lisp

### Rust
- `rust-mode-treesitter-derive = t` (62).
- `rust-format-on-save = t` (64).
- Eglot server list receives `(rust-mode "rust-analyzer")` (425–426).
- `lsp-rust-analyzer-rustc-source` points to:
  `/usr/local/rustup/toolchains/nightly-2024-08-03-x86_64-unknown-linux-musl/lib/rustlib/rustc-src/rust/compiler/rustc/Cargo.toml` (217–218).

### LSP variables
| Variable | Value | Lines |
|---|---|---|
| `lsp-rust-analyzer-cargo-watch-command` | `"clippy"` | 471 |
| `lsp-eldoc-render-all` | `t` | 472 |
| `lsp-idle-delay` | `0.6` | 473 |
| `lsp-inlay-hint-enable` | `t` | 475 |
| `lsp-rust-analyzer-display-lifetime-elision-hints-enable` | `"skip_trivial"` | 477 |
| `lsp-rust-analyzer-display-chaining-hints` | `t` | 478 |
| `lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names` | `nil` | 479 |
| `lsp-rust-analyzer-display-closure-return-type-hints` | `t` | 480 |
| `lsp-rust-analyzer-display-parameter-hints` | `nil` | 481 |
| `lsp-rust-analyzer-display-reborrow-hints` | `nil` | 482 |
| `lsp-enable-suggest-server-download` | `nil` | 483 |
| `lsp-ui-peek-always-show` | `t` | 496 |
| `lsp-ui-sideline-show-hover` | `t` | 497 |
| `lsp-ui-doc-enable` | `t` | 498 |
| `lsp-ui-doc-show-with-mouse` | `t` | 499 |
| `lsp-tex-server` | `'digestif` | 769 |

- `lsp-mode-hook` enables Which-key integration and `lsp-ui-mode` (485–486).
- `lsp` and `lsp-ui-mode` are declared commands (468, 494).
- No active direct Python → LSP hook or general Eglot startup hook.
- JSON parser and `lsp-resolve-final-command` receive the booster advice described above (733–759).

### Debugging/Python/Lisp
- `dap-python-debugger = 'debugpy` (545).
- `python-mode-hook → jedi:setup` (848).
- `jedi:complete-on-dot = t` (849).
- SLIME setup loads `slime-fancy`, `slime-quicklisp`, `slime-asdf` (560).
- No inferior Lisp executable specified here.

## 8. Projects, version control, and issue browsing

- `magit-status-file-list-limit = 1000` (220).
- `debbugs-browse-url-regexp`: HTTP(S) GNU Debbugs, GNU Bugs, or Guix Issues URLs, optional `cgi/bugreport.cgi?bug=`, ending in numeric issue ID (136–137).
- `lsp-treemacs-theme = "Iconless"` (219).
- `treemacs-width = 25` (595).
- After Treemacs loads, mouse button 1 → `treemacs-single-click-expand-action` (288–289).
- `treemacs-display-current-project-exclusively` called (593).
- `treemacs-refresh` called after local configuration loads (846).
- Git/Forge packages declared as described above; no explicit diff-hl activation.

## 9. Org, LaTeX, notes, and mathematical tools

### TeX and Maxima
| Variable | Value | Lines |
|---|---|---|
| `LaTeX-command` | `"lualatex -shell-escape"` | 110 |
| `LaTeX-electric-left-right-brace` | `t` | 111 |
| `TeX-engine` | `'luatex` | 112 |
| `TeX-electric-sub-and-superscript` | `t` | 770 |
| `TeX-fold-mode` | `t`, assigned as a variable | 771 |
| `imaxima-use-maxima-mode-flag` | `t` | 727 |

### Org execution, export, and preview
- `org-babel-ditaa-java-cmd = "ditaa"` (227).
- `org-ditaa-jar-path = "/home/dannym/.guix-home/profile/lib/ditaa0.11.0.jar"` (228).
- `org-ditaa-java-exec = "ditaa"` (229).
- `org-export-exclude-tags = '("confidential")` (230).
- `org-export-select-tags = '("public")` (231).
- `org-id-link-to-org-use-id = 'use-existing` (232).
- `org-latex-packages-alist`: `braket`, `esint`, `units`, `unicode-math`; each has empty options, preview flag `t`, final field `nil` (233–235).
- `org-latex-preview-appearance-options` (236–239):
  - Foreground/background `default`; scale 2.
  - HTML foreground Black, background Transparent, scale 1.0.
  - Matchers: `"begin"`, `"$1"`, `"$"`, `"$$"`, `"\\("`, `"\\["`.
- `org-latex-preview-process-default = 'dvisvgm` (240).

### Org behavior and notes
- `org-replace-disputed-keys = t` (246).
- `org-startup-folded = 'content` (247).
- `org-startup-with-link-previews = t` (248).
- `org-sticky-header-always-show-header = t` (249).
- `org-sticky-header-full-path = 'reversed` (250).
- `org-support-shift-select = t` (251).
- `org-noter-always-create-frame = nil` (244).
- `org-noter-auto-save-last-location = t` (245).
- `org-noter-notes-search-path`: expanded `~/doc/org-roam`, assigned as a **string** (331).

Export tag settings control export selection, not confidentiality enforcement.

## 10. Mail, feeds, media, document viewing, and offline browsing

### Mail
- `read-mail-command = 'mu4e` (253).
- `mu4e-compose-switch = nil` (225).
- `mu4e-search-results-limit = -1` (226).
- `org-msg-convert-citation = t` (241).
- `org-msg-greeting-fmt = "Hello%s,"` (242).
- `org-msg-posting-style = nil` (243).
- `org-mime` declared (611).
- Optional `email.el` loaded (826–827), not inspected.

### Elfeed
`elfeed-feeds` contains nine entries (141–150):
1. `https://the-dam.org/rss.xml`
2. `http://planet.emacslife.com/atom.xml`, tagged `emacs`
3. `https://lwn.net/headlines/rss`
4. FiveFilters subscription/full-text wrapper for HN front page
5. Same wrapper for Nature Materials current issue
6. Same wrapper for Nature Physics current issue
7. `https://semianalysis.substack.com/feed`
8. `https://slow-journalism.com/blog/feed`
9. HTTP FiveFilters full-text wrapper for Ars Technica features

The transformed feeds use `max=3`; nested HTTP URLs occur inside several HTTPS subscription URLs.

### Media/documents
- `dired-listing-switches = "-alot --si"` (139).
- `mediainfo-mode-file-regexp`: matches `3gp`, `aiff`, `avi`, `flac`, `jpg`, `jpeg`, `png`, `gif`, `m4a`, `mkv`, `mov`, `mp3`, `mp4`, `mpg`, `ogg`, `opus`, `vob`, `wav`, `webm`, `wmv` (221–222).
- `mpv-start-timeout = 0.5` (224).
- `doc-view-resolution = 300` (598).
- PDF Tools and saveplace-pdf-view required, but `pdf-tools-install` is not explicitly called (599–606).
- `kiwix-default-browser-function = 'eww-browse-url` (213).
- `kiwix-server-type = 'kiwix-serve-local` (214).
- `kiwix-zim-dir`: expanded `~/.local/zim` (330).

## 11. Performance variables

| Variable | Value | Lines |
|---|---|---|
| `gc-cons-threshold` | 100 MiB | 562 |
| `gcmh-high-cons-threshold` | 1 GiB | 563 |
| `gcmh-idle-delay-factor` | `20` | 564 |
| `jit-lock-defer-time` | `0.05` seconds | 565 |
| `read-process-output-max` | 1 MiB | 567 |

No explicit `gcmh-mode` activation appears.

## 12. Ambiguous, fragile, or version-dependent features

These are static observations, not runtime-tested failures:

- **`:ensure f` is not false in Lisp.** Unless `f` is bound suitably or a custom ensure handler intervenes, these forms may attempt to evaluate an unbound symbol rather than suppress installation (614, 619, 629, 632, 641, 792). This conflicts with the apparent Guix-managed intent.
- **`pyvenv-mode nil` is not a reliable “disable” call.** Standard minor-mode behavior with nil depends on invocation context; use of `-1` would be unambiguous (75).
- Marginalia’s configuration calls **`vertico-mode`, not `marginalia-mode`** (618–621). Annotation activation is absent here.
- **`TeX-fold-mode` is assigned, not invoked.** Setting a minor-mode variable need not perform its activation machinery (771).
- `org-noter-notes-search-path` is assigned a string; commonly documented versions expect a list of directories (331).
- `treesit-auto-install` belongs to `treesit-auto`, but no active `treesit-auto` load or mode activation appears (325).
- C# routing conflicts: the later, broader `\\.cs` entry takes precedence over the earlier anchored Tree-sitter entry (432, 448).
- Julia, Rust, C#, and JavaScript patterns lack end anchors and can match names beyond their intended suffixes (445–449).
- JavaScript routing to `js2-mode` is not directly covered by the `javascript-mode → js-ts-mode` remap (313, 449).
- Tree-sitter remapping does not migrate mode hooks automatically; comments acknowledge this (296–301). Symbol prettification remains on ordinary Python/Rust hooks.
- `left-fringe-width = 160`, subsequent `(20 . 12)` fringe style, and Spacious Padding’s fringe width 12 express potentially competing geometry settings (269, 420–421).
- Rust formatting may overlap: `rust-format-on-save` plus programming-mode `format-all-mode` (64, 654–655).
- Python has Jedi setup plus Company, optional LSP components, and two outline-indent hook declarations; actual integration depends on package behavior.
- `dap-python` is required twice (464, 542); harmless redundancy under normal `require` semantics.
- The trusted `bug-reference-bug-regexp` uses `(32 "guix/guix")`, meaning repetition, not a character code; likely worth checking against intended issue syntax (256–259).
- `:italic t` in the LSP sideline face is nonstandard compared with `:slant italic` (281).
- Modern Org preview/link-preview variables and Rust/LSP hint names are package-version-sensitive (236–240, 248, 477–482). Unsupported Custom variables may persist without effect.
- `org-ditaa-java-exec` and `org-babel-ditaa-java-cmd` both name `ditaa`, not `java`; compatibility depends on the installed Org implementation (227–229).
- The fixed Rust nightly path may become stale (217–218).
- Booster JSON advice is **global**, not limited to the wrapped LSP process; its bytecode execution deserves particular security scrutiny (733–746).
- No explicit `use-package` require appears; availability depends on Emacs/package startup environment.
- Local loads near EOF can change all of these conclusions about effective runtime values.

## 13. Commented-out configuration: inactive

The following are present only as comments and have no direct effect:

- `use-package-defaults`; alternate `lsp-treemacs-theme` setting (6–8).
- Global auto-revert, noted as problematic with mediainfo (15–16).
- `load-suffixes` byte-compilation avoidance suggestion (18).
- Default indentation assignment and global tab-line activation (29–35); indentation is independently configured through Custom.
- Early Magit loading/status commands, `magit-status-buffer-switch-function`, scratch-buffer deletion (77–84).
- Geiser Guix load-path addition (88–89).
- Global diff-hl and Magit refresh hooks (99–101).
- Treemacs simple Git mode (291).
- C# and HTML Tree-sitter remaps, Python/Rust/js remap alternatives (304–318).
- Legacy `tree-sitter-langs`, global Tree-sitter mode, highlighting hook (326–328).
- Duplicate Rust format-on-save settings and explicit Rust prettify activation (372–373, 390–391, 408).
- GUD and an incomplete C# `use-package` wrapper (419, 430–431).
- Vue routing, automatic R/ESS example, TypeScript/Rust alternative routing (443, 447, 450–451).
- Frames-only buffer-kill lists (453–454).
- Elpy; Python LSP startup; Flycheck programming hook; alternate Company configuration; duplicate Rust LSP declaration (465, 488–535).
- DAP C++/Java loading, DAP tooltip/UI controls, integrated terminal and auto-configuration (538–555).
- Rustic macro-expansion setting (570–573).
- Alternate/generated Solarized theme and bare theme-enabling example (579–587).
- LSP/Treemacs synchronization and Treemacs Magit integration (589–592).
- PDF restore hook and Doc View alias (600–609).
- Orderless completion and Doom Modeline configuration (623–638).
- Rust-specific Format All hooks and alternate MMM background (657–662).
- Eshell Corfu/Cape completion and scroll-to-bottom setting (690–700).
- Preview LaTeX load (720).
- `exec-path-from-shell`, including `LSP_USE_PLISTS` import (761–767).
- Xenops, global Enter indentation, indentation functions (772–785).
- Explicit dtrt-indent package setup (810–819); its global mode variable is active in Custom.
- Howm; optional protected-branches and Straico files (822, 828–829, 838–839).
- Envrc debugging/global activation (851–853).

**No explicit `custom-file` assignment appears.** The GUI-generated block remains in `init.el`, while a separate hand-managed `custom.el` is loaded explicitly.
