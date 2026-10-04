# Lazy PGTK Emacs configuration

Implementation is isolated here; the original startup files and live state are unchanged. Review the `lazy-emacs-migration` branch's topic commits before switching your default configuration.

## Launch

From the original configuration directory:

```sh
DIR=/home/dannym/.config/emacs/lazy-emacs
guix shell -m "$DIR/manifest.scm" -- emacs --init-directory="$DIR" --daemon=lazy-emacs
guix shell -m "$DIR/manifest.scm" -- emacsclient --socket-name="$DIR/state/server/lazy-emacs" --create-frame
```

For an ordinary standalone GUI test, omit `--daemon=lazy-emacs`. Do **not** add `-Q`: it bypasses normal init/site integration. The frame-save/close policy is designed for your daemon deployment.

Use your existing Guix Home/profile if it already supplies the dependencies; `manifest.scm` is a reproducible package/environment reference, not an Emacs installer. The tested channel revisions are in `guix/channels.scm`; optionally use `guix time-machine -C ... -- shell ...` to reproduce them. No package.el archive refresh, installation, :ensure t, or grammar download is part of startup.

**Real Org data must be available** at the migrated default paths `~/doc/org-agenda` and `~/doc/org-roam`, or configure `org-agenda-files` and `org-mem-watch-dirs` for your actual locations. Production does not filter out missing paths or invent empty data directories. The test suite supplies its own documents separately. A timer being active is not evidence that an unavailable real calendar was processed.

## Ownership / Customize

- `early-init.el`: early security and daemon policy.
- `init.el`: small hand-managed loader.
- `lisp/`: feature declarations/integrations.
- `user-lisp/`: maintained local commands/adapters.
- `vendor/`: isolated matching source snapshots (especially your custom Org preview).
- `defaults.el`: initial migrated preferences, not reapplied on every launch.
- `gui-settings.el`: created from defaults once; **Emacs Customize owns it thereafter**.
- `private.el`: local-only migrated news credential; ignored by Git, never included in tests.
- `state/`, `cache/`: independent runtime/generated files, ignored by Git.

Start with `M-x customize-group RET lazy-config`, plus native package groups and `customize-face`. In particular `lc-global-actions` / `lc-mode-actions` control toolbar contents. Tabs and actions share the existing tab line: there is no extra toolbar row. Missing-command generation (`unbreak`) is enabled; its menu is rebuilt when package/mode context changes, without eagerly loading every command implementation.

`M-x lc-diagnostics` reports library resolution and loaded/deferred status. Native saved Custom values are respected; a small one-time deferred-value bridge also handles old package preferences implemented as plain `defvar`, rather than resetting preferences on every feature load.

## Startup versus first use

**At daemon startup:** Org Notify and continuous Org Node/Mem indexing. Profiling is off; opt in through `lc-profile-startup` for the next startup.

**At first visible frame:** GUI-only padding/scroll/cursor setup.

**On invocation:** mail, news, agents, music, feeds, LSP/DAP, TeX/PDF/notebook machinery and other applications. Shared Gnus/MIME preferences are available to mu4e; this can load Gnus core preference definitions without opening the news reader or a network connection.

- Mail polling follows mu4e's native service lifecycle, including composition/mail-link entry. It does not start on normal daemon startup.
- EMMS imports `lc-music-directory` once on first browsing/EMMS entry, not at startup or merely requiring the library.
- MathML in mail/news/EWW uses the local explicit-entry Org preview API. Agent math keeps your Org-based adapter. No Xenops; standalone `.tex` buffers use AUCTeX editing/build only.
- Babel confirmations are restored and configured unrestricted shell escape is removed. No LSP bytecode booster.
- EBDB/GPTel/Kiwix/McPhase/Wolfram/Pascal/local Ada/llama-cli/Claude IDE and the rejected helper commands are not configured.

## Execution / containment

Agents use agent-shell's **documented command-prefix option** and the owned Loki adapter's public ACP constructor. There is no advice on the private agent client factory or command builder. Loki supplies no containment: Guix is authoritative.

Explicit builds through Compile/Projectile and the local Sass commands require an approved local `manifest.scm` and run inside Guix; no manifest means refusal, not host fallback. This is a build/agent policy, **not a claim that the entire host GUI, all language-server internals, REPLs or renderers are sandboxed**.

`lc-guix-authorized-manifests` records exact content approvals. A changed recipe must be approved again. Guix evaluates recipes while preparing an environment, before its container is entered: approve only trusted Scheme and its transitive sources. Content checks are not a promise of protection against deliberate concurrent filesystem attacks or mutable code imported by an approved recipe.

Default agent grants: writable workspace, networking, read-only Loki program tree, and explicitly injected provider-key environment names. **No host Emacs socket, blanket /tmp, AI config directories, Guix state/logs or nested Guix grant by default.** Use the `lc-security` Customize group for deliberate additional grants. Socket permission allows arbitrary host Lisp execution. Mount changes do not revoke permissions from an already-running container: restart it. Guix/nested-build/state access can be added explicitly when needed; it is not silently assumed.

Credential source defaults to the original encrypted authinfo file. At final cutover, deliberately copy the encrypted file/signature/private settings and set `lc-authinfo-file` to the desired stable location. Never add them to Git.

## Mail index and existing state

The new mu index is separate (`state/mu`), so testing does not lock or write the old daemon's index. On first real mail setup use **`M-x lc-mail-initialize-index`** (also in Tools): initialize this index and read/index the configured Maildir asynchronously. It does not sync or send mail, and refuses to reinitialize an existing index. Then use `M-x mu4e`. Archive is `Archive`; colliding shortcuts are repaired and GUI-editable.

Bookmarks, abbreviations, histories, project lists, Forge/EMMS/news state and trust data have **not** been bulk-copied over live writers. Stop writers before copying databases. Keep the old directory as rollback; migrate selected durable state deliberately, never assume caches/backups are equivalent to user records. The old EBDB database is untouched.

## Frame closing

Closing a daemon GUI saves work associated with that frame, including hidden/tab-history files—not every daemon buffer. Failed/cancelled saves keep the frame open; saved buffers are not indiscriminately killed. Shared buffers remain shared.

The final GUI stays open with an unsaved-work review if orphaned edits/notes/drafts remain. Resolve them using normal save/discard actions and close again. Existing pending minibuffer/direct-key input is unwound before a new save interaction; the invisible initial frame is never treated as usable input.

PGTK/GTK's separate display-disconnection limitation is not fixed by this config. Closing a frame and shutting down its display/compositor are different events.

## Tests

Run from the original root:

```sh
emacs -Q --batch -l lazy-emacs/tools/check-elisp.el
emacs -Q --batch -l lazy-emacs/tests/test-core.el -f ert-run-tests-batch-and-exit
guix shell -m lazy-emacs/manifest.scm -- emacs --batch \
  -l lazy-emacs/tests/test-init.el -l lazy-emacs/tests/test-features.el \
  -l lazy-emacs/tests/test-sass.el -l lazy-emacs/tests/test-modes.el \
  -l lazy-emacs/tests/test-mail-index.el -f ert-run-tests-batch-and-exit
guix shell -m lazy-emacs/manifest.scm xorg-server -- \
  python3 lazy-emacs/tools/run-gui-tests.py
```

GUI tests use an actual PGTK daemon on a disposable Xvfb display, never your real display/server. They test real frame saving and pending questions, including real emacsclient filter requests followed by successful subsequent requests. They are not Wayland/HiDPI visual acceptance or real email delivery/model-provider tests.

Optional TeX tools are in `guix/preview.scm`. Combine manifests if your profile does not already supply them. Enable the real GUI MathML image test with `LC_PREVIEW_TEST=1`. `tools/check-news-tls.py` tests the public news server's STARTTLS/certificate without authentication or article retrieval; encryption failure never causes automatic plaintext fallback.

See `IMPLEMENTATION.md` for judgement calls, validation results and remaining acceptance checks. `INVENTORY*.md` document the original configuration, not the final retention list.
