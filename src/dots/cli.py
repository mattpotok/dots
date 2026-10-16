"""Argument parsing and command dispatch for dots-py."""

from __future__ import annotations

import argparse
import subprocess
import sys

from dots.commands.base import Command, Context
from dots.commands.install_i3status_rust import InstallI3statusRustCommand

INSTALL_TARGETS: tuple[Command, ...] = (InstallI3statusRustCommand(),)
INSTALL_TARGETS_BY_NAME = {target.name: target for target in INSTALL_TARGETS}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="dots-py",
        description="Experimental Python setup tool for this dotfiles repository.",
    )
    subparsers = parser.add_subparsers(dest="command_group", required=True)
    install_parser = subparsers.add_parser(
        "install", help="Install software and configuration."
    )
    install_parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show commands and file changes without making them.",
    )
    install_parser.add_argument(
        "--yes", action="store_true", help="Do not ask for confirmation."
    )
    install_parser.add_argument(
        "targets",
        choices=sorted(INSTALL_TARGETS_BY_NAME),
        metavar="TARGET",
        nargs="+",
        help="Software target to install.",
    )
    install_parser.set_defaults(handler=run_install)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    context = Context(dry_run=args.dry_run, assume_yes=args.yes)
    try:
        return args.handler(args, context)
    except (RuntimeError, subprocess.CalledProcessError, OSError) as error:
        print(f"dots-py: {error}", file=sys.stderr)
        return 1


def run_install(args: argparse.Namespace, context: Context) -> int:
    if len(args.targets) != len(set(args.targets)):
        raise RuntimeError("Each install target can be specified only once.")

    targets = [INSTALL_TARGETS_BY_NAME[name] for name in args.targets]
    context.confirm(f"Install target(s): {', '.join(args.targets)}?")
    for target in targets:
        exit_code = target.run(context)
        if exit_code != 0:
            return exit_code
    return 0
