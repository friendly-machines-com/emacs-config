;; Exact channels used for this migration's Emacs 31.1 validation.
(use-modules (guix channels))
(list
 (channel (name 'guix) (url "https://git.guix.gnu.org/guix.git")
          (branch "master") (commit "8f080c0523423a00699e29e6ac4b19686c24fba0")
          (introduction (make-channel-introduction
                         "9edb3f66fd807b096b48283debdcddccfea34bad"
                         (openpgp-fingerprint "BBB0 2DDF 2CEA F6A8 0D1D E643 A2A0 6DF2 A33A 54FA"))))
 (channel (name 'guix-ai-cloud) (url "https://codeberg.org/daym/guix-ai-cloud")
          (branch "master") (commit "36d4baa7593530cf4c0f5f8127abf789591975ec")
          (introduction (make-channel-introduction
                         "ba6015f3120e56a18eeb31ee31cbd0efc25dbb94"
                         (openpgp-fingerprint "76CE C6B1 7274 B465 C02D B3D9 E71A 3554 2C30 BAA5"))))
 (channel (name 'nonguix) (url "https://gitlab.com/nonguix/nonguix")
          (branch "master") (commit "c0192e90a52cafb4d33b04734cbe9bbedd703a04")
          (introduction (make-channel-introduction
                         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
                         (openpgp-fingerprint "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5")))))
