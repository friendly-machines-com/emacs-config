# Migration decisions and remaining questions

This records the user's answers after the static inventory. The inventories describe the **old** configuration. The user subsequently authorized implementation, remaining choices by judgement, topic commits, and the proposed frame-close policy. Implementation is now present; see [current choices and rationale](IMPLEMENTATION.md) and [launch/validation instructions](README.md). Original config/state is unchanged. Earlier questions below are discussion history, not a request blocking implementation.

## Confirmed

### Retain

- Gnus/Gmane for **news**, not mail. mu4e remains the email client. Shared Gnus/MIME/message settings that affect mu4e must be installed independently of starting the Gnus news reader.
- agent-shell (including the retained Loki/Org math workflow).
- Use the **existing local** `org-mode/lisp/org-latex-preview.el` and its matching Org tree, not a stock substitute. It calls org-assert-version and depends on local Org support/export APIs. Preserve the existing agent-shell-org-math adapter, which already uses this renderer without Xenops.
- Keep mu4e's native recipient completion from indexed mail. **Remove EBDB**, per the user's subsequent explicit decision. Do not add an alternative contacts package now; an Org-based contacts integration may be considered in a later session. Preserve the existing EBDB database without loading or modifying it.
- Dynamic `unbreak` menu generation is explicitly essential; retain it and make generated entries available when their packages/modes become available, without requiring every package at startup.
- All other inventoried active workflows unless explicitly excluded or later clarified.

### Remove from the replacement

- Xenops, its mode hooks/settings/converter definitions, vendored dependency and inactive Xenops-based agent math variant. This does not mean remove math preview: use the local Org preview engine. SHR MathML currently calls Xenops and needs a port or an explicit removal decision; LaTeX-buffer preview behavior also needs clarification.
- EBDB and its Gnus/mu4e/Message hooks/completion integration. Preserve native mu4e completion and the old contact database; no replacement contacts package in this migration.
- Kiwix.
- McPhase, its runners, broad scientific/file extension overrides, JVX launcher and feature-specific assets/actions.
- Wolfram integration.
- Pascal/Lazarus integrations and project registrations.
- Custom lightweight Ada mode override.
- Local llama-cli completion (the hand-written copilot.el, not a statement about unrelated GitHub Copilot packages).
- GPTel entirely, including its backend, menu/toolbar entries, rewrite/send keybindings and feature-specific settings; user has not used it in years.
- Claude Code IDE setup.
- Experimental mu4e vtable replacement, its overrides and face changes. Ordinary mu4e header rendering remains.
- Among the specifically queried occasional helpers, remove bulk Org-tag cleanup, crate-moving, Google-result copying, NotDeft web import, DOCX keyboard-macro export and blog-template helpers. **Retain unbreak menu generation.** This does not remove normal Org tags/export/publishing or Guix workflows.
- Remove no-confirmation Babel policy: restore evaluation confirmation by default. Remove configured shell-escape LaTeX execution; ensure retained Org preview, TeX compilation and export do not silently reintroduce it. Re-enablement is deferred to a later user session.

Do not confuse removing configuration with deleting external user documents, mail, model files, credentials or scientific projects. None of those will be deleted.

### Startup/activation timing

| Functionality | Required timing |
| --- | --- |
| Org reminders | Daemon startup, even before any GUI frame or Org command; not optional idle/first-use initialization |
| Org Node/Mem indexing | Keep live indexing from startup; user reports small files and very fast indexer |
| EMMS library import | First EMMS use, explicitly including M-x emms; once per session |
| Mail polling | Native mu4e service lifecycle on first mail use (opening, composing or following a mail link is acceptable); never ordinary daemon startup. User relaxed the explicit-M-x-only distinction in favor of simpler behavior. |
| Profiler | Opt-in debugging affordance, disabled by default |
| Security/daemon guards | Early; don't defer policy while deferring packages |

The eager Org requirement is intentional, not a failure of laziness. Defer unrelated Org exporters/preview/notebook/PDF machinery and other applications where possible without deferring reminders/indexing.

### GUI and maintenance

- PGTK **daemon** is the normal setup. The internal initial/dummy frame is not an input frame. `frame-list` being nonempty (or frame-live-p being true) cannot establish that user input is possible. Exclude frame-initial-p, temporary server dummy frames, child/tooltip frames and unusable hidden frames from prompt eligibility; account explicitly for recoverable iconified frames and initial GUI mapping. If the last usable GUI closes during input, abort/unwind pending input instead of transferring an indefinite wait to the dummy frame. Source review does not establish a universal built-in fix in 31.1.
- No new toolbar row or additional vertical toolbar space. Keep existing tab-line placement, preserving tabs, context actions and persistent global actions within it.
- Bug/inconsistency fixes are authorized. Record deliberate changes and add regression checks rather than perpetuating broken behavior in the name of parity.
- GUI Customize remains the preferred preference/face editing interface.

## Clarification 3: what containment currently permits

The current guix-workspace wrapper runs agents with `guix shell -C -N -W -m ...`:

- `-C`: container filesystem/process environment.
- `-N`: network access is allowed.
- `-W`: nested Guix operation is enabled.
- Guix normally shares the current working directory writable; explicit `--share` mounts add other **writable host paths**. `--expose` is read-only.

Current extra shares include Claude/Codex/Loki configuration, Loki source, `/run/user/1000/emacs`, `/tmp`, `/var/log/guix`, and `/var/guix`. Variables ending `_KEY`, `_TOKEN` and `_PAT` are preserved; agent-shell-loki also injects provider keys from auth-source. These grants can be useful, but a container is not then limited to editing the project.

In particular, sharing the **host Emacs socket** and installing emacsclient allows a process with socket access to request arbitrary host Emacs Lisp evaluation. A container tool can thereby ask host Emacs to access files/run commands outside the container. Disabling ACP client read/write-text-file capabilities does not prevent that socket path or shell tools accessing writable mounts. Actual use also depends on the socket/authentication setup and permissions; the mount is nevertheless an important explicit authority grant.

The current policy differs by operation:

- Agent client construction fails if neither a configured runner nor an authorized manifest-derived runner exists.
- Compilation without a manifest deliberately falls back to the host.
- A configured agent runner can take precedence over manifest-derived runner selection.

### Confirmed containment decisions

- **Host Emacs control is opt-in, default off.** Do not share the host Emacs socket in ordinary agent containers. An explicit GUI-customizable permission must disclose that access enables host Emacs Lisp execution; changing it affects newly launched containers, not the mounts of already-running ones.
- **No blanket /tmp share by default.** Access is not regularly needed. tmux socket/session inspection may be useful occasionally; any such exposure is opt-in and narrowly specified where feasible, not a reason to expose all host /tmp. The optional affordance may be omitted if unnecessary.
- **Loki provides no containment of its own.** Guix shell is the authoritative boundary and must be installed/configured before any Loki/agent client is created. Never assume the Loki launcher sandboxes itself.
- **No host compilation fallback.** If there is no suitable manifest/explicit trusted Guix environment, compilation must fail with a clear explanation instead of returning/running the original host command. A missing or rejected manifest cannot weaken this policy.

Remaining share decisions: `/var/guix`, `/var/log/guix`, Loki source and AI configuration directories were not explicitly approved by this answer. Do not silently infer approval. Determine actual needs and expose only the minimum necessary paths/credentials, distinguishing agent and compilation policies. Existing agent fail-closed behavior is retained; compilation is now also fail-closed.

Use distinct launch policies with safe defaults and explicit opt-ins. An existing globally configured runner must not silently bypass mandatory Guix containment or reintroduce forbidden default shares.

## Clarification 6: development integrations and booster

Current client split is not itself a bug:

- Python starts Eglot; it also enables Jedi and Flycheck. Eglot normally contributes completion via CAPF and diagnostics via Flymake, while Company is the popup frontend. Depending on settings/package versions, multiple completion/diagnostics producers may coexist.
- Rust/Rustic has lsp-mode/rust-analyzer settings, LSP UI and hint preferences; formatting-on-save and generic Format All integrations can overlap.
- Vue loads both Volar and Vetur clients, with an LSP hook. Whether both compete at runtime depends on client selection and versions; eager require alone does not prove two servers run.
- VHDL has LSP/extensions and native-vs-generic formatting hooks; remapping to tree-sitter can bypass classic-mode hooks.

Recommendation: preserve **Python Eglot and Rust/Vue/VHDL lsp-mode**, not switch everything to Eglot just for fashion. Select one intended primary completion/diagnostics/formatter policy per language while retaining additional checkers only where they add desired behavior. Keep Company as the UI unless the user requests a switch.

Questions: any Jedi-specific completion or separate Flycheck linting you rely on? Which Vue server is intended? May redundant format-on-save paths be consolidated into one? Unknown behavior remains pending rather than silently removed.

The booster is a separate trust decision. init.el:733–759 installs global JSON-parser advice: if input starts with `#`, read a Lisp bytecode object and **execute it inside host Emacs**. Ordinary JSON parsing processes data; this path executes code. That is not confined by the language server's process/container boundary, and the current advice isn't limited to one LSP connection. Removing it does not remove LSP features, but may change performance.

Recommendation: omit the bytecode booster initially, use the current native JSON parser and measure LSP responsiveness on this fast machine. If needed, evaluate an explicitly scoped, verified acceleration strategy separately. User approval is pending.

## Preview follow-up

Xenops removal is confirmed. Preserve Org and agent math via the local Org preview. Two other contexts were previously Xenops-dependent:

1. **Retain and port MathML** in HTML mail/news/EWW: adapt `shr-tag-math/shr-tag-math.el` to explicit org-latex-preview-place entries using the local renderer. No Xenops dependency.
2. **Standalone `.tex`: AUCTeX editing/build support only.** No Xenops and no new inline-preview adapter. Keep previews in Org and agent-shell.

Never leave either integration calling missing Xenops functions; do not enable Org parsing/Org major mode in non-Org message/agent/TeX buffers merely to get images.

## Additional targeted questions

- **GPTel:** resolved—remove entirely.
- **EBDB:** resolved by subsequent explicit decision—remove its integration, retain native mu4e completion, and preserve the old database. Alternative contacts integration deferred to a later session.
- **Occasional helpers:** resolved—only unbreak is retained from the queried list; other listed helpers removed.
- **Execution trust:** resolved—restore Babel confirmations and remove shell-escape LaTeX. Other local-variable/manifest trust approvals were not explicitly revoked; review separately rather than interpreting this as permission to rewrite them all.
- **News encryption:** require encrypted NNTP. Verify the actual server capability and certificate behavior before selecting mandatory STARTTLS or implicit TLS. No automatic plaintext downgrade. If the server cannot meet the requirement, report it and revisit with the user. This check is still pending.
- **Compose vs polling:** resolved—whatever is simpler is acceptable. Preserve native mu4e service-start timer behavior (including composition/links); never initialize the mail service for normal daemon startup.
- **Mail folder correction:** **Archive** is authoritative. Correct the shortcut path; preserve unambiguous keys and make collisions GUI-editable.
- **Frame close:** replace global saving with frame-scoped saving. Include modified buffers associated with the closing frame, not every daemon buffer. Design for hidden/tabbed buffers and the last usable frame; see FRAME-CLOSE-POLICY.md. Keep a failed/cancelled save from closing the frame.
- **Test state:** use independent state while testing and copy selected bookmarks/contacts/histories/databases only at final cutover? Proposed yes, to avoid modifying/locking the active daemon's state.
