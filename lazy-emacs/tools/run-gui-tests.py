#!/usr/bin/env python3
"""Run real PGTK daemon/frame tests on a private, disposable Xvfb display.
Invoke through: guix shell -m lazy-emacs/manifest.scm xorg-server -- python3
lazy-emacs/tools/run-gui-tests.py. No existing Emacs/socket/display is used.
"""
from pathlib import Path
import json
import os
import select
import subprocess
import sys
import tempfile
import time
root = Path(__file__).resolve().parents[1]
work = Path(tempfile.mkdtemp(prefix='gui-test-', dir=root / 'cache'))
report = work / 'result.json'
env = os.environ.copy()
env['LC_GUI_REPORT'] = str(report)
bare = '--bare' in sys.argv
for name in ('XDG_CACHE_HOME', 'XDG_CONFIG_HOME', 'XDG_STATE_HOME'):
    directory = work / name.lower()
    directory.mkdir(mode=0o700)
    env[name] = str(directory)
# Never let this isolated test accidentally render a window on the user's display.
env.pop('WAYLAND_DISPLAY', None)
env['GDK_BACKEND'] = 'x11'
rfd, wfd = os.pipe()
xvfb = emacs = None
try:
    with (work / 'xvfb.log').open('w') as xlog, (work / 'emacs.log').open('w') as elog:
        xvfb = subprocess.Popen(['Xvfb', '-displayfd', str(wfd), '-screen', '0', '1280x900x24',
                                 '-nolisten', 'tcp'], pass_fds=(wfd,), stdout=xlog, stderr=xlog)
        os.close(wfd)
        if not select.select([rfd], [], [], 10)[0]:
            raise RuntimeError('Xvfb did not allocate a display')
        display = os.read(rfd, 128).decode().strip()
        os.close(rfd)
        env['DISPLAY'] = ':' + display
        emacs = subprocess.Popen(['emacs', '--no-init-file', '--fg-daemon=lc-gui-test',
                                  '--load', str(root / 'tests' / ('test-gui-bare.el' if bare else 'test-gui.el'))],
                                 env=env, stdout=elog, stderr=elog)
        deadline = time.monotonic() + 60
        while not report.exists() and time.monotonic() < deadline and emacs.poll() is None:
            time.sleep(.1)
        if not report.exists():
            raise RuntimeError('GUI tests failed or timed out; see ' + str(work / 'emacs.log'))
        result = json.loads(report.read_text())
        print(json.dumps(result, indent=2))
        if result.get('status') != 'ready':
            raise RuntimeError('GUI assertions failed; see ' + str(work / 'emacs.log'))
        # Execute inside a REAL server filter, then prove a subsequent client can
        # still be dispatched. The prompt test deletes a frame while reading.
        socket = result.get('socket')
        probes = [] if bare else [('(lc-gui-prompt-regression (quote minibuffer))', 't'),
                                 ('(lc-gui-prompt-regression (quote key))', 't'),
                                 ('(+ 1 1)', '2')]
        for form, expected in probes:
            check = subprocess.run(['emacsclient', '--socket-name', socket, '--eval', form],
                                   env=env, text=True, capture_output=True, timeout=10)
            if check.returncode or check.stdout.strip() != expected:
                raise RuntimeError('Server recovery failed: ' + check.stdout + check.stderr)
        print('Bare PGTK frame control: PASS' if bare else 'PGTK daemon GUI and subsequent server-request recovery: PASS')
        print('Logs: ' + str(work))
finally:
    for process in (emacs, xvfb):
        if process and process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
