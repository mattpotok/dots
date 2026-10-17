"""OpenWeatherMap current weather as Waybar JSON, with cached IP geolocation."""

import argparse
import json
import os
import time
from html import escape
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

LOCATION_INTERVAL = 6 * 60 * 60
ICON_FORMAT = "<span font_family='Font Awesome 6 Free Solid' rise='1024'>{}</span>"


class WeatherError(Exception):
    """A safe error message that never includes the API key or request URL."""


def fetch(url: str, service: str) -> dict[str, Any]:
    request = Request(url, headers={"User-Agent": "dots-waybar-weather"})
    try:
        with urlopen(request, timeout=15) as response:
            data = json.load(response)
    except HTTPError as error:
        raise WeatherError(f"{service}: HTTP {error.code}") from None
    except URLError, OSError:
        raise WeatherError(
            f"{service}: unable to connect or request timed out"
        ) from None
    except ValueError, UnicodeError:
        raise WeatherError(f"{service}: invalid response") from None
    if not isinstance(data, dict):
        raise WeatherError(f"{service}: invalid response")
    return data


def location_cache() -> Path:
    cache_home = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    return cache_home / "waybar" / "weather-location.json"


def valid_coordinates(location: dict[str, Any]) -> bool:
    try:
        return (
            -90 <= float(location["latitude"]) <= 90
            and -180 <= float(location["longitude"]) <= 180
        )
    except KeyError, TypeError, ValueError:
        return False


def get_location(cache: Path) -> dict[str, Any]:
    now = time.time()
    try:
        cached = json.loads(cache.read_text())
        if (
            isinstance(cached, dict)
            and valid_coordinates(cached)
            and 0 <= now - float(cached["cached_at"]) < LOCATION_INTERVAL
        ):
            return cached
    except OSError, ValueError, TypeError, KeyError:
        pass

    data = fetch("https://ipapi.co/json/", "Location service")
    if data.get("error") or not valid_coordinates(data):
        raise WeatherError("Location service: unable to determine location")
    # Store only the coordinates and city, not the provider's full IP profile.
    location = {
        "latitude": float(data["latitude"]),
        "longitude": float(data["longitude"]),
        "city": data.get("city", ""),
        "cached_at": now,
    }
    try:
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(json.dumps(location))
    except OSError:
        pass  # Weather still works when the cache directory isn't writable.
    return location


def weather_icon(code: str) -> str:
    return {
        "01d": "\uf185",
        "01n": "\uf186",
        "02d": "\uf0c2",
        "02n": "\uf6c3",
        "03d": "\uf0c2",
        "03n": "\uf6c3",
        "04d": "\uf0c2",
        "04n": "\uf6c3",
        "09d": "\uf743",
        "09n": "\uf73c",
        "10d": "\uf743",
        "10n": "\uf73c",
        "11d": "\uf0e7",
        "11n": "\uf0e7",
        "13d": "\uf2dc",
        "13n": "\uf2dc",
        "50d": "\uf0c2",
        "50n": "\uf0c2",
    }.get(code, "\uf0c2")


def get_weather(api_key: str, cache: Path) -> dict[str, str]:
    location = get_location(cache)
    query = urlencode(
        {
            "lat": location["latitude"],
            "lon": location["longitude"],
            "appid": api_key,
            "units": "metric",
        }
    )
    data = fetch(
        f"https://api.openweathermap.org/data/2.5/weather?{query}", "Weather service"
    )
    condition = data["weather"][0]
    main = data["main"]
    city = escape(str(data.get("name") or location.get("city") or "Current location"))
    description = escape(str(condition["description"]))
    temperature = float(main["temp"])
    text = (
        f"{ICON_FORMAT.format(weather_icon(condition['icon']))} "
        f"{escape(str(condition['main']))} {temperature:.0f}°C"
    )
    tooltip = (
        f"{city}: {description}\n"
        f"{temperature:.1f}°C; feels like {float(main['feels_like']):.1f}°C\n"
        f"Humidity: {main['humidity']}%; wind: {float(data['wind']['speed']):.1f} m/s\n"
        "Click to refresh weather and location"
    )
    return {"text": text, "tooltip": tooltip, "class": "weather"}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--clear-location-cache", action="store_true")
    args = parser.parse_args()
    cache = location_cache()
    if args.clear_location_cache:
        cache.unlink(missing_ok=True)
        return

    api_key = os.environ.get("OPENWEATHERMAP_API_KEY", "")
    if not api_key:
        print(json.dumps({"text": ""}))
        return
    try:
        output = get_weather(api_key, cache)
    except (
        WeatherError,
        KeyError,
        IndexError,
        TypeError,
        ValueError,
        OSError,
    ) as error:
        message = (
            str(error)
            if isinstance(error, WeatherError)
            else "Invalid weather response"
        )
        output = {
            "text": f"{ICON_FORMAT.format(chr(0xF071))} unavailable",
            "tooltip": f"{escape(message)}\nClick to retry weather and location",
            "class": "error",
        }
    print(json.dumps(output))


if __name__ == "__main__":
    main()
