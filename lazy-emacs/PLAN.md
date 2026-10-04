# Lazy PGTK Emacs migration plan (review draft)

Planning began 2026-10-03. Implementation is now present; see [launch instructions](README.md), [implementation choices](IMPLEMENTATION.md) and [validation](VALIDATION.md). The original configuration remains unchanged. This plan records the design discussion; current code and those implementation documents supersede unresolved draft alternatives below.

## Scope and evidence

Target the actual Guix `emacs-pgtk` 31.1, not a hypothetical 2026 release. `guix build emacs-pgtk` resolved `/gnu/store/66pynpvm1cdkv08mcxynm7z7vhc0wyxp-emacs-pgtk-31.1`. Its clean batch runtime reports PGTK, native compilation, tree-sitter, SQLite, modules, libxml2 and SVG support. Both `use-package` and `window-tool-bar` are built in. Installed Emacs NEWS, Custom implementation, the Guix site-start implementation, and window-tool-bar's source were inspected. No existing init files were evaluated: that would start services, read credentials, and install global process-output advice. The four entry/config files passed a non-executing reader/parens check.

Success means the same approved workflows, keys, menus, faces, file associations, environment inheritance, security boundaries, persistence and background behavior—not just the same package list. Static configuration shows what is configured, not which features are actually used, nor whether every old workaround works on current package versions.

## Approved scope decisions (user follow-up)

- Keep Gnus/Gmane for **news only**, mu4e for email, and agent-shell. Preserve Gnus/MIME/message settings also honored by mu4e; separating entry points must not postpone shared email behavior until Gnus is started.
- Explicitly remove Xenops, Kiwix, McPhase, Wolfram, Pascal/Lazarus, the local lightweight Ada mode, local llama-cli completion, **GPTel entirely**, and Claude Code IDE from the replacement. Remove associated startup loads, routes, templates/actions/settings where they belong exclusively to those features.
- Org reminders must operate from daemon startup, **before any GUI frame or Org command**. Keep Org Node/Mem continuously indexing from startup; don't hide this work behind first search.
- Defer recursive EMMS music import until first EMMS entry (including M-x emms); initialize once per session, not on every browser/playlist opening. Mail polling follows the native mu4e service-start lifecycle; the user permits compose/link entry to start it too, avoiding an unnecessary explicit-M-x-only gate. No mail service/polling in ordinary daemon startup.
- PGTK daemon is the normal deployment. The inspected Guix Emacs 31 source migrates minibuffers but does not establish universal pending-prompt cancellation when the last GUI closes. Keep an early modernized safeguard; `read-key` needs separate consideration. See DAEMON-SOURCE-REVIEW.md. Actual isolated PGTK tests are required before removing/narrowing guards.
- Profiling is opt-in; don't start the CPU profiler by default.
- Drop the experimental mu4e vtable replacement entirely; use ordinary mu4e headers with preserved UI actions.
- Use the local `org-mode/lisp/org-latex-preview.el` and matching Org modules as the math engine. Org and agent math must not depend on Xenops. **Port SHR MathML** in mail/news/EWW to this engine. Standalone `.tex` buffers retain AUCTeX editing/build only; no inline-preview adapter. Remove all dangling Xenops hooks/calls.
- Remove EBDB and its hooks/completion integration, preserving mu4e's native recipient completion and the old contact database. No replacement contacts package now; revisit contacts in a later session. Keep unbreak menu generation as essential GUI discoverability; remove the other queried one-off/bulk/export helper commands.
- Restore Babel evaluation confirmation and disable configured shell-escape LaTeX execution, including retained preview/export/build commands. Gnus NNTP must require encryption with no automatic plaintext fallback; server support remains to be verified. Mail archive folder is **Archive**.
- Replace global save-on-frame-close with frame-local saving, including tracked hidden/tabbed buffers. Do not use buffer-list FRAME as a filter or save-some-buffers globally. Keep the frame alive on failed/cancelled saves; propose refusing final-frame closure while unsaved user work remains elsewhere. See FRAME-CLOSE-POLICY.md.
- **No extra toolbar row.** Keep actions in the existing tab-line layout, using a documented formatter seam and composed maps. No additional vertical toolbar space.
- Bug/inconsistency repairs are approved; record them as intentional changes and test the repaired behavior. User data and the original configuration remain untouched.
- Guix shell is mandatory containment: Loki does not sandbox itself. Host Emacs socket access is opt-in/default-off, and there is no default blanket /tmp share. Optional tmux inspection may use a narrow opt-in mount. Compilation without a manifest/trusted Guix environment must refuse, never fall back to the host. Other Guix/log/source/AI config shares still need clarification.
- Language stack/booster policy, remaining Guix/source/AI-config shares, the proposed last-frame unsaved-work rule and final state-migration details still need resolution. Existing manifest/local-variable trust approvals were not broadly revoked by the Babel/TeX decision.

## 1. Ownership and layout

Proposed final layout (names are negotiable):

```
lazy-emacs/
  early-init.el             minimal security/startup guards and early policy
  init.el                   stable hand-managed bootstrap
  gui-settings.el           Emacs-managed Customize variable/face output
  features/                 small declarations, triggers and integration setup
    ui.el completion.el editing.el projects.el programming.el
    org.el documents.el media.el feeds.el email.el news.el agents.el
    guix.el                  retained TeX/Maxima/Julia integrations stay feature-local
  user-lisp/                maintained local commands/packages; lexical binding
  assets/                   live icons, snippets, templates
  state/                    this test instance's databases/history/bookmarks
  cache/                    generated/replaceable data
  tests/                    ERT plus a PGTK interactive acceptance checklist
  guix/                     package manifest/dependency record
  INVENTORY.md PLAN.md
```

The GUI writes only `gui-settings.el`, never hand-written source. There is no requirement to keep conventional file names that are misleading here. If desired, retain the old arrangement instead: a tiny stable loader in GUI-managed `init.el`, hand-managed `custom.el`. The essential property is distinct ownership and predictable precedence.

Copy/consolidate *effective* approved preferences into the saved-settings file. Do not reapply them later with scattered `setq`, `set-face-attribute`, or `use-package :custom`: that would undo changes made in Customize. Procedural feature setup stays in modules. New abstractions expose documented `defgroup`, `defcustom` and `defface` entries, with proper setters that update an already-running Emacs as well as future buffers/frames. Factory defaults may use a configuration-only theme below the user Custom theme; never reset user overrides on feature load. Native package options remain accessible in Customize; loading a package while explicitly customizing it is expected.

Security invariants are not ordinary appearance preferences. Name/document them distinctly and enforce them at execution boundaries. Do not present a saved GUI option as proof of containment.

## 2. Guix alone owns installed packages

Use built-in `use-package` with `use-package-always-ensure` nil and explicit `:ensure nil` for external declarations. Do not use `:ensure f`: in the verified Emacs 31 macro expansion, it requests the package **f**, not false. Remove package-install, archive refresh, `:vc`, automatic server/grammar downloading and accidental ELPA dependencies. Keep Guix's package/autoload discovery: disabling package.el installation does not mean discarding Guix load-path/autoload integration.

Emacs 31 loads `site-start.el` before `early-init.el`. Guix's site-start calls `guix-emacs-autoload-packages` and registers package-descriptor support. Audit the real site's autoload effects before assuming user early-init precedes every third-party action. Normally keep Guix site initialization; only a documented launcher-controlled sequence can give user policy precedence over site-start itself. If that precedence is necessary for containment, use a carefully tested `--no-site-file` launcher and explicitly initialize the trusted Guix autoload integration *after* early policy—not `-Q`, which also bypasses the configuration under test.

Keep explicit, reproducible local overrides where functionality relies on modified packages. The current Org checkout reports `9.8-pre`, git version `release_9.7.39-855-g1ef59f`; it cannot be silently replaced with stock Org 9.7 while agent math calls its new preview APIs. Record patched source versions and eventually package them with Guix; no version swap during a pure laziness migration.

## 3. Early security/startup layer

Preserve before any feature activation:

- Agent client read/write-text-file capabilities disabled, including when providers are loaded in a different order. Set base policy early, register after-load enforcement where necessary, and verify it again when creating each client.
- Project/container selection and Guix command wrapping before starting any agent or compilation subprocess. Loki supplies no containment. Missing configuration/manifest or rejected trust must reject execution rather than fall through to a host process. Validate configured runners against this policy. Host Emacs socket and host /tmp mounts are excluded by default; permission opt-ins apply only to newly launched containers.
- Headless input guard and last-frame minibuffer cancellation before daemon/server requests can block startup. Emacs 31's `frame-initial-p` replaces reliance on the internal daemon bootstrap frame variable; exclude initial/dummy, temporary server, child and tooltip frames; a nonempty frame-list is insufficient. Require an actually usable PGTK input frame, accounting explicitly for hidden/iconified states and GUI mapping races. GUI-only does not exclude PGTK daemon/client operation.
- Fixed configuration root and real home captured before buffer-env mutates project process environments.
- Required load-path ordering for the patched Org, plus necessary PGTK frame geometry/image setup before first display.
- Existing HiDPI toolbar separator workaround until an actual PGTK 31 test shows it is obsolete.

Do not blindly move all current early-init contents to this layer: menus, tab icons and ordinary appearance declarations do not all need to run before packages. Conversely, do not use idle timers for security policy. Preserve diagnostic trace behavior until its continued use is clarified. The current CPU profiler and conflicting debug-on-quit assignments are diagnostics, not proven startup requirements.

The LSP booster JSON advice evaluates bytecode from parser input globally. Inventory it as an existing trust-sensitive behavior; ask whether to retain it. Never silently extend that advice to other subprocesses during refactoring.

## 4. Lazy feature declarations

Load only small declaration/registration files at startup. Use real entry triggers (`:commands`, `:bind`, `:mode`, `:interpreter`, `:hook`), then feature-specific `:config` and `with-eval-after-load`. `:defer t` alone is not a trigger. `:after` specifies ordering but does not itself guarantee useful activation. Prefer explicit entry points over guessed idle loading; they make first-use latency and dependencies testable.

Examples of boundaries:

| Feature | Entry/activation boundary |
| --- | --- |
| mail | native mu4e service startup on opening/composition/links; polling permitted then, never ordinary daemon startup |
| Gnus | gnus / news commands and Gnus links |
| Org | reminders and Node/Mem indexer at daemon startup; other Org integrations on buffer/command/protocol entry |
| Org preview | first actual preview/agent math activation, not initial scratch |
| agent-shell | agent-shell / Loki start command, after early policy is installed |
| LSP/DAP | matching programming buffer or explicit LSP/debug command |
| TeX/Maxima/Julia/Jupyter | file mode, REPL, Babel block execution or notebook command |
| Magit/Forge | Magit/Forge entry commands, commit/rebase file modes |
| EMMS / Elfeed / OSM / weather | menu/toolbar/key/command invocation; EMMS library import on first EMMS entry |
| PDF / EPUB / media | file associations and document commands |
| EAT / Eshell / shell helpers | terminal/Eshell creation |
| Guix tools | associated mode or public command; removed scientific/local language extensions are excluded |

GUI essentials should be available on the first visible frame: keys, tabs/toolbars, appearance, popup/window policy, and minibuffer completion. Enabling an actual global minor mode can legitimately have startup cost. Buffer-local completion/spelling/formatting/highlighting should activate when matching buffers are created. Register integration hooks before packages fire them, including commit, mu4e, agent, Org, and local-variable/environment hooks.

Custom settings need special care: `custom-set-variables` can load libraries through `custom-autoload`, REQUEST fields and mode setters. Merely deferring `use-package` will not prevent that. Ordinary unloaded variables can retain saved values until their `defcustom` is executed. For genuinely lazy feature enablement, expose lightweight feature switches whose setters register/unregister triggers; map old native global-mode preferences only where equivalent. Do not hack every variable's Custom metadata or lose GUI save/reset/setter semantics. Keep required global modes eager and measure them. Load declarations/integration hooks before applying settings that activate modes.

## 5. Common abstractions

### A. Actions and toolbar composition

A small action registry is shared by menus, toolbar items and optional keys. Each entry has stable ID, label, help, command/autoload target, icon, visibility, enable predicate and optional toggle state. Reuse native menu items where practical so disabled/toggle behavior stays correct. It must not require the command's entire package to register or display the entry.

Three independent layers:

1. A small, GUI-customizable global action map (mail, agenda/capture, search, projects, applications, etc.; exact membership/order to confirm).
2. Native major-mode toolbar plus declarative feature-specific additions.
3. Active minor-mode/buffer-context action maps (e.g. pending agent permission, compile/debug, mail headers versus message view).

Compose keymaps with intentional precedence (context overrides duplicate native IDs; global IDs stay available); don't repeatedly copy the current global map and freeze it in each buffer. Rebuild only when context/options change, reuse maps, and invalidate the renderer cache on async status changes. Predicates must be cheap and cannot load a package or start a process during redisplay. Buttons execute in the clicked window/buffer. Keep contextual actions buffer-local; define a separate frame/global launcher map if wanted.

Current mu4e headers copy the global map and append compose/reply-all/reply/forward/move/execute/trash/refresh; message view replaces it with a separate map (reply-all/reply/forward/move/flag/trash/execute/previous/next). Other modes also replace maps, so global actions disappear. New composition unifies these without losing native EWW/Help/Info toolbars. Preserve message-composer send/attach/spell/sign/encrypt/kill actions and handle inherited message/mu4e hooks deliberately.

### B. Window chrome composition

Current selected tab text includes `window-tool-bar-string` by replacing a built-in formatter globally. Use the documented `tab-line-tab-name-format-function` customization seam with a named function, retaining the existing selected-tab placement. No additional toolbar row or vertical-space allocation is permitted. Preserve tabs, full-path tooltips and close behavior. `window-tool-bar-string` is expressly usable in tab/header/mode lines. Do not simply enable `global-window-tool-bar-mode` alongside global tab-line-mode: they compete for `tab-line-format`.

Make one owner of window chrome, composing toolbar, tabs and optional sticky Org heading/status. This addresses the current org-sticky-header conflict rather than choosing whichever mode writes the header last. Placement, global-vs-context grouping and icon/text style should be GUI preferences. PGTK tests must cover two windows, different buffers, nonselected windows, narrow splits, HiDPI, disabled/toggled actions, new frames and theme changes.

### C. Environment/process service

One layer supplies buffer-env/project environment inheritance, real-home/config-root isolation, trusted manifest checks and container-aware process launching. Babel, compilation, REPL, LSP, DAP, agent and Guix commands use explicit integration adapters. Keep environment-bound temp files correct. Do not replace TRAMP with local-process wrappers or make security-critical containment best-effort.

### D. Buffer policies and compatibility patches

Use reusable, opt-in mode policies for formatting, completion, spelling, indentation, fonts, popup routing and diagnostics. Account for derived/common base modes so tree-sitter remaps don't lose hooks. Enforce one chosen formatter/server policy per language without silently dropping currently used alternatives.

Place each compatibility patch next to its owning feature, with problem reference, supported API/version/capability check and regression test. Install it when that feature loads, before its first real action. Replace core-function redefinitions with documented extension points where behavior is equivalent. Removal of a workaround requires evidence, not merely a higher version number.

### E. Persistence and diagnostics

Use explicit configurable state/cache roots and an independent named server for testing. Persistent user data is not scratch: credentials, bookmarks, abbrevs, EBDB contacts, playlists/scores, Forge DB, saved document places, histories, known projects and trust decisions need a migration decision. Fresh test state avoids locking/clobbering a running old Emacs; final migration can copy selected data after shutting down writers. Prefer explicit root-relative paths over `~/.emacs.d` and HOME-sensitive expansion.

A diagnostics command reports feature status, chosen library paths/versions, missing Guix packages/executables/grammars, active patches and timings. Missing optional dependencies produce clear first-use errors; missing security dependencies prevent execution. Startup diagnostics/profiling are opt-in, not always-on work.

## 6. Modern Emacs 31 features to use selectively

- Built-in use-package and window-tool-bar: no ownership fight or unnecessary external duplicate.
- `user-lisp/` automatic autoload scraping and byte-compilation for maintained local commands. Cookies expose commands without loading implementation. Exclude notes, backup variants, tests and unrelated source checkouts from this tree. Measure first-run compilation separately. For reproducible minimal startup, prepare it explicitly with `prepare-user-lisp` after edits and arrange activation without unnecessary re-scraping; implementation must follow/test actual startup ordering, not assume defaults. Every local file gets a lexical-binding cookie after checking dynamic-binding dependencies.
- `frame-initial-p` for daemon-safe GUI guards.
- `load-path-filter-cache-directory-files` as an optional measured lookup optimization. Emacs supports it via `load-path-filter-function`; validate cache behavior after live Guix profile changes/local edits rather than treating it as mandatory.
- `setopt` for procedural Custom-aware changes where appropriate, `keymap-set`/`defvar-keymap`, hook depths, derived/base-mode hooks and capability-based Tree-sitter routing. These conveniences do not justify changing saved preferences or selecting a different completion/LSP package.
- Native compilation of maintained modules after functional correctness; moderate temporary startup GC tuning with guaranteed restoration. Don't globally remove file-name handlers (breaks TRAMP/encrypted files), suppress errors, disable security checks, or postpone everything to idle and call that success.

## 7. Implementation and acceptance sequence

1. Confirm open questions in INVENTORY.md; record which inactive/scratch-looking commands are nevertheless used through M-x.
2. Build a functionality-to-new-module/trigger/test matrix from this inventory. Seed GUI preferences from effective old settings, keeping a separately reviewable list of intentional fixes.
3. Create the minimal bootstrap, early safeguards and isolated test paths. Test startup security before adding ordinary features.
4. Migrate GUI/key/completion/chrome policies, then local maintained packages and each independent workflow module. Keep email as its own unit; put Gnus/feeds/media separately.
5. Establish a Guix dependency manifest including external tools, fonts and grammars; preserve the local patched Org preview and agent APIs initially; exclude Xenops entirely. Inspect actual runtime package resolution through the same Guix profile/shell used for the GUI.
6. Run non-evaluating reader checks, byte compilation where safe, ERT dependency/loading tests, Custom set/save/reset/restart tests, and an actual PGTK manual acceptance pass. A batch -Q run is not a GUI startup or Guix site-integration benchmark.
7. Compare cold/warm startup and first visible usable frame, first invocation latency per feature, GC and loaded libraries. Empty GUI startup should not load mail/Gnus/EMMS/Elfeed/LSP/DAP/TeX/Jupyter unless an approved startup task actually needs them. Background notifications/indexing intentionally requested at startup must retain that timing.
8. Test `emacs --init-directory=/home/dannym/.config/emacs/lazy-emacs` using the PGTK build with the required Guix package environment. If using a daemon, use a distinct server name and socket/state directories. Do not use -Q for this normal test because it skips early-init/init.
9. Verify credentials/containment failures, daemon startup without a GUI, first/new/last frame handling, HOME mutation, Org protocol callbacks, remote Babel, email sending/marking/threading with standard mu4e headers, formatter order, tree-sitter fallback, and all listed toolbars.
10. Only after parity approval, stop writers and migrate selected durable state; switch the default directory with a rollback path. Delete neither the old config nor historical data during testing.

No startup-time target is promised before measuring the current GUI with the actual installed package set. First-use cost, Custom compatibility and security behavior are acceptance criteria alongside speed.
