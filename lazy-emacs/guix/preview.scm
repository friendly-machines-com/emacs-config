;; Optional TeX/diagram tools; keep executable ownership with Guix.
;; Combine with the editor manifest when these tools are not already installed.
(use-modules (guix profiles))
(specifications->manifest
 '("texlive-scheme-basic" "texlive-amsmath" "texlive-amsfonts" "texlive-mathtools"
   "texlive-xcolor" "texlive-tools" "texlive-braket" "texlive-esint" "texlive-units"
   "texlive-unicode-math" "texlive-preview" "texlive-mylatexformat" "texlive-dvisvgm"))
