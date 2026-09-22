# buildbot/buildmaster/projects/version_guard.py
#
# Shared helper for tag-based projects: decides whether a newly-resolved
# tag is actually worth building, given that:
#   (a) the same tag can get "re-detected" by GitPoller with nothing new
#       upstream (see bstone), and
#   (b) some projects' "find the latest tag" shell one-liner picks the
#       tag nearest the most-recently-*dated* commit, which is not
#       necessarily the highest *version* (see yquake2: QUAKE2_4_00
#       sometimes gets picked over QUAKE2_8_70).
#
# The fix for both is the same: track the highest version we've actually
# built, compare newly-resolved tags against it numerically, and only
# build forward.

import json
import os
import re

from buildbot.plugins import steps, util


def extract_version_tuple(tag):
    """Pull every run of digits out of a tag string, in order, as a tuple
    of ints. Ignores whatever letters/prefixes/separators the project's
    tagging convention uses -- this is deliberately dumb so it works
    across wildly different schemes without per-project regexes:

        'v1.3.4'          -> (1, 3, 4)
        '1.3.4'           -> (1, 3, 4)
        'QUAKE2_8_70'     -> (8, 70)
        'QUAKE2_4_00'     -> (4, 0)
        'QUAKE2_8_00_RC1' -> (8, 0, 1)   -- see caveat below
        '1.1.16-2'        -> (1, 1, 16, 2)
        'QUAKE2_WIN32_TEST1' -> (32, 1)  -- see caveat below

    IMPORTANT: this is naive digit-extraction, so a project-name prefix
    that itself contains a number ("QUAKE2_...") contributes a spurious
    leading component to every tag's tuple. That's harmless as long as
    it's *constant* across every tag in the project (it cancels out in
    every comparison), which is the normal case.

    What is NOT harmless: non-release tags whose *suffix* contains
    digits that aren't part of the version -- 'QUAKE2_WIN32_TEST1'
    parses to (2, 32, 1), which numerically outranks the real
    'QUAKE2_8_70' release. Same problem with 'v1.2.0-beta.1' parsing
    higher than the 'v1.2.0' release that supersedes it. Always pass a
    `tag_filter` (see VersionGuard) that matches only the project's
    real release-tag shape -- don't rely on this parser alone to sort
    out junk/pre-release tags from real ones.
    """
    digits = re.findall(r'\d+', tag)
    return tuple(int(n) for n in digits)


class VersionGuard:
    """One instance per project (or per component within a project).

    should_build(step)  -> use as a step's doStepIf
    record_built(step)  -> call from a trailing BuildStep after a
                            successful build
    """

    def __init__(
        self,
        project_name,
        tag_property,
        component=None,          # e.g. "xatrix" for yquake2's mission packs
        extractor=extract_version_tuple,
        tag_filter=None,         # optional: callable(tag) -> bool, True = eligible
        force_scheduler_names=(),  # schedulers that bypass the guard entirely
        base_dir="~/Documents/GitHub/MacSourcePorts/MSPBuildSystem",
    ):
        marker_name = f".last_built_tag_{component}.json" if component else ".last_built_tag.json"
        self.marker_path = os.path.expanduser(f"{base_dir}/{project_name}/{marker_name}")
        self.tag_property = tag_property
        self.extractor = extractor
        self.tag_filter = tag_filter
        self.force_scheduler_names = set(force_scheduler_names)

    def _load(self):
        if not os.path.exists(self.marker_path):
            return None
        try:
            with open(self.marker_path) as f:
                data = json.load(f)
            return data.get("tag"), tuple(data.get("version", []))
        except (json.JSONDecodeError, OSError, TypeError):
            return None

    def should_build(self, step):
        # Let a manually-forced build always through, regardless of version.
        if step.getProperty('scheduler') in self.force_scheduler_names:
            return True

        tag = step.getProperty(self.tag_property)
        if not tag:
            return False

        if self.tag_filter is not None and not self.tag_filter(tag):
            return False

        last = self._load()
        if last is None:
            return True  # nothing recorded yet -- build it, establish a baseline

        last_tag, last_version = last
        if tag == last_tag:
            return False  # identical tag -- definitely already built this

        new_version = self.extractor(tag)
        if not new_version or not last_version:
            # Couldn't parse a numeric version out of one side. Don't
            # silently skip real work just because parsing failed --
            # fall back to "different string than last time" instead.
            return tag != last_tag

        return new_version > last_version

    def record_built(self, step):
        tag = step.getProperty(self.tag_property)
        version = self.extractor(tag)
        os.makedirs(os.path.dirname(self.marker_path), exist_ok=True)
        with open(self.marker_path, "w") as f:
            json.dump({"tag": tag, "version": list(version)}, f)
        return util.SUCCESS


class RecordBuiltTag(steps.BuildStep):
    """Generic version of the bstone RecordBuiltTag step -- pass it the
    VersionGuard it should record into."""
    name = "Record built tag"

    def __init__(self, guard, **kwargs):
        self.guard = guard
        super().__init__(**kwargs)

    def run(self):
        return self.guard.record_built(self)