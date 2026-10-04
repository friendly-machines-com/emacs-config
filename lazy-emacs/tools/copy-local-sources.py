#!/usr/bin/env python3
"""Copy maintained source/assets without caches, state, backups, or removed packages.
Run once from the old Emacs root. Never overwrite a destination.
"""
from pathlib import Path
import shutil
root = Path.cwd()
new = root / 'lazy-emacs'
def copy(src, dest):
    dest = new / dest
    if not dest.exists():
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(root / src, dest)
for source in (root / 'org-mode' / 'lisp').glob('*.el'):
    copy(source.relative_to(root), Path('vendor/org/lisp') / source.name)
for package, target in [('wakib-keys', 'wakib-keys'), ('ssass-mode', 'ssass-mode'), ('elfeed-tube', 'elfeed-tube')]:
    for source in (root / package).glob('*.el'):
        copy(source.relative_to(root), Path('vendor') / target / source.name)
for name in ['unbreak.el', 'modern-fringes.el', 'python-django.el']:
    copy(Path('lisp') / name, Path('user-lisp') / name)
for name in ['agent-shell-loki.el', 'agent-shell-org-math.el', 'autoresize.el']:
    copy(Path(name), Path('user-lisp') / name)
copy(Path('shr-tag-math/shr-tag-math.el'), Path('user-lisp/shr-tag-math.el'))
for source in (root / 'icons').rglob('*.xpm'):
    if not any(x in source.name for x in ['mcphas', 'gptel']):
        copy(source.relative_to(root), Path('assets/icons') / source.relative_to(root / 'icons'))
for package, dest in [('org-mode', 'org'), ('wakib-keys', 'wakib-keys'), ('ssass-mode', 'ssass-mode'), ('elfeed-tube', 'elfeed-tube')]:
    for name in ['COPYING', 'LICENSE', 'README.md', 'README.org']:
        if (root / package / name).is_file():
            copy(Path(package) / name, Path('vendor') / dest / name)
