# Temporary tray-menu scrolling workaround

Debian's `libgtk-layer-shell0` 0.10.1-1 ignores the compositor's reduced size
for oversized popup menus. Network lists can extend beyond the display without
scrolling. This reproduces with a standalone GTK layer-shell menu, independently
of Waybar and its CSS; ordinary GTK menus scroll correctly.

Upstream fixes:

- https://github.com/wmww/gtk-layer-shell/pull/224 (popup size constraints)
- https://github.com/wmww/gtk-layer-shell/pull/225 (reopened-menu positioning)

Both fixes were tested successfully using upstream commit
`eb7876471dea74697c0212198d1a8e6d83aa5583`. Its internal version remains 0.10.1,
so the version string alone does not identify whether the fixes are present.

## Local deployment

`bin/general/sway-status-bar` loads the tested library from
`~/.local/opt/gtk-layer-shell-eb7876471dea/lib` when launching Waybar.
It falls back to the system library if the local copy is absent. Nothing is
installed under `/usr` or added to the global linker configuration. Do not export
this library path in the shell profile. Processes launched by Waybar can inherit
its library search path, so keep this directory limited to this library.

Build prerequisites on Debian:

```sh
sudo apt install meson ninja-build build-essential pkg-config libgtk-3-dev libwayland-dev wayland-protocols
```

To reproduce the build in a fresh checkout:

```sh
git clone https://github.com/wmww/gtk-layer-shell.git
cd gtk-layer-shell
git checkout --detach eb7876471dea74697c0212198d1a8e6d83aa5583
meson setup build -Dintrospection=false -Dvapi=false -Dexamples=false -Ddocs=false -Dtests=false
meson compile -C build
mkdir -p "$HOME/.local/opt/gtk-layer-shell-eb7876471dea/lib"
cp build/src/libgtk-layer-shell.so.0.10.1 "$HOME/.local/opt/gtk-layer-shell-eb7876471dea/lib/libgtk-layer-shell.so.0"
```

This is a manual workaround, not yet part of the dots installer. Rebuild and
retest if a GTK update makes the local library incompatible.

## Retirement

Once Debian packages both fixes, remove the `layer_shell_directory` conditional
from the launcher and reload Sway to restart Waybar using the system library.
Verify scrolling in an overflowing tray submenu before removing the local
library directory. Package versions need to be checked against their changelog,
since Debian could backport the fixes without changing the upstream version.
