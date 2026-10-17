#!/usr/bin/env python3
"""Report root filesystem space with colors based on user-available capacity."""

import json
import os


def disk_status(stats: os.statvfs_result) -> dict[str, str]:
    total = stats.f_blocks * stats.f_frsize
    available = max(0, stats.f_bavail) * stats.f_frsize
    used = (stats.f_blocks - stats.f_bfree) * stats.f_frsize
    # Classify the same whole-number available percentage shown in the bar.
    percentage = int(available * 100 / total)
    state = (
        "critical" if percentage < 10 else "warning" if percentage <= 20 else "normal"
    )
    gib = 1024**3
    return {
        "text": f"{available / gib:.1f}GiB ({percentage}%)",
        "tooltip": (
            f"{used / gib:.1f}GiB used out of {total / gib:.1f}GiB on / "
            f"({int(used * 100 / total)}%)"
        ),
        "class": state,
    }


if __name__ == "__main__":
    print(json.dumps(disk_status(os.statvfs("/"))))
