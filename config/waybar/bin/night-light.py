#!/usr/bin/env python3
"""Manage Gammastep's automatic schedule and temporary Waybar overrides."""

import argparse
import asyncio
import contextlib
import fcntl
import json
import logging
import os
import re
import signal
import sys
from datetime import datetime
from html import escape
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

DAY_TEMP = 6500
NIGHT_TEMP = 4000
POLL_SECONDS = 30
LOG = logging.getLogger("night-light")


def runtime_path() -> Path:
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if not runtime:
        raise RuntimeError("XDG_RUNTIME_DIR is not set")
    return Path(runtime) / "dots-night-light"


def location_path() -> Path:
    state = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
    return state / "dots" / "night-light-location.json"


def validate_location(value: object) -> dict:
    if not isinstance(value, dict):
        raise ValueError("Invalid location response")
    try:
        latitude = float(value["latitude"])
        longitude = float(value["longitude"])
    except (KeyError, TypeError, ValueError) as error:
        raise ValueError("Location has invalid coordinates") from error
    if not (-90 <= latitude <= 90 and -180 <= longitude <= 180):
        raise ValueError("Location has invalid coordinates")
    city = str(value.get("city") or "Current location")[:100]
    location = {"latitude": latitude, "longitude": longitude, "city": city}
    for field in ("region", "country_code"):
        if isinstance(value.get(field), str) and value[field].strip():
            location[field] = value[field].strip()[:100]
    return location


def parse_zone_coordinates(value: str) -> tuple[float, float]:
    match = re.fullmatch(
        r"([+-])(\d{2})(\d{2})(\d{2})?([+-])(\d{3})(\d{2})(\d{2})?", value
    )
    if not match:
        raise ValueError("Invalid time-zone coordinates")
    lat_sign, lat_deg, lat_min, lat_sec, lon_sign, lon_deg, lon_min, lon_sec = (
        match.groups()
    )

    def decimal(sign: str, degrees: str, minutes: str, seconds: str | None) -> float:
        result = int(degrees) + int(minutes) / 60 + int(seconds or 0) / 3600
        return -result if sign == "-" else result

    return decimal(lat_sign, lat_deg, lat_min, lat_sec), decimal(
        lon_sign, lon_deg, lon_min, lon_sec
    )


def timezone_location() -> dict:
    zone = os.environ.get("TZ", "").removeprefix(":")
    zoneinfo = Path("/usr/share/zoneinfo")
    if not zone:
        try:
            zone = str(Path("/etc/localtime").resolve().relative_to(zoneinfo))
        except ValueError, OSError:
            with contextlib.suppress(OSError):
                zone = Path("/etc/timezone").read_text().strip()
    if zone.startswith(str(zoneinfo) + "/"):
        zone = zone.removeprefix(str(zoneinfo) + "/")
    # Resolve geographic aliases (for example US/Eastern) to the zone table key.
    if zone and not zone.startswith("/") and ".." not in Path(zone).parts:
        with contextlib.suppress(OSError, ValueError):
            zone = str((zoneinfo / zone).resolve().relative_to(zoneinfo))
    for table in (zoneinfo / "zone1970.tab", zoneinfo / "zone.tab"):
        try:
            lines = table.read_text().splitlines()
        except OSError:
            continue
        for line in lines:
            fields = line.split("\t")
            if not line.startswith("#") and len(fields) >= 3 and fields[2] == zone:
                latitude, longitude = parse_zone_coordinates(fields[1])
                return {
                    "latitude": latitude,
                    "longitude": longitude,
                    "city": zone,
                    "source": "Approximate time-zone reference location",
                    "updated_at": "",
                }
    raise ValueError(
        "No location saved and no geographic time-zone location found; "
        "set a geographic time zone or provide a saved location"
    )


def load_location(path: Path) -> dict:
    try:
        saved = json.loads(path.read_text())
        location = validate_location(saved)
        location["updated_at"] = str(saved.get("updated_at", ""))
        location["source"] = "Saved location"
        return location
    except OSError, ValueError, TypeError:
        return timezone_location()


def fetch_location() -> dict:
    request = Request(
        "https://ipapi.co/json/", headers={"User-Agent": "dots-night-light"}
    )
    try:
        with urlopen(request, timeout=15) as response:
            data = json.load(response)
    except HTTPError as error:
        raise ValueError(f"Location service returned HTTP {error.code}") from None
    except (URLError, OSError, ValueError) as error:
        raise ValueError("Location lookup failed") from error
    if not isinstance(data, dict) or data.get("error"):
        raise ValueError("Location service could not determine a location")
    return validate_location(data)


def save_location(path: Path, location: dict) -> None:
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    temporary = path.with_suffix(".tmp")
    try:
        temporary.write_text(json.dumps(location) + "\n")
        temporary.chmod(0o600)
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def should_resume(previous: str, current: str) -> bool:
    """Resume at a new transition, including one missed during suspend."""
    stable = {"daytime", "night"}
    return (previous in stable and current == "transition") or (
        previous in stable and current in stable and previous != current
    )


def parse_schedule(output: str) -> tuple[str, int]:
    period = re.search(r"Period:\s*(Daytime|Night|Transition)\b", output, re.I)
    temperature = re.search(r"Color temperature:\s*(\d+)K", output, re.I)
    if not period or not temperature:
        raise ValueError("Unable to read Gammastep schedule")
    return period.group(1).lower(), int(temperature.group(1))


async def schedule(location: dict) -> tuple[str, int]:
    process = await asyncio.create_subprocess_exec(
        "gammastep",
        "-c",
        "/dev/null",
        "-p",
        "-m",
        "dummy",
        "-l",
        f"{location['latitude']}:{location['longitude']}",
        "-t",
        f"{DAY_TEMP}:{NIGHT_TEMP}",
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.STDOUT,
        env={**os.environ, "LC_ALL": "C"},
    )
    try:
        output, _ = await asyncio.wait_for(process.communicate(), 10)
    except TimeoutError:
        process.kill()
        await process.wait()
        raise RuntimeError("Gammastep schedule check timed out") from None
    if process.returncode:
        raise RuntimeError("Gammastep schedule check failed")
    return parse_schedule(output.decode(errors="replace"))


class Controller:
    def __init__(self) -> None:
        self.location = load_location(location_path())
        self.period = "unknown"
        self.scheduled = DAY_TEMP
        self.override: int | None = None
        self.process: asyncio.subprocess.Process | None = None
        self.error = ""
        self.location_error = ""
        self.lock = asyncio.Lock()

    async def stop_display(self) -> None:
        if self.process and self.process.returncode is None:
            self.process.terminate()
            try:
                await asyncio.wait_for(self.process.wait(), 3)
            except TimeoutError:
                self.process.kill()
                await self.process.wait()
        self.process = None

    async def start_display(self) -> None:
        await self.stop_display()
        args = ["gammastep", "-c", "/dev/null", "-m", "wayland", "-r"]
        if self.override is None:
            args += [
                "-l",
                f"{self.location['latitude']}:{self.location['longitude']}",
                "-t",
                f"{DAY_TEMP}:{NIGHT_TEMP}",
            ]
        else:
            args += ["-O", str(self.override)]
        self.process = await asyncio.create_subprocess_exec(
            *args,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )
        await asyncio.sleep(0.3)
        if self.process.returncode is not None:
            self.error = "Gammastep could not control the display"
            raise RuntimeError(self.error)
        self.error = ""

    def status(self) -> dict:
        if self.process and self.process.returncode is not None:
            self.error = "Gammastep stopped unexpectedly"
        temperature = self.override if self.override is not None else self.scheduled
        mode = "Manual" if self.override is not None else f"Auto · {self.period}"
        parts = [self.location["city"]]
        for field in ("region", "country_code"):
            part = self.location.get(field)
            if part and part.casefold() not in {item.casefold() for item in parts}:
                parts.append(part)
        location_name = ", ".join(parts)
        tooltip = (
            f"{mode}: {temperature} K\n"
            f"{location_name} "
            f"({self.location['latitude']:.2f}, {self.location['longitude']:.2f})\n"
            + (
                "Approximate time-zone location\n"
                if self.location.get("source")
                == "Approximate time-zone reference location"
                else ""
            )
            + ("Auto resumes at next transition\n" if self.override is not None else "")
            + "Left: toggle · Right: refresh location"
        )
        if self.error:
            tooltip += f"\nError: {self.error}"
        if self.location_error:
            tooltip += (
                f"\nLocation update failed: {self.location_error}; "
                "previous location retained"
            )
        return {
            "text": f"{temperature} K" if not self.error else "unavailable",
            "tooltip": escape(tooltip),
            "class": "error" if self.error else "normal",
        }

    async def update_schedule(self) -> None:
        location = self.location.copy()
        period, temperature = await schedule(location)
        async with self.lock:
            if location != self.location:
                return
            previous = self.period
            self.period, self.scheduled = period, temperature
            if self.override is not None and should_resume(previous, period):
                self.override = None
                await self.start_display()

    async def command(self, command: str) -> dict:
        if command == "status":
            return self.status()
        if command == "location":
            try:
                location = await asyncio.to_thread(fetch_location)
                location["updated_at"] = (
                    datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %Z")
                )
                location["source"] = "IP-based lookup"
                period, temperature = await schedule(location)
                async with self.lock:
                    await asyncio.to_thread(save_location, location_path(), location)
                    self.location = location
                    self.period, self.scheduled = period, temperature
                    if self.override is None:
                        await self.start_display()
                    self.location_error = ""
            except (OSError, ValueError, RuntimeError) as error:
                self.location_error = str(error)
                LOG.warning("Location update failed: %s", error)
            return self.status()
        if command != "toggle":
            raise ValueError("Unknown command")
        async with self.lock:
            current = self.override if self.override is not None else self.scheduled
            self.override = DAY_TEMP if current == NIGHT_TEMP else NIGHT_TEMP
            await self.start_display()
        return self.status()


async def serve() -> None:
    directory = runtime_path()
    directory.mkdir(mode=0o700, parents=True, exist_ok=True)
    lock_file = (directory / "controller.lock").open("w")
    try:
        fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        LOG.info("Night-light controller is already running")
        return
    socket_path = directory / "controller.sock"
    socket_path.unlink(missing_ok=True)
    controller = Controller()

    async def handle(
        reader: asyncio.StreamReader, writer: asyncio.StreamWriter
    ) -> None:
        try:
            command = (await asyncio.wait_for(reader.readline(), 5)).decode().strip()
            result = await controller.command(command)
        except (OSError, ValueError, RuntimeError, TimeoutError) as error:
            result = {
                "text": "unavailable",
                "tooltip": escape(str(error)),
                "class": "error",
            }
        try:
            writer.write((json.dumps(result) + "\n").encode())
            await writer.drain()
        finally:
            writer.close()
            await writer.wait_closed()

    async def poll() -> None:
        while True:
            try:
                await controller.update_schedule()
            except (OSError, ValueError, RuntimeError) as error:
                controller.error = str(error)
                LOG.warning("Schedule check failed: %s", error)
            await asyncio.sleep(POLL_SECONDS)

    loop = asyncio.get_running_loop()
    stopped = asyncio.Event()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, stopped.set)
    polling = None
    watcher = None
    watcher_task = None
    try:
        await controller.update_schedule()
        await controller.start_display()
        server = await asyncio.start_unix_server(handle, path=socket_path)
        os.chmod(socket_path, 0o600)
        watcher = await asyncio.create_subprocess_exec(
            "swaymsg",
            "-m",
            "-t",
            "subscribe",
            '["shutdown"]',
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )

        async def watch_session() -> None:
            await watcher.wait()
            stopped.set()

        watcher_task = asyncio.create_task(watch_session())
        polling = asyncio.create_task(poll())
        async with server:
            await stopped.wait()
    finally:
        if polling:
            polling.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await polling
        if watcher and watcher.returncode is None:
            watcher.terminate()
            await watcher.wait()
        if watcher_task:
            await watcher_task
        await controller.stop_display()
        socket_path.unlink(missing_ok=True)
        lock_file.close()


async def send(command: str) -> None:
    try:
        reader, writer = await asyncio.open_unix_connection(
            runtime_path() / "controller.sock"
        )
        writer.write((command + "\n").encode())
        await writer.drain()
        response = await asyncio.wait_for(reader.readline(), 20)
        writer.close()
        await writer.wait_closed()
        print(response.decode().strip())
    except (OSError, RuntimeError, TimeoutError) as error:
        print(
            json.dumps(
                {"text": "unavailable", "tooltip": escape(str(error)), "class": "error"}
            )
        )
        sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["daemon", "status", "toggle", "location"])
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO)
    try:
        asyncio.run(serve() if args.command == "daemon" else send(args.command))
    except (OSError, RuntimeError, ValueError) as error:
        LOG.error("%s", error)
        sys.exit(1)


if __name__ == "__main__":
    main()
