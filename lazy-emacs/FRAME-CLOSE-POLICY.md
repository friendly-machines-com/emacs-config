# Proposed frame-local save/close policy

The user wants closing a GUI frame to save **that frame's** buffers, not every modified buffer in the daemon, and does not want a headless daemon left full of unsaved work. This design is a proposal awaiting confirmation of the last-frame rule; no replacement close handler has been installed.

## API/source findings

Verified with the Guix PGTK 31.1 build and source:

- `(buffer-list FRAME)` is **not a filter**: it returns all live buffers, ordering the frame's buffers first. It cannot be used as the set of buffers to save.
- Merely passing a frame predicate to save-some-buffers is also insufficient for strict isolation: its initial loop saves every modified buffer with buffer-save-without-query, without consulting that predicate. It additionally invokes global save-some-buffers-functions. Implement explicit target-buffer saving instead of calling it globally.
- Default window-buffer-change-functions callbacks receive a frame; buffer-local callbacks receive a window. Use the documented global form to track actual displayed work, not incidental with-current-buffer selections.
- The existing handler calls global save-some-buffers, kills unmodified buffers displayed in the frame, then deletes it. Neither global saving nor blanket buffer killing is part of the new proposal.

## Scope

1. Use the **frame being closed** from the close event/command, not whichever frame happened to be selected at the time.
2. Record real user buffers displayed/visited in each top-level PGTK frame. Include current windows, tab/window history and recorded recently displayed buffers, so switching tabs does not evade saving. Track before mutation as well as at redisplay and synchronize a final snapshot at close; do not rely solely on redisplay callbacks for rapid buffer switches. Weak/live-buffer bookkeeping avoids retaining killed buffers.
3. Exclude minibuffers, daemon initial/dummy frames, child/tooltip frames and temporary server frames. Do not treat buffer-list FRAME as ownership.
4. Save modified file-backed buffers associated with this frame, including buffers currently hidden behind its tabs. Do not save modified buffers belonging only to other open frames.
5. A buffer displayed in two frames is one shared buffer; saving it from either frame necessarily persists the same edits. There cannot be independent save states for those two views.
6. For meaningful non-file work (editable notes/scratch or unsaved composition/drafts), offer explicit save-to-file/draft or keep-open actions. Never auto-send mail, silently invent a filename, mark the buffer unmodified to hide it, or auto-save process output/diagnostic logs as user documents.

## Close sequence

- Keep the frame alive and input-capable throughout saving/review.
- If closure occurs during an existing prompt, first safely unwind/cancel the old input and schedule the close workflow outside that input context; don't nest an unrelated save dialog into a stranded recursive edit. Cover direct read-key questions separately. Never wait for a new answer on the internal initial frame.
- Save the explicit frame target set using ordinary save-buffer semantics, preserving save hooks, externally-modified-file checks, remote/GPG behavior, formatting and errors.
- A failed save, conflict cancellation, declined required save, or Escape/cancel **keeps the frame open**. Recheck the target set after save hooks, because a successful save can leave another target modified.
- Do not kill successfully saved buffers just because the frame closed. Buffers/processes shared with other frames must continue to work.
- Programmatic non-user frame cleanup (child/tooltips/transient server frames) must not trigger unrelated save dialogs. User-initiated top-level close paths must use the same policy; don't rely only on a post-deletion hook, when it is already too late to save safely.

## Last usable GUI frame: proposed rule

Before deleting the final usable frame, detect remaining unsaved **user work**, including file buffers not in this frame's tracked set and meaningful unsaved notes/drafts. This is a safety check, not permission to save every daemon buffer automatically.

If anything remains, keep this frame open and present a review list. The user can explicitly bring the orphaned buffers into the current frame, save them (or explicitly discard appropriate work), and then close. Cancel leaves the frame open. No extra permanent toolbar row is needed; a normal transient review buffer/dialog is sufficient.

Proposed default: **do not allow the last GUI to close while unsaved user work remains**. This avoids leaving edits inaccessible without turning every ordinary frame close into a global save. If the user prefers an explicit 'leave work unsaved in daemon anyway' override, add it as a separately confirmed Customize option, not the default.

A save error can itself prompt; final-frame deletion must never occur before that error/interaction has completed. If the compositor/window manager destroys the surface despite the normal close protocol, log/recover without attempting headless saving prompts and preserve buffers in memory; proactive closing safeguards cannot promise prevention of forced external destruction/crashes.

## Acceptance cases

- Two frames with disjoint modified files: closing one saves only its associated files.
- A modified file hidden behind a tab/window history is included in that frame's save set.
- Shared buffer in two frames is saved once and not killed.
- Another frame's buffer-save-without-query buffer is not saved as an accidental side effect.
- Save hooks, read-only/external conflicts, remote files/GPG and mail drafts: failure/cancellation keeps the GUI.
- Escape or 'quit the save sequence' is not treated as successful completion.
- Last frame with orphaned file/scratch/draft work remains open for review; process/agent/compilation logs do not cause spurious unsaved-work warnings.
- Closing during completing-read, nested minibuffers, y-or-n/read-char/read-key questions leaves no wait on the dummy frame; server requests remain recoverable.
- Tests distinguish native GUI close, explicit delete-frame commands, hide/iconify, transient-frame cleanup and actual daemon shutdown.
