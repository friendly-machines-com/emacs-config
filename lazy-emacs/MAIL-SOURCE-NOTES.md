# Shared Gnus/mu4e and polling source notes

Guix `guix build -S mu` resolves current source `/gnu/store/hb953slsm12bc1wkzjbikw63svslpcaj-mu-1.14.3-checkout`. This is evidence about the current Guix package, not proof of the version installed in the running host profile. Recheck profile/version before implementation; do not silently change mu/mu4e versions.

## Shared settings are necessary

- mu4e-view.el requires gnus-art (~32), uses Gnus MIME/article rendering, and defines mu4e-view-mode derived from gnus-article-mode (~1121).
- mu4e-compose.el requires gnus-msg (~33), and mu4e-draft.el uses Gnus article decoding for draft reconstruction.
- Gnus header/MIME/image options and hooks may therefore affect mu4e without the user ever opening the Gnus news application. The mu4e obsolete-variable aliases explicitly map mu4e-view-inhibit-images to gnus-inhibit-images and blocked images to gnus-blocked-images.
- Split shared MIME/article/message behavior from NNTP/group/summary/news-reader behavior. Apply shared settings before first mail rendering, while keeping Gnus news entry itself on demand.
- Old gnus-article-mode-hook toolbar replacement can run for derived mu4e views. The new toolbar compositor must select the mu4e-specific actions rather than installing a Gnus news toolbar indiscriminately. Shared bug-reference/spelling/message hooks should still work.

## Polling lifecycle

mu4e.el:137–151 starts the periodic update timer in mu4e--pong-handler after the mu server starts, not merely because `(require 'mu4e)` occurred. The timer starts with zero initial delay, then repeats at mu4e-update-interval. mu4e--stop cancels it (~190–195).

Other mail entry points can initialize the server too, so 'load on demand' alone is not proof that polling starts only after an explicit M-x mu4e. Separate the desired update interval from permission to begin periodic polling, if the user confirms that composition/stored links should not activate polling. Test server callbacks, first explicit mail opening, subsequent openings, quit/restart and Customize interval changes. Keep manual fetching available as a distinct explicit action.

## Gnus NNTP TLS

The inspected Emacs 31 nntp.el:1209–1250 maps nntp-open-network-stream to network type and passes a capability-based STARTTLS command to open-network-stream. It can negotiate STARTTLS when offered; these settings are not an explicit require-encryption policy. Ask whether mandatory encryption is desired and verify the actual server's support before selecting a connection policy.
