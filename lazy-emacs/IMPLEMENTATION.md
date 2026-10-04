# Implementation / review notes

## Ownership and scope

All implementation lives in `lazy-emacs/` on branch `lazy-emacs-migration`. Original startup files, local helpers, credentials and databases were not edited/deleted. Planning inventories remain historical source descriptions. Topic commits separate source snapshots, core safety, GUI, application families and tests.

Factory preferences were imported by reading—not evaluating—the old files. They are consolidated in defaults.el, then copied once to the ignored Customize-owned GUI file. The old cleartext news cancellation credential was copied only to ignored mode-0600 private.el; it is not committed or used in fixtures. Tests create their own state and Org documents, and never decrypt credentials.

## Explicit decisions made while questions were deferred

- No EBDB or replacement contacts package; retain native mu4e recipient completion.
- No bytecode booster: native JSON processing is adequate to start with; do not execute parser input inside host Emacs.
- Python defaults to Eglot/Company/Flymake, not simultaneous Jedi/Flycheck producers. Jedi and Flycheck remain available for explicit use. Rust keeps lsp-mode and configured analyzer hints; Vue selects Volar rather than Vetur. One generic Format All save path, with VHDL native beautification; no duplicate Rust format-on-save path.
- Rust's parent selection occurs at library load time. Its public option defaults to installed-grammar readiness, not blindly true; otherwise use the classic parent. No mode-function override or automatic grammar download.
- Removed queried bulk tag/crate/Google/NotDeft/DOCX/blog helper commands; unbreak is essential and enabled.
- Gnus is news-only; shared MIME/article settings are installed independently for mu4e. Ordinary mu4e headers replace the vtable experiment. Composer/mail links may start native polling; no daemon-start polling. Archive and shortcut collisions repaired.
- No blanket AI configuration/Guix state/log/tmp mounts. Additional mounts are explicit Customize options. Read-only Loki program source is exposed because the configured adapter must execute; provider keys are injected from auth-source, not exposed through whole credential directories.
- Compilation-start/Projectile/local Sass builds refuse absent/unapproved manifests. This is not an implementation of universal containment for the host GUI or every native REPL/LSP/rendering subprocess. Nested Guix access is not automatically granted; opt in to required service access deliberately.
- Last GUI is retained while unsaved user work remains. Current-frame saving includes native frame/window history, without using buffer-list FRAME as a filter or globally calling save-some-buffers.
- No automatic live-state database copying. Private mu index initialization is an explicit GUI action, not an unsolicited startup sync/index.

## Compatibility review: no convenience monkeypatches

The rejected Org Mem path-filtering advice and all associated filtering functions are **removed**. Production invokes the package against configured data. Missing test documents are addressed by fixtures outside hidden ancestor paths (which Org Mem deliberately excludes), not by editing package internals or suppressing missing data.

Other comparable cases were reviewed:

- **agent-shell:** no advice on its private client factory/command builder. Use the documented command-prefix callback and ACP's public constructor inside the owned Loki adapter.
- **Envrc/buffer-env:** removed stale private update interception and forced absolute REPL-program rewrites. Programs remain names resolved in the current environment.
- **Org Noter:** current stock has the historical start-location fix and module location hooks. Keep stock getters/start-location, the supplied PDFTools module, a thin public precise-note wrapper and public annotation activation hook.
- **Jupyter:** current allocator already uses start-file-process; remove the old replacement and use jupyter-executable/public commands.
- **Toolbars:** use documented tab formatter option, native separator rendering and public keymap-canonicalize. No replacement tool-bar-setup. Generated missing-menu discovery needed a re-entry guard in its OWN filter: where-is-internal traverses menus and can recursively invoke that filter. No patch to key lookup.
- **MathML:** namespaced handler registered via shr-external-rendering-functions, not a replacement for Emacs 31's native shr-tag-math. Queue records use named struct fields and Org's explicit-entry/finish APIs, not private process-buffer name polling. The local renderer's existing asynchronous return contract is documented without changing its behavior.
- **Sass:** owned local source fixed directly: lexical closures retain temporary inputs until public compilation-finish callbacks, compiler dispatch uses compilation-start, quoting/regexes corrected. No temp-file deletion immediately after starting an async compiler.
- **Data contracts:** capture/action/remap/debug/preview records have documented fields and named destructuring/accessors instead of unexplained slot offsets.

Remaining advice is deliberately bounded: public input readers/frame deletion for the user-required daemon safeguard; public compilation-start for the user-required build policy; public register-preview integration from Consult; original global-environment lookup/reminder behavior; original inheritenv Babel integration; and first-use EMMS import entry points. It is not used to make tests pass by changing production inputs.

## What has been validated

- Actual Guix PGTK 31.1 package environment and local Org 9.8-pre precedence.
- Core regression tests: paths, exact approvals, approval invalidation, no host fallback, mount defaults, shell quoting, headless readers, frame-scoped save helpers, conservative commit generation, safe build-dir cancellation, workspace vs symlinked recipe identity.
- Real package/init tests with isolated Org files: reminder timer and continuous index active, synthetic node indexed, reminder scan paths unchanged, capture targets usable, Custom preferences not reapplied, flat composed toolbar rendered, startup application deferral, required backend command declarations and trust/removal choices.
- Real package activation: public agent constructor/prefix, no private interception; MathML conversion, marker movement, cached/asynchronous completion; mu4e preferences without service/polling; native Noter/Jupyter implementations; all registered toolbar actions interactive; private publishing filename exclusions; Sass input lifetime and contained-build refusal.
- Actual PGTK daemon on an isolated Xvfb: frame-local/hidden-buffer saves, cancellation retains frame, final-frame orphan review, completing-read/direct read-key unwinding. Both question types also invoked inside real emacsclient filter requests; subsequent requests succeeded.
- Warm explicit init of the uncompiled config with two synthetic Org files was approximately 2.1–2.6 seconds. This excludes provisioning and is **not** a measured old-vs-new, cold, full-corpus or Wayland first-frame benchmark.

## Remaining acceptance / limitations

No real email delivery, model-provider turn, private contact/mail data, project language-server/debugger execution, news reading or user publishing was exercised. Do not infer those are end-to-end verified from mocked process-construction tests. Live TLS verification and actual TeX rendering results are recorded in VALIDATION.md when available.

PGTK was exercised with its real GTK backend on X11/Xvfb, not the user's Wayland compositor/HiDPI monitors. Do the visual/menu/click/focus/font pass on that environment before switching the default directory. Preferred Noto/Atkinson/Dijkstra fonts remain configured; a fallback font is provided for clean test environments. Jinx dictionaries are supplied, but LANG=C has no automatic dictionary selection; choose native jinx-languages for your actual language if necessary. No production locale override masks that test environment condition.

The matching local Org tree emits Emacs 31 obsolete when-let/if-let warnings. They are not suppressed or globally rewritten without semantic review. Byte/native compilation is optional after the correctness pass. Some optional native document modules report absent DjVu support; PDF workflow remains the target.

Real Org paths must exist and contain the real reminders. The initial asynchronous Org Node message about no IDs can precede worker completion; tests verify actual indexed entries, not just mode flags. If real data is missing, fix paths/mounts—do not filter it away.

Guix evaluates trusted manifest Scheme before entering its generated container; transitive recipe trust and concurrent-file attacks are not solved by a simple digest check. The configured containment boundary must not be represented as a sandbox for the whole host Emacs.
