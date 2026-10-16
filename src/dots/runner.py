"""Subprocess helpers with consistent dry-run output."""

from __future__ import annotations

import shlex
import shutil
import subprocess
from pathlib import Path


def run(command: list[str], *, cwd: Path | None = None, dry_run: bool = False) -> None:
    """Run a command, showing it first and failing on an unsuccessful exit."""
    print("+", shlex.join(command))
    if not dry_run:
        subprocess.run(command, cwd=cwd, check=True)


def command_exists(command: str) -> bool:
    """Return whether a command can be resolved from the current PATH."""
    return shutil.which(command) is not None
