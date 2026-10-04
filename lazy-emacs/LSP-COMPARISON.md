# Emacs 31 Eglot versus the retained lsp-mode/Rustic integration

## Versions actually examined

- Guix PGTK **31.1**: `package-built-in-p` returns t for Eglot. The selected library is inside Emacs's own lisp/progmodes directory, not a separately installed ELPA package.
- Rustic **3.5**, lsp-mode **10.0.0**, lsp-ui **9.0.0**, VHDL-ext **0.8.0**, rust-analyzer **1.93.0** from the current recorded Guix channels.
- Read Eglot's actual 31.1 implementation; many old comparisons incorrectly omit features now present, especially inlay hints, semantic tokens and type/call hierarchy.

This is a source/API comparison plus built-in/capability verification, not a claim of end-to-end Rust protocol parity. No production client selection has been changed by this comparison.

## Core functionality matrix

| Functionality | Eglot 31.1 | lsp-mode / current integration |
| --- | --- | --- |
| Completion | CAPF, usable with existing Company; snippets via existing Yasnippet | CAPF/Company, snippets |
| Hover/signature documentation | ElDoc, documentation buffer, Markdown renderer options | ElDoc plus configured lsp-ui floating mouse-hover docs and sideline hover |
| Diagnostics | Flymake; pushed and supported pull diagnostics | LSP diagnostics / Flycheck integration and lsp-ui sideline |
| Definitions/references/declaration/implementation/type definition | Xref and public Eglot commands; existing Consult Xref can present results | Xref plus lsp-ui peek presentation |
| Rename / code actions / refactors / server edits | Supported; server-edit confirmation and diff preview | Supported |
| Formatting | Supported | Supported; current config chooses one Format All save path |
| Inlay hints | **Supported**, including hint overlays/tooltips/navigation/edits | Supported; existing Rust preferences need server-config translation |
| Semantic-token highlighting | **Supported** | Supported, with additional Rust-specific modifier mappings |
| Workspace/document symbols | Xref/Imenu | Xref/Imenu plus lsp-treemacs tree |
| Call/type hierarchy | **Supported** with native hierarchy UI | Supported; different UI |
| Progress / reconnect / project sessions / file watching | Supported | Supported |
| Code-lens buttons and Rust run/debug lenses | No corresponding builtin CodeLens UI implementation found | Rust-analyzer run/debug/implementation/reference lenses supported |
| Rust-analyzer-specific extension commands | Not automatically supplied by builtin Eglot | Explicit extension request/command handlers in lsp-rust.el |
| Debugging | Not an LSP feature; Eglot does not replace a debugger | dap-mode integration currently depends on lsp-mode |

Eglot's design delegates to native Emacs facilities rather than duplicating the UI. Backend capability parity is therefore distinct from preserving the configured mouse popup/sideline/peek presentation. Changing that UI must be acknowledged, not described as an identical replacement.

## What Rustic already supports with Eglot

`rustic-lsp-client` explicitly accepts `eglot`, `lsp-mode` or nil. Its native startup path requires Eglot, registers a rust-analyzer subclass for rustic-mode and calls eglot-ensure. There is no reason to add private-function advice or a second Rustic startup hook merely to select it.

Independent of that choice, Rustic retains:

- Cargo build/check/run/rerun/clean/bench/new/init/update/add/rm/doc workflows;
- Cargo tests, nextest and local test-at-point scanning;
- Cargo Clippy/fix and Rustfmt commands;
- interactive Cargo/comint programs;
- cargo-expand and rerun;
- compilation/output/error handling, Cargo popup and editing helpers.

Thus switching the client does **not** mean replacing or discarding the Rustic package. Cargo functionality is not something Eglot needs to reimplement.

## Why it is not a complete drop-in replacement for every Rustic/LSP feature

Current Rustic has concrete integration gaps, not merely different preferences:

1. **Rust-analyzer macro expansion:** Rustic's display callback calls lsp-workspace-root. The requesting command is lsp-rust-analyzer-expand-macro using rust-analyzer/expandMacro; no corresponding Eglot wiring exists in the reviewed Rustic implementation. cargo-expand remains available but is a different operation requiring a separate tool.
2. **Converted-doc browser:** Rustic has an Eglot hover helper, but its dispatcher checks a variable named eglot, not Eglot's managed-buffer state, and project tracking still uses lsp-mode. The presence of an Eglot helper is not proof the complete workflow works.
3. **Missing-dependency insertion:** explicit Eglot/Flymake parsing exists, but selection checks the same inappropriate eglot variable and the automatic hook is lsp-after-diagnostics-hook. Automatic support is documented lsp-mode-only.
4. **Analyzer extensions:** lsp-mode supplies syntax/item/HIR trees, analyzer status, join/move items, workspace reload, parent-module/Cargo.toml navigation, external docs, run/rerun/debug runnables and related tests. Eglot has public extension interfaces, but builtin Eglot/Rustic do not automatically reproduce this command collection.

Several of these helpers are optional or not explicitly enabled by this config. That makes them potentially acceptable tradeoffs—not evidence that every Rustic integration is preserved.

## Rust settings do not transfer by renaming the client

lsp-rust-analyzer-* preferences are lsp-mode-specific. Under Eglot their equivalents belong in JSON-compatible `eglot-workspace-configuration`, normally under the rust-analyzer section. Translate and verify against the installed analyzer version:

- Clippy/check command;
- chaining hints;
- lifetime-elision mode and parameter names;
- closure-return hints;
- parameter hints;
- reborrow hints.

Use `:json-false` where an actual JSON false is required, not assume Lisp nil always has that meaning. Enum options remain strings.

The reviewed lsp-mode source also exposes two inherited configuration problems: the display-prefixed closure-return option is not used by its initialization builder (which reads lsp-rust-analyzer-closure-return-type-hints), and reborrow-hint enable is an enum string, not boolean nil. They must be corrected in a chosen client configuration, not copied as apparent parity.

Rustic's eglot-rust-analyzer initialization method returns its own detached-files/empty-object options and does not merge the next/default initialization method. Prefer the supported workspace-configuration interface for settings rather than assuming a contact :initializationOptions plist will override that subclass.

## Removing lsp-mode globally is a separate dependency migration

Even after Rust selects Eglot:

- **DAP:** current dap-mode unconditionally requires lsp-mode and its Guix package propagates it and lsp-treemacs. Dropping it requires a separate Dape/GUD/debugging migration, including Python attach, GDB/GDBserver, watches, frame selection, breakpoint persistence and key targets. Dape is independent of lsp-mode, but replacing declarations alone does not prove debugger parity.
- **Vue:** current Volar is a TypeScript hybrid/add-on bridge. lsp-volar configures the TypeScript plugin and forwards tsserver/request/response to another server. Builtin Eglot contains no equivalent bridge; a simple vue-language-server registration is not established parity.
- **VHDL:** VHDL-ext supports an eglot feature/server registration and can migrate at runtime, but its current Guix package still propagates lsp-mode. Removing the package closure requires a package variant/upstream dependency change too.
- **ccls:** ordinary C/C++ services work with Eglot; ccls-specific navigation/notification helpers are not automatically transferred. The server executable must remain even if the emacs-ccls integration is removed.
- **TeX:** Digestif is already an Eglot alternative; do not add automatic TeX startup where none was configured.
- **Symbol tree:** lsp-treemacs-symbols must be replaced by an Eglot-compatible UI or explicitly dropped. Plain Treemacs is independent and can remain.

Stopping lsp-mode in Rust buffers, removing direct declarations, and removing it from the Guix closure are three different claims.

## Conclusion

**Eglot is a credible, full-featured choice for normal Rust development plus Rustic's core Cargo workflow. It is not an exact replacement for every current Rustic/LSP extension and configured UI.** Consequently the strict condition “replace all the integration without behavior regression and drop lsp-mode” is not yet established.

Recommended direction: select native Eglot for Rust if the explicit UI/extension differences are acceptable, translate analyzer preferences and exercise a real Rust workspace. Retain/port the genuinely used analyzer extras through supported extensions; migrate Vue and debugging separately before claiming global removal. Do not silently throw away those features merely because Eglot is builtin.

## Source references

- Emacs 31.1 lisp/progmodes/eglot.el: native UI design (45–94); builtin Rust/Digestif contacts (241–315); public connection/configuration APIs (1666 onward, 3140–3221); completion, diagnostics, refactors; inlay/semantic/hierarchy implementations (5219 onward).
- Rustic 3.5 rustic-lsp.el: native selection/setup/registration (15–141), lsp-specific macro display (143–178).
- Rustic rustic-doc.el: project tracking and backend dispatcher/hover implementations (207–211, 382–429).
- Rustic rustic-cargo.el / rustic.el: dependency-insertion implementations and lsp-only hook (769–857 / 165–166).
- lsp-mode 10 clients/lsp-rust.el: analyzer extensions (969–1101, 1551–1771), options initialization (1773–1930).
- lsp-ui 9 lsp-ui-doc.el / lsp-ui-sideline.el / lsp-ui-peek.el: distinct popup/sideline/peek UI.
- lsp-mode clients/lsp-volar.el: TypeScript plugin and two-server bridge (77–133).
- VHDL-ext 0.8 vhdl-ext.el / vhdl-ext-eglot.el: supported eglot feature and registrations.

No existing configuration files were modified for this research.
