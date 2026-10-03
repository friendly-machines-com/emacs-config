# PGTK 31.1 daemon prompt source review

## Source and limits

`guix build -S emacs-pgtk` returned `/gnu/store/s0qhfxdm0d0gj704rw98pmfxx0g7d756-emacs-31.1.tar.zst`. It was extracted under `/tmp/emacs-pgtk-source-review/emacs-31.1` for read-only inspection. The built PGTK binary previously resolved is `/gnu/store/66pynpvm1cdkv08mcxynm7z7vhc0wyxp-emacs-pgtk-31.1/bin/emacs`.

This is a source-path investigation, not an actual last-PGTK-frame-close reproduction. Do not infer that every old hang is fixed from the version number, nor that the same historical bug necessarily reproduces in 31.1. Actual PGTK/Wayland daemon/client tests remain an acceptance requirement before removing guards.

## Directly inspected mechanisms

- `src/minibuf.c`, `barf_if_interaction_inhibited` (~1296–1301): signals inhibited-interaction **only if the flag is already set**. `read-from-minibuffer` calls it before entering input (~1367). The global default is false (~2697 onward). This supplies a mechanism for our early headless policy, not a universal automatic check for a GUI frame.
- `src/minibuf.c`, `read_minibuf` (~653–661): batch/daemon-before-detach special handling reads noninteractively. That special path does not establish safe behavior for a fully running daemon whose last GUI frame has subsequently disappeared.
- `src/minibuf.c`, `read_minibuf` (~670–714): choose a minibuffer frame, record unwind cleanup, make its frame visible. Normal frame visibility handling is not equivalent to aborting an input wait after frame deletion.
- `src/minibuf.c`, `move_minibuffers_onto_frame` (~189–214): frame switching/deletion can transfer active minibuffer stacks to the new frame. This function preserves input state, rather than itself cancelling the recursive input wait.

There are two requirements to test separately:

1. A timer/server callback tries to ask a question with no real input frame.
2. A real prompt is pending, then its last GUI frame closes (including nested prompts and direct read-key/read-char questions).

Do not advise all read-event calls as an attempted blanket fix: Emacs also uses event reads for non-user events and backend processing. Preserve headless checks/cancellation only at appropriate prompt/lifecycle boundaries, with trace logging optional and low-overhead.

## Conclusion after frame/server/PGTK tracing

**Do not remove the guard on the assumption that Emacs 31 fixed last-GUI-frame closure during an active prompt.** The source has minibuffer migration fixes, but the inspected close/deletion path does not universally cancel pending input. No targeted last-PGTK-frame-during-prompt regression test was located. This is not a runtime assertion that every old hang still reproduces.

- `lisp/frame.el`, handle-delete-frame (~265–280), can force-delete the GUI frame when the daemon initial frame qualifies as another frame. It doesn't check/abort active minibuffer recursion. frame-deletable-p has separate checks, but this handler does not consult it.
- `lisp/server.el`, server-handle-delete-frame (~500–513), disconnects the client, not its pending prompt.
- Server filters serialize requests while server--process-filter-active is bound (~1162–1182). A prompt inside an active filter can prevent subsequent client requests from being dispatched until it unwinds; opening another client isn't a guaranteed recovery path. This is a control-flow inference, not a reproduced deadlock.
- Inhibition checks in read-char/read-event/read-char-exclusive occur at entry, not after GUI closure. read-key has a separate read-key-sequence-vector path without that inhibition check. The current config already notes this gap.

Retain an early modernized headless/last-frame safeguard, add explicit pending-minibuffer and direct-question acceptance tests, and keep trace/profiling diagnostics opt-in. Removal or narrowing of any guard requires an actual isolated PGTK daemon/client test, including nested prompts and server-filter evaluation.

See [detailed source paths, historical fixes and tests](DAEMON-SOURCE-TRACE.md). Source C/Lisp line numbers can differ slightly between display tools because some files contain form feeds.
