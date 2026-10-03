# Scope and loading

Read all source of the six requested modules. No files were modified. Paths and line references below are relative to `/home/dannym/.config/emacs`.

`init.el:830–843` explicitly loads, in order:

1. `git-commit-message.el`
2. `guix-build-failure3.el`
3. `autoresize.el`
4. `wolfram.el`
5. `mcphas.el`
6. `ada.el`

These loads tolerate missing files, **not evaluation errors**. “Active” below means wired into startup, not runtime-tested.

Inactive alternatives found but not inventoried: `guix-build-failure.el`, `guix-build-failure2.el`, and `guix-build-failure3-xx.el`. Related `.prompt`/`.cache` files were not read. None is referenced by the inspected active startup files.

## 1. `git-commit-message.el`

### Public entry point and behavior

**`my/generate-lisp-commit-message`** (`:199–226`) is a public function, **not an interactive command**.

- Checks whether anything is staged through Magit.
- Reads `git diff --cached`.
- Requires exactly one changed file and one continuous block of added lines.
- Requires that block to contain exactly one Lisp expression beginning with a restricted `define-public` name.
- Splits a trailing numeric-looking version from the variable name.
- **Deletes the entire current buffer**, inserts a Guix-style commit message, and saves it.

Generated form:

```text
gnu: Add PACKAGE@VERSION.

* FILE (PACKAGE-VERSION): New variable.
```

### Hooks, helpers, tests

- **Active hook:** `custom.el:2683` installs it on `git-commit-setup-hook`. `custom.el` loads before this module (`init.el:824–831`).
- Noninteractive helpers:
  - `my/parse-exactly-one-list` — `:9–20`
  - `my/diff-lines->files` — `:102–107`
  - `my/diff-lines->block-lines` — `:125–139`
  - `my/guix-split-variable-name` — `:165–182`
  - `my/strip-prefix` — `:193–197`
  - `my/test-generate-lisp-commit-message-setup` — `:228–236`
- Requires `ert` and `cl-lib` at load time (`:6–7`).
- Registers **11 ERT tests**, but does not run them (`:22–100,109–124,141–163,184–191,239–313`).
- No advice, menu, toolbar, or keybinding is defined here.

### Requirements and uncertainties

- Requires Git and Magit’s `magit-anything-staged-p`/`magit-git-lines`; Magit is not explicitly required by this module (`:201–202`).
- Uses Emacs string helpers without explicitly requiring their libraries.
- **Commit-buffer replacement is unconditional once the heuristic qualifies**, including any pre-existing message (`:215–225`).
- Only added lines are analyzed; removal lines do not prevent an update from being described as “New variable” (`:125–139,199–226`).
- The filename helper collects the first `diff --git` path, ordinarily `a/...`; generation strips **`c/`**, not `a/` (`:105–106,222`). This relies on a nonstandard Git prefix or produces the wrong path.
- Versionless names can produce `@nil` and `-nil` (`:165–182,211–224`).
- Unbalanced input can raise `scan-error`; generation does not catch it (`:15,207`).
- Existing tests appear stale: their expected messages omit `@VERSION`, and their expected paths disagree with current prefix stripping (`:249,313` versus `:217–224`). Several expect errors where the generator can simply return nil. The test helper also reaches `save-buffer` from a temporary buffer. **Tests were not executed.**

## 2. `guix-build-failure3.el`

### Public commands

| Command | Behavior |
|---|---|
| `guix-ensure-drv-0-directory` (`:7–27`) | Prompts for a directory; normalizes `/tmp/guix-build-….drv-N` to `.drv-0`, potentially deleting the destination and renaming the build tree. |
| `guix-normalize-and-open-build-dir` (`:29–37`) | Normalizes a build directory and opens Dired, temporarily binding `treemacs-follow-mode` to nil. |

Noninteractive predicate: **`guix-build-dir-p`** (`:2–5`), recognizing paths beginning `/tmp/guix-build-….drv-N`.

### Hooks and Embark integration

- `compilation-mode-hook` installs a compilation regexp for Guix’s “note: keeping build directory” output (`:40–49`).
  - Captures the directory as the filename; no line-number group.
  - Uses `add-to-list`, without explicitly making these regexp variables buffer-local.
- After Embark loads (`:52–74`):
  - Adds a target finder for **exactly** `compilation-mode`, not derived compilation modes.
  - Produces target type `guix-build-dir`.
  - Registers `embark-guix-build-dir-map`.
  - Binds **`d`** to a lambda intended to normalize/open the target; it also emits debugging message `PPP …`.
- No advice, menus, or toolbar additions.

### Requirements and uncertainties

- Requires Guix’s preserved failed-build directories, Dired, compilation support, filename-at-point support, and Embark for the contextual action.
- Uses `defvar-keymap`, a modern Emacs dependency (`:62`).
- **Destructive behavior:** deletion/rename occurs when the command is invoked, not merely on loading (`:19–25`).
- The deletion prompt checks whether the **source** exists, not whether the destination exists. Declining deletion still proceeds to `rename-file … t` (`:19–25`).
- If the path already has `.drv-0`, the function returns the top-level directory and drops any suffix; otherwise it preserves the suffix (`:13–18`).
- **The open command ignores its supplied argument**, shadowing it with `thing-at-point` (`:29–33`).
- The Embark `d` lambda lacks an `interactive` declaration, so its usability as an Embark command is questionable (`:64–67`).
- The regexp’s class `[^&#x27;]+` literally excludes characters including `x`, `2`, and `7`; it is not an HTML-entity exclusion. Legitimate build paths can fail to match (`:42`).
- The target finder is stricter about major mode than the compilation hook (`:55`).

## 3. `autoresize.el`

### Public command and setting

- **`document-window-enforce-max-width`** (`:8–35`) — interactive.
- **`document-window-max-width`**, default **120 characters**, customizable under `pdf-tools` (`:3–6`).

In PDF/DocView buffers with an available image, the command:

1. Computes a window width from the image aspect ratio and current window height.
2. Caps that width at 120 frame characters.
3. Subtracts a five-pixel adjustment.
4. Horizontally resizes the selected window, **only if the image exceeds the window height**.

It changes window geometry, not image scaling.

### Hooks

- `pdf-view-after-change-page-hook` — `:37`
- `doc-view-after-change-page-hook` — `:38`
- Global `window-configuration-change-hook` — `:43–49`
  - Uses buffer-local `window-resizing-in-progress` as a recursion guard (`:40–41`).
  - Resets the guard with `unwind-protect`.

No advice, keybindings, menu, or toolbar additions.

### Requirements and uncertainties

- Depends on PDF Tools’ image functions or built-in DocView’s image/slice functions (`:11–17`).
- PDF Tools and its rendering backend must be available for PDF behavior; `init.el:599` requires `pdf-tools`.
- The advertised maximum is **not enforced when the image already fits vertically** (`:26`).
- Resizing uses the selected window, not an explicit window passed by a hook (`:14`).
- Impossible resize requests, fixed-width/sole-window layouts, or missing image data are not caught.
- The recursion guard is buffer-local rather than frame/window-specific.

## 4. `wolfram.el`

The complete live configuration is `:16–18`:

- Configures external **`xah-wolfram-mode`** through `use-package`.
- Binds **`C-j` → `xah-wolfram-eval-region`** in `xah-wolfram-mode-map`.

There are **no locally defined public commands, hooks, advice, menus, or toolbars**. The comments at `:3–15` are TODOs, not installed bindings or functionality.

**Requirements:** `use-package`, `xah-wolfram-mode`, and whatever Wolfram execution backend that package requires. This file specifies neither executable paths nor backend configuration; those remain external migration requirements.

## 5. `mcphas.el`

### Mode and file selection

**`my-mcphas-mode`** (`:9–12`) is an interactive major mode derived from `prog-mode`.

- Displayed mode name: `mcphas`.
- Treats underscore as a word constituent (`:3–7`).
- Provides feature **`my-mcphas-mode`**, not `mcphas` (`:409`).
- Consequently inherits active global `prog-mode` integrations, including Yasnippet, Rainbow Delimiters, and Format All (`init.el:515–520,647–655`).

The global auto-mode registration (`:411–416`) covers:

```text
Blm cef cif clc dat del dsigma fcm fe_status forfit fst fum grid
hkl hst in ini j jq jvx Llm mcdisp mcphas mf
MH_mcphas MH_spins MH_spins3dab MH_spins3dac MH_spins3dbc
MT_mcphas MT_spins MT_spins3dab MT_spins3dac MT_spins3dbc
out par pc phs prn qee qei qem qom qvc rtplot setup sipf
spins spins3dab spins3dac spins3dbc sps status trs tst txt xyt
```

Also matches filenames ending `calcsta.bat`. **Broad extensions such as `.txt`, `.dat`, `.ini`, `.in`, and `.out` are globally reassigned**, not restricted to a McPhase project.

### All locally defined interactive runner commands

Except for the two process-launch commands noted below, these call `compile` in the current directory.

| Command | Executed command / inputs | Lines |
|---|---|---|
| `run-mcphas` | `mcphas` | 16–18 |
| `run-calcsta` | `wine64 cmd calcsta.bat` | 20–22 |
| `run-simannfit` | `simannfit` | 24–26 |
| `run-searchspace` | `searchspace` | 28–30 |
| `setup-mcphasjforfit` | `setup_mcphasjforfit` | 32–34 |
| `powdermagnon-r` | `powdermagnon -r` | 36–38 |
| `powdermagnon` | `powdermagnon` | 40–42 |
| `mcdisp` | `mcdisp` | 44–46 |
| `mcdiff` | `mcdiff` | 48–50 |
| `cpsingleion` | `cpsingleion` | 52–54 |
| `mcphas2jvx` | `mcphas2jvx CURRENT-FILE` | 56–58 |
| `singleion` | Numeric T/Hext/Hxc; corresponding flags | 91–93 |
| `ic1ion` | Prompts for T/Hext/Hxc; corresponding flags | 95–100 |
| `formfactor` | `formfactor` | 102–104 |
| `bfk` | `bfk` | 106–108 |
| `run-anisotropy` | Temperature, field, plane/steps or polycrystal settings, optional ion file/exchange fields | 110–142 |
| `makenn` | Distance, interaction option, A, and option-specific values/files | 144–190 |
| `setup-jqfit` | `setup_jqfit -h … -k … -l …` | 192–194 |
| `setup-mcdiff-in` | T, Ha/Hb/Hc, x/y flags | 196–204 |
| `setup-mcdisp-mf` | T, Ha/Hb/Hc, x/y flags | 206–214 |
| `pointc` | Current file, charge, x/y/z | 216–228 |
| `mpe` | Shell process running `mpe`; buffer `mpebuffername` | 230–232 |
| `javaview` | Shell process running `javaview CURRENT-FILE` | 234–236 |
| `cif2mcphas` | `cif2mcphas CURRENT-FILE` | 238–240 |
| `display-density` | `display_density` | 242–244 |
| `display-densities` | Selected density option and numeric/file inputs | 246–337 |

`makenn` supports `-rkky`, `-rkky3d`, `-rkkz`, `-rkkz3d`, `-kaneyoshi`, `-kaneyoshi3d`, `-bvk`, `-cfph`, `-f`, `-dm`, and `-d`.

`display-densities` supports `-f`, `-tMSL`, `-tHex`, `-tI`, `-c`, `-s`, `-o`, `-m`, `-j`, `-p`, `-div`, `-L`, `-M`, and `-P`.

### Toolbar and hooks

Noninteractive **`my-mcphas-mode-toolbar-buttons`** copies the global toolbar and makes the result buffer-local (`:340–403`). Installed on `my-mcphas-mode-hook` (`:406`).

Its first matching filename branch supplies:

| Filename | Added actions |
|---|---|
| `.cif` | `cif2mcphas` |
| `calcsta.bat`, `.forfit` | calcsta, simannfit, searchspace |
| `.sipf` | pointc, mpe, singleion, ic1ion, formfactor, display-density |
| `mcphas.ini`, `mcphas.j` | mcphas, singleion, jqfit, mcphasjforfit, mcphas2jvx, makenn, powdermagnon, mcdisp, display-densities, anisotropy |
| `mcdisp.par`, `mcdisp.mf` | mcdisp |
| names ending `cef` or `par` | bfk |
| `mcdiff.in` | mcdiff |
| Other `.j` | No extra action |
| `.sps` | setup-mcdiff-in, display-densities |
| Other `.mf` | setup-mcdiff-in, setup-mcdisp-mf, display-densities |
| `.sipf.levels` | cpsingleion |
| `.qei` | powdermagnon-r |
| `.jvx` | javaview |

References: `:343–401`.

- Only the mcphas runner explicitly names an image: **`mcphas-mcphas`** (`:360`); the other buttons supply nil images.
- A second mode hook adds `#…` comment highlighting and double-quoted string highlighting for buffer names ending `.sipf`, `.cif`, `.tst`, `.grid`, or `.j` (`:418–444`).
- No local menus, advice, or keyboard shortcuts.
- Toolbar maps are installed, but `init.el:39` disables toolbar display; maps alone do not establish visible buttons.

### Requirements and uncertainties

- Requires the McPhase executables/scripts named in the table, project input files in the current working directory, Wine64 for `calcsta.bat`, and a `javaview` executable/runtime.
- Commands rely on shell PATH; no installation paths or environment setup are declared.
- **Filenames and free-text inputs are not shell-quoted**, notably `mcphas2jvx`, `pointc`, `javaview`, `cif2mcphas`, anisotropy, and several `makenn` branches.
- Polycrystal anisotropy sets `nofsteps` to `""`, then calls `number-to-string` on it: an apparent error (`:119–120,134`).
- Anisotropy’s advertised “press Enter to skip” file prompt uses `read-file-name` with must-match enabled; skipping is not reliably represented as an empty string (`:124–140`).
- `setup-jqfit`’s third interactive specification is `l:`, not `nl:`—apparently invalid (`:193`).
- `.sipf.levels` has a toolbar branch but no matching automatic mode registration (`:393–394,412`).
- Toolbar construction is filename-based and runs on mode entry; no rename-refresh hook is installed.
- Many runners are explicitly marked TODO/FIXME/test-needed. CLI correctness was not runtime-verified.

## 6. `ada.el`

### Public command and behavior

**`ada-mode`** (`:11–26`) is an interactive mode derived from `prog-mode`, redefining that conventional package symbol.

It installs:

- A fixed Ada keyword regexp (`:5–9`).
- Case-insensitive searching and font-lock (`:17,24`).
- Sexpression parsing that does not ignore comments (`:15`).
- Parenthesis blinking that does not ignore comments (`:16`).
- **Pascal-style comment settings:** `{ … }`, with a start regexp also recognizing `(*` (`:18–21`).

### Missing/inactive functionality and requirements

- No custom indentation: both indentation assignments are commented out (`:13–14`).
- No Ada `--` comment syntax implementation; the source explicitly marks it FIXME (`:18–21`).
- No syntax-propertization implementation enabled (`:25`).
- No file-extension registrations.
- Org source-language integration is commented out (`:28–29`).
- No installed hooks, advice, menus, toolbar buttons, or custom keys.
- No compiler/LSP/GNAT dependency declared; this is a lightweight highlighting mode.
- Does not provide an `ada` or `ada-mode` feature.

**Migration risk:** loading it overrides an existing `ada-mode` function, but loading another Ada package afterward can override it again. Existing extension associations/autoloads therefore affect which implementation runs.

# Migration dependencies

## `manifest.scm`

The entire root manifest is four lines:

- Active packages: **`python`, `coreutils`, `git`, `emacs-minimal`** (`:1–4`).
- `python-pyte` is commented out (`:3`).
- No package versions, channel pins, or the numerous configured Emacs packages are specified.

**This manifest is not a complete reproducible Emacs environment.** In particular, it does not declare Magit, Embark, PDF Tools, Xah Wolfram mode, or the external scientific executables above.

The active workspace integration discovers a project’s nearest `manifest.scm`, rather than always using this root file (`guix-workspace.el:31–38,101`; loaded by `custom.el:614`).

## `.gitmodules`

Read all 30 root lines.

| Path | URL | Branch | Lines |
|---|---|---|---|
| `combobulate` | `https://github.com/mickeynp/combobulate.git` | master | 1–4 |
| `elfeed-tube` | `https://github.com/karthink/elfeed-tube.git` | master | 5–8 |
| `notebook-mode` | `git@github.com:rougier/notebook-mode.git` | unspecified | 9–11 |
| `ssass-mode` | `https://github.com/AdamNiederer/ssass-mode.git` | master | 12–15 |
| `vue-html-mode` | `https://github.com/AdamNiederer/vue-html-mode.git` | master | 16–19 |
| `vue-mode` | `https://github.com/AdamNiederer/vue-mode.git` | master | 20–23 |
| `xenops` | `https://github.com/dandavison/xenops.git` | master | 24–27 |
| `ultra-scroll` | `https://github.com/jdtsmith/ultra-scroll.git` | unspecified | 28–30 |

Relevant distinctions:

- **Explicitly used local checkouts:** `ssass-mode`, `elfeed-tube`, and `xenops` (`custom.el:664–687`).
- `ultra-scroll` is actively configured, but no explicit local-checkout load-path reference was found (`custom.el:2049–2055`).
- Combobulate references found in startup are comments.
- No direct startup loading references found for `notebook-mode`, `vue-html-mode`, or `vue-mode`; current Vue configuration names `genehack-vue-mode` (`custom.el:1811–1815`).
- Nested test submodule: `combobulate/tests/html-ts-mode`, SSH URL `git@github.com:mickeynp/html-ts-mode.git` (`combobulate/.gitmodules:1–3`).

SSH URLs require suitable access. Actual checked-out/gitlink revisions were not inspected.

## `icons/`

**21 XPM files:** 17 root files and four tab images.

```text
embark-act.xpm
elfeed.xpm
emms.xpm
gptel.xpm
magit.xpm
mcphas-crystal.xpm
mcphas-mcphas-magnet.xpm
mcphas-mcphas.xpm
mcphas-spin.xpm
mu4e.xpm
org-agenda.xpm
org-capture.xpm
org-node-find.xpm
org-node-grep.xpm
org-store-link.xpm
osm.xpm
ripgrep.xpm

tabs/close.xpm
tabs/new.xpm
tabs/left-arrow.xpm
tabs/right-arrow.xpm
```

- Fifteen root images are 24×24; `ripgrep.xpm` is 24×21 (`:4`).
- `mcphas-crystal.xpm` is 196×193, with 12,019 colors (`:3`).
- Tab images are 18×18 (each `:4`).
- No licensing/provenance text was found in the targeted metadata inspection.

**Active path dependency:** `custom.el:88` adds configuration-relative `icons` to `image-load-path`. `mcphas.el:360` depends directly on `mcphas-mcphas.xpm`; other global toolbar references occur at `custom.el:125–167`.

**Path mismatch:** active `early-init.el:52–54` instead references **`~/.emacs.d/icons`**, with tab image names at `:61,73,85,97`. Migration must reconcile that path with the current configuration location.

## `snippets/`

The local directory exists but contains **no files found**, including hidden/ignored-file searches. No explicit startup reference to this local directory was found.

Actual snippet dependencies are:

- `~/src/guix/etc/snippets/yas` — `custom.el:638–641`
- `~/src/guix/etc/snippets/tempel/*` — `custom.el:643–647`
- Project-relative `etc/snippets/yas` and `etc/snippets/tempel/*.eld`, found through `.dir-locals.el` — `init.el:182–203`

These external Guix/project snippet trees—not the empty local directory—are the meaningful migration dependencies.

**Remaining limits:** symlink targets, checkout revisions, installed executable availability, and runtime behavior were not established. No inactive variant functionality was included in the live-module inventory.
