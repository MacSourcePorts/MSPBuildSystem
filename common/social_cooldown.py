"""
social_cooldown.py — shared "post to social media at most once per N days"
logic for publish_release.py (our own builds) and check_thirdparty.py
(third-party builds).

The site keys each social.xml post on a port's "lastAnnounced" (falling back
to "lastUpdated" when it's unset), so a new post only appears when
lastAnnounced changes. For ports listed in social_cooldown.json:

  - An update after the cooldown has passed moves lastAnnounced to the new
    lastUpdated: posted right away.
  - An update inside the cooldown leaves lastAnnounced where it was: the site
    and download update, but no new post ("held").
  - The daily ThirdParty job (check_thirdparty.py) releases held posts once
    the cooldown is over, for every port in the list -- third-party or ours.

social_cooldown.json is a flat map of sourcePortStub -> days:

    { "quetoo": 7, "xash3d-fwgs": 7 }
"""

import datetime
import json
import sys
from pathlib import Path

DEFAULT_PATH = Path(__file__).parent / "social_cooldown.json"

# The daily run's start time drifts by a few seconds, so allow an hour of
# slack -- otherwise a 7-day cooldown would often slip to 8 days.
GRACE = datetime.timedelta(hours=1)


def load_cooldowns(path: Path = DEFAULT_PATH) -> dict:
    if not path.exists():
        return {}
    with path.open() as f:
        cooldowns = json.load(f)
    for stub, days in cooldowns.items():
        if not isinstance(days, int) or days < 1:
            sys.exit(f"{path}: '{stub}' must map to a whole number of days (got {days!r})")
    return cooldowns


def parse_iso(value):
    if not value:
        return None
    return datetime.datetime.fromisoformat(value.replace("Z", "+00:00"))


def iso_utc(dt: datetime.datetime) -> str:
    return dt.isoformat(timespec="milliseconds").replace("+00:00", "Z")


def cooled_down(last_posted: datetime.datetime, days: int, now: datetime.datetime) -> bool:
    return now - last_posted >= datetime.timedelta(days=days) - GRACE


def apply_on_update(port: dict, previous_updated, days: int, now: datetime.datetime) -> dict:
    """Call after port["lastUpdated"] has been set for a new build.
    previous_updated is lastUpdated from before this update -- the feed falls
    back to it when lastAnnounced is unset, so that's when it last posted.
    Sets port["lastAnnounced"] and returns a report entry."""
    stub = port["sourcePortStub"]
    last_posted_str = port.get("lastAnnounced") or previous_updated
    last_posted = parse_iso(last_posted_str)
    if last_posted is None or cooled_down(last_posted, days, now):
        port["lastAnnounced"] = port["lastUpdated"]
        return {"stub": stub, "action": "announced"}
    port["lastAnnounced"] = last_posted_str
    until = (last_posted + datetime.timedelta(days=days)).date().isoformat()
    return {"stub": stub, "action": "held", "until": until}


def ports_to_release(ports: list, cooldowns: dict, now: datetime.datetime, exclude=()):
    """Ports whose latest update was held back earlier and whose cooldown
    has now passed. Returns (ports, problems)."""
    released, problems = [], []
    for stub, days in cooldowns.items():
        port = next((p for p in ports if p.get("sourcePortStub") == stub), None)
        if port is None:
            problems.append(f"social_cooldown.json lists '{stub}', which isn't in sourceports.json")
            continue
        if port in exclude:
            continue
        announced = parse_iso(port.get("lastAnnounced"))
        updated = parse_iso(port.get("lastUpdated"))
        if announced and updated and updated > announced and cooled_down(announced, days, now):
            released.append(port)
    return released, problems
