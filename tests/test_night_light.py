"""Tests for the Waybar night-light controller without changing display gamma."""

import importlib.util
import unittest
from pathlib import Path
from unittest.mock import AsyncMock, patch

SCRIPT = Path(__file__).resolve().parents[1] / "config/waybar/bin/night-light.py"
spec = importlib.util.spec_from_file_location("night_light", SCRIPT)
night_light = importlib.util.module_from_spec(spec)
spec.loader.exec_module(night_light)


class NightLightTests(unittest.IsolatedAsyncioTestCase):
    def setUp(self):
        self.controller = night_light.Controller()
        self.controller.start_display = AsyncMock()

    async def test_toggle(self):
        self.controller.scheduled = 4000
        await self.controller.command("toggle")
        self.assertEqual(self.controller.override, 6500)
        await self.controller.command("toggle")
        self.assertEqual(self.controller.override, 4000)

    async def test_override_resumes_on_next_transition(self):
        self.controller.override = 5000
        self.controller.period = "night"
        with patch.object(
            night_light, "schedule", AsyncMock(return_value=("transition", 4100))
        ):
            await self.controller.update_schedule()
        self.assertIsNone(self.controller.override)
        self.controller.start_display.assert_awaited_once()

    async def test_override_during_transition_remains_until_following_transition(self):
        self.controller.override = 5000
        self.controller.period = "transition"
        with patch.object(
            night_light, "schedule", AsyncMock(return_value=("daytime", 6500))
        ):
            await self.controller.update_schedule()
        self.assertEqual(self.controller.override, 5000)
        self.controller.start_display.assert_not_awaited()

    async def test_failed_location_lookup_keeps_current_location(self):
        original = self.controller.location.copy()
        with patch.object(
            night_light.asyncio,
            "to_thread",
            AsyncMock(side_effect=ValueError("offline")),
        ):
            result = await self.controller.command("location")
        self.assertEqual(self.controller.location, original)
        self.assertIn("offline", result["tooltip"])
        self.assertNotEqual(result["text"], "unavailable")

    def test_schedule_output(self):
        self.assertEqual(
            night_light.parse_schedule(
                "Notice: Period: Night\nNotice: Color temperature: 4000K"
            ),
            ("night", 4000),
        )

    def test_tooltip_shows_region_and_country(self):
        self.controller.location = night_light.validate_location(
            {
                "latitude": 42,
                "longitude": -71,
                "city": "Arlington",
                "region": "Massachusetts",
                "country_code": "US",
            }
        )
        self.assertIn(
            "Arlington, Massachusetts, US", self.controller.status()["tooltip"]
        )

    def test_location_omits_missing_fields_and_duplicate_region(self):
        self.controller.location = night_light.validate_location(
            {
                "latitude": 35,
                "longitude": 139,
                "city": "Tokyo",
                "region": "Tokyo",
                "country_code": None,
            }
        )
        self.assertIn("Tokyo (35.00, 139.00)", self.controller.status()["tooltip"])

    def test_timezone_coordinates_with_seconds(self):
        latitude, longitude = night_light.parse_zone_coordinates("+404251-0740023")
        self.assertAlmostEqual(latitude, 40.7141666667)
        self.assertAlmostEqual(longitude, -74.0063888889)

    def test_timezone_coordinates_without_seconds(self):
        self.assertEqual(
            night_light.parse_zone_coordinates("-3352+15113"),
            (-33.86666666666667, 151.21666666666667),
        )

    def test_missing_saved_location_uses_timezone(self):
        fallback = {"latitude": 10, "longitude": 20, "city": "Example/Zone"}
        with patch.object(night_light, "timezone_location", return_value=fallback):
            self.assertEqual(
                night_light.load_location(Path("/nonexistent/location")), fallback
            )


if __name__ == "__main__":
    unittest.main()
