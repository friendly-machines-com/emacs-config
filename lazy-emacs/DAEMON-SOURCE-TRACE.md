All references relative to `/tmp/emacs-pgtk-source-review/emacs-31.1`; line numbers are newline-based Grep numbering (Read drifts at form feeds).

## Main conclusion

**The inspected protections migrate existing minibuffers and reject some newly initiated interactions; they do not universally cancel a prompt when the last GUI frame closes.** There is also a concrete server-filter serialization path that could prevent subsequent client requests from recovering an already-blocked server request. This is source evidence, not a reproduced hang or a version-based fix claim.

## PGTK close path

- `src/pgtkterm.c:6846–6847`: `"delete-event"` connects to `delete_event`.
- `:5690–5708`: callback queues `DELETE_WINDOW_EVENT`, returns `TRUE`; GTK does not directly delete the frame.
- Queue processing: `:288–349`, `pgtk_read_socket` at `:3930–3960`.
- `src/keyboard.c:6234–6236`: event becomes `(delete-frame (FRAME))`.
- `:14531–14532`: special-event binding is `handle-delete-frame`.
- **`:3102–3139`, `read_char`: special-event commands execute immediately, then reading retries.** Closure can therefore execute inside an input-reading operation.

`lisp/frame.el:265–280`, `handle-delete-frame`, deletes with FORCE=t when another qualifying visible frame exists; otherwise calls `save-buffers-kill-emacs`. It has **no active-minibuffer, recursive-edit, or daemon-specific check**.

The daemon’s internal initial frame is marked visible at `src/frame.c:1443`; `frame-visible-p` reads that flag at `:3645`. It can consequently count as “another frame,” permitting last-GUI deletion rather than shutdown.

## Frame/minibuffer deletion protections

- `lisp/frame.el:195–228`, `frame-deletable-p`, rejects certain active-minibuffer frames. **`handle-delete-frame` does not consult it.**
- `src/frame.c:2598–2697`, `delete_frame`, checks remaining frames and surrogate minibuffer ownership. `:2620–2621` protects the daemon’s **initial frame**, not the last GUI.
- `:2789–2827`: absent another suitable visible same-terminal frame, deletion selects “some other frame.”
- `:2026,2841–2843`: switching/deletion invokes `move_minibuffers_onto_frame`.
- `src/minibuf.c:188–213`: transfer during deletion happens regardless of `minibuffer-follows-selected-frame`. `zip_minibuffer_stacks`, `:143–186`, preserves/interleaves nested minibuffer stacks.
- `src/frame.c:3020–3032`: deletion exits single-keyboard state if no frame remains on that keyboard.
- `src/minibuf.c:906`: input enters `recursive_edit_1`; `read_minibuf_unwind` at `:1100–1141` decrements minibuffer depth **on exiting**. Frame deletion transfers the prompt rather than explicitly requesting this exit.

Thus an existing prompt can remain pending after migration to the internal frame; inspected deletion logic does not establish automatic cancellation.

## Entry checks versus already-pending input

- `src/keyboard.c:10733,10771,10810`: `read-char`, `read-event`, and `read-char-exclusive` call `barf_if_interaction_inhibited` **at function entry**.
- `read_filtered_event`, `:10588–10628`, subsequently reads/retries through `read_char`; it does not repeat that check upon frame closure.
- **`read-key` has a distinct uncovered route:** `lisp/subr.el:3603–3695` uses `read-key-sequence-vector`, not `read-event`. Its C implementation (`src/keyboard.c:11904–12029`) has no `barf_if_interaction_inhibited` call; only the three calls above occur in keyboard.c.
- `lisp/subr.el:4148` onward: `y-or-n-p` defaults to minibuffer reading, but `y-or-n-p-use-read-key` selects the modal `read-key` branch. Do not treat all direct questions as equivalent.

A **new** minibuffer/read-event invocation reaches the existing inhibition/no-frame entry guard examined by the main agent. A prompt that passed that guard before GUI closure does not automatically pass through it again.

## Server paths worth emphasizing

Direct questions remain:
- `server-visit-files`, `lisp/server.el:1628`: deleted-file write question.
- `server-done`, `:1744`: save-file question.
- `server-kill-emacs-query-function`, `:1761`: other-client exit question.

`server-handle-delete-frame`, `:500–513`, disconnects the client; it does not abort the prompt.

**Potential recovery limitation:**
- `server-process-filter`, `:1162–1170`, queues requests while `server--process-filter-active` is true.
- `server--process-filter-all-pending`, `:1172–1181`, holds that binding while calling the filter.
- That filter can synchronously execute arbitrary code through `server-execute`/`server-eval-and-print` (`:1464–1470`, `:1487–1505`, `:883–899`).
- Therefore, **if a prompt blocks inside an active server filter**, subsequent client requests can remain queued until that prompt returns/unwinds. This is an inference directly supported by the control flow, not a runtime reproduction.
- `server-goto-toplevel`, `:1019–1035`, explicitly aborts an active minibuffer to avoid unusable new-display input; called only for `(or frame files)` at `:1467–1468`, not bare evaluation. It also cannot run until a queued request is processed.
- Newly signaled inhibition errors are caught and returned to the client: `:1555–1560`.

## History/tests

- `ChangeLog.3:32271–32313` (2021-03-21): **“Prevent open minibuffers getting lost when their frame gets deleted.”** Closest relevant fix; not specifically daemon/PGTK/last-GUI cancellation.
- `ChangeLog.4:144254–144275`, bug **55412**: regression fix avoiding selection of an inactive minibuffer.
- `ChangeLog.4:101213–101229`, bug **58877**: keep client frames during shutdown to avoid a useless error prompt. Test `test/lisp/server-tests.el:191–222`, `server-tests/server-force-stop/keeps-frames`, explicitly indirect.
- `ChangeLog.3:219393–219399`, bug **24326**: server shutdown hook runs last so other hooks retain a frame for questions.
- `test/src/minibuf-tests.el:419–432`: inhibition tests for new minibuffer/y-or-n/yes-or-no calls.
- `test/src/keyboard-tests.el:78–82`: inhibition tests for read-char/read-event/read-char-exclusive, **not read-key**.

No targeted NEWS/history entry or regression test explicitly covering **last PGTK GUI closure during an already-active prompt** was found.
