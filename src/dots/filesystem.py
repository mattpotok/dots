"""Safe replacement helpers for user-local installation files."""

from __future__ import annotations

import shutil
from pathlib import Path
from uuid import uuid4


def replace(source: Path, destination: Path) -> None:
    """Stage and replace a file or directory without retaining a backup."""
    destination.parent.mkdir(parents=True, exist_ok=True)
    staging = destination.with_name(f".{destination.name}.dots-py-{uuid4().hex}")
    previous = destination.with_name(f".{destination.name}.previous-{uuid4().hex}")

    if source.is_dir():
        shutil.copytree(source, staging)
    else:
        shutil.copy2(source, staging)

    if destination.exists() or destination.is_symlink():
        destination.replace(previous)
    try:
        staging.replace(destination)
    except OSError:
        if previous.exists() or previous.is_symlink():
            previous.replace(destination)
        raise

    if previous.exists() or previous.is_symlink():
        _remove(previous)


def _remove(path: Path) -> None:
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    else:
        path.unlink()
