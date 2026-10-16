"""Common command interface and execution context."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True)
class Context:
    """Shared command settings supplied by the command-line interface."""

    dry_run: bool
    assume_yes: bool

    def confirm(self, prompt: str) -> None:
        """Request confirmation unless the command is non-interactive."""
        if self.dry_run or self.assume_yes:
            return
        answer = input(f"{prompt} [y/N] ").strip().lower()
        if answer not in {"y", "yes"}:
            raise RuntimeError("Aborted by user.")


class Command(Protocol):
    """A subcommand that can configure its parser and execute itself."""

    name: str
    help: str

    def run(self, context: Context) -> int:
        """Execute the command and return its process exit code."""
        ...
