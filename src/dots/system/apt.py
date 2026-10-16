"""Debian and Ubuntu package-manager helpers."""

from __future__ import annotations

import subprocess

from dots.runner import command_exists


def ensure_apt_available() -> None:
    """Ensure that this command is running on an apt-based system."""
    if not command_exists("apt-get") or not command_exists("dpkg-query"):
        raise RuntimeError(
            "install i3status-rust currently supports Debian/Ubuntu systems with apt."
        )


def missing_packages(packages: tuple[str, ...]) -> list[str]:
    """Return packages that are not installed according to dpkg's database."""
    missing = []
    for package in packages:
        result = subprocess.run(
            ["dpkg-query", "-W", "-f=${db:Status-Status}", package],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0 or result.stdout.strip() != "installed":
            missing.append(package)
    return missing
