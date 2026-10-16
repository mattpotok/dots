"""Install i3status-rust from a pinned upstream release."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
from datetime import UTC, datetime
from pathlib import Path
from uuid import uuid4

from dots.commands.base import Context
from dots.filesystem import replace
from dots.runner import command_exists, run
from dots.system.apt import ensure_apt_available, missing_packages

I3STATUS_RUST_REPOSITORY = "https://github.com/greshake/i3status-rust.git"
I3STATUS_RUST_VERSION = "0.36.1"
I3STATUS_RUST_TAG = f"v{I3STATUS_RUST_VERSION}"
APT_BUILD_DEPENDENCIES = (
    "build-essential",
    "git",
    "pkg-config",
    "libdbus-1-dev",
    "libpulse-dev",
    "libssl-dev",
    "libsensors-dev",
)
APT_RUNTIME_DEPENDENCIES = (
    "fonts-font-awesome",
    "gammastep",
    "gsimplecal",
    "pavucontrol",
    "x11-xkb-utils",
)
APT_DEPENDENCIES = (*APT_BUILD_DEPENDENCIES, *APT_RUNTIME_DEPENDENCIES)


class InstallI3statusRustCommand:
    """Build and install the repository-pinned i3status-rust release."""

    name = "i3status-rust"
    help = "Build and install the repository-pinned i3status-rust release."

    def run(self, context: Context) -> int:
        if os.geteuid() == 0:
            raise RuntimeError("Run dots-py as your normal user, not via sudo.")

        missing_rust_tools = [
            tool for tool in ("cargo", "rustc") if not command_exists(tool)
        ]
        if missing_rust_tools:
            missing = ", ".join(missing_rust_tools)
            raise RuntimeError(
                f"Missing Rust tool(s): {missing}. "
                "Install Rust with rustup, then rerun this command."
            )

        ensure_apt_available()
        missing_dependencies = missing_packages(APT_DEPENDENCIES)
        if missing_dependencies:
            print("Missing dependencies:", ", ".join(missing_dependencies))
            run(
                ["sudo", "apt-get", "install", "-y", *missing_dependencies],
                dry_run=context.dry_run,
            )
        else:
            print("All Debian/Ubuntu dependencies are already installed.")
        print()

        prefix = Path.home() / ".local"
        binary_destination = prefix / "bin" / "i3status-rs"
        data_destination = prefix / "share" / "i3status-rust"
        source_directory = prefix / "src" / f"i3status-rust-{I3STATUS_RUST_TAG}"

        if source_directory.is_symlink():
            raise RuntimeError(
                f"Refusing to use a symlinked source checkout: {source_directory}"
            )
        if source_directory.exists() and not source_directory.is_dir():
            raise RuntimeError(
                f"Source checkout is not a directory: {source_directory}"
            )

        print(f"Target: i3status-rust {I3STATUS_RUST_TAG}")
        print("Paths:")
        print(f"  <build>:  {source_directory}")
        print(f"  <binary>: {binary_destination}")
        print(f"  <data>:   {data_destination}")
        print()

        if context.dry_run:
            self._show_dry_run(source_directory)
            return 0

        self._clone_if_missing(source_directory)
        run(["cargo", "build", "--release", "--locked"], cwd=source_directory)

        print("Replacing <binary> with <build>/target/release/i3status-rs")
        replace(
            source_directory / "target" / "release" / "i3status-rs",
            binary_destination,
        )
        print("Replacing <data> with <build>/files")
        replace(source_directory / "files", data_destination)

        installed_version = subprocess.run(
            [str(binary_destination), "--version"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        metadata_destination = data_destination / "installation.json"
        metadata_destination.write_text(
            json.dumps(
                {
                    "version": I3STATUS_RUST_TAG,
                    "repository": I3STATUS_RUST_REPOSITORY,
                    "installed_at": datetime.now(UTC).isoformat(),
                },
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )
        print(f"Installed {installed_version}")
        print("Reload i3 with: i3-msg reload")
        return 0

    @staticmethod
    def _clone_if_missing(source_directory: Path) -> None:
        if source_directory.exists():
            print(f"Reusing source checkout {source_directory}")
            return

        source_directory.parent.mkdir(parents=True, exist_ok=True)
        staging_directory = source_directory.with_name(
            f".{source_directory.name}.dots-py-{uuid4().hex}"
        )
        try:
            run(
                [
                    "git",
                    "clone",
                    "--depth",
                    "1",
                    "--branch",
                    I3STATUS_RUST_TAG,
                    I3STATUS_RUST_REPOSITORY,
                    str(staging_directory),
                ]
            )
            staging_directory.replace(source_directory)
        except OSError, subprocess.CalledProcessError:
            if staging_directory.exists():
                shutil.rmtree(staging_directory)
            raise

    @staticmethod
    def _show_dry_run(source_directory: Path) -> None:
        if source_directory.exists():
            print("Would reuse <build>")
        else:
            staging_directory = source_directory.with_name(
                f".{source_directory.name}.dots-py-<temporary>"
            )
            run(
                [
                    "git",
                    "clone",
                    "--depth",
                    "1",
                    "--branch",
                    I3STATUS_RUST_TAG,
                    I3STATUS_RUST_REPOSITORY,
                    str(staging_directory),
                ],
                dry_run=True,
            )
            print(f"Would move {staging_directory} to <build>")

        print()
        run(
            ["cargo", "build", "--release", "--locked"],
            cwd=source_directory,
            dry_run=True,
        )
        print("Would replace <binary> with <build>/target/release/i3status-rs")
        print("Would replace <data> with <build>/files")
