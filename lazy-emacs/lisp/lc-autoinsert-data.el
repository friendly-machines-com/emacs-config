;;; lisp/lc-autoinsert-data.el --- Retained definitions/data -*- lexical-binding: t; -*-
(require 'lc-core)
(define-auto-insert '(".*\\.vala\\'" . "Vala program")
  '("Vala program" "// SPDX-License-Identifier: GPL-3.0-or-later" > n
    "/*" > n " * " (file-name-nondirectory (buffer-file-name)) > n
    " *" > n " * TODO: Describe." > n " */" > n "using Gtk;" > n "" >
    n "int main (string[] args) {" > n "    Gtk.init (ref args);" > n
    "    var window = new Window ();" > n
    "    window.title = \"First GTK+ Program\";" > n
    "    window.border_width = 10;" > n
    "    window.window_position = WindowPosition.CENTER;" > n
    "    window.set_default_size (350, 70);" > n
    "    window.destroy.connect (Gtk.main_quit);" > n
    "    var button = new Button.with_label (\"Click me!\");" > n
    "    button.clicked.connect (() => {" > n
    "        button.label = \"Thank you\";" > n "    });" > n
    "    window.add (button);" > n "    window.show_all ();" > n > _ n
    "    Gtk.main ();" > n "    return 0;" > n "}" > n))

(define-auto-insert '(".*\\.scm\\'" . "Guix package")
  '("Guix package" "; Guix package definition." n
    "(use-modules (guix packages))" n "(use-modules (guix gexp))" n
    "(use-modules (guix build-system glib-or-gtk))" n
    "(use-modules (guix build-system gnu))" n
    ";(use-modules (guix build-system maven))" n
    ";(use-modules (guix build-system node))" n
    "(use-modules ((guix licenses) #:prefix license:))" n n
    ";(define %source-dir (getcwd))" n "(define "
    (file-name-sans-extension
     (file-name-nondirectory (buffer-file-name)))
    "\n" "  (package\n" "    (name \""
    (file-name-sans-extension
     (file-name-nondirectory (buffer-file-name)))
    "\")\n" "    (version \"0.1\")\n" "    (source " _ "(origin\n"
    "              (method url-fetch)\n"
    "              (uri (string-append \"TODO:\" name \"-\" version \".tar.gz\"))\n"
    "              (sha256 (base32 \"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\"))))\n"
    "    (build-system gnu-build-system)\n"
    "    (native-inputs (list))\n" "    (inputs (list))\n"
    "    (synopsis \"TODO: A brief description of the package.\")\n"
    "    (description \"TODO: A longer description of the package.\"))\n"
    "    (home-page \"TODO: url\")\n"
    "    (license #f)) ; TODO: Put license.\n"
    (file-name-sans-extension
     (file-name-nondirectory (buffer-file-name)))
    n))

(define-auto-insert '("manifest\\.scm\\'" . "Guix manifest")
  '("Guix manifest" ";;; Guix manifest definition." n
    "(specifications->manifest" n
    " (list \"rust\" \"rust-analyzer\" \"ccls\" \"ocaml-lsp-server\" \"gcc-toolchain\" \"gdb\" \"rr\" \"texlive-minted\" \"texlive-scheme-basic\" \"dvisvgm\" \"python-lsp-server\" \"tidy-html\"))"
    n))

(provide 'lc-autoinsert-data)
