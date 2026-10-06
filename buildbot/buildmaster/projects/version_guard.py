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
# The fix for both is the same: track the highest version that's actually
# shipped, compare newly-resolved tags against it numerically, and only
# build forward.
#
# "What's actually shipped" can come from two places:
#
#   - A local marker file (.last_built_tag.json) written by this same
#     guard after a successful build. Works fine for a single build
#     machine, but breaks down the moment you have more than one (a test
#     VM and the real build server) -- each keeps its own independent
#     local state, so a build promoted from the VM to the real server
#     looks "new" to the server even though it was already proven out.
#
#   - The site's own meta.json (https://www.macsourceports.com/meta.json),
#     which lists what's actually published, as an array of objects with
#     (at least) `sourcePortStub` and `buildVersion` fields. Pass
#     meta_url= to use this instead -- then every machine checks the same
#     ground truth regardless of what's sitting on its own disk.
#
#     Caveat: meta.json is updated by a separate process, sometime after
#     a build actually publishes -- not atomically with it. So there's a
#     real (if narrow) window right after a build where meta.json still
#     shows the old version. This guard does not try to paper over that
#     with local state (that's exactly the inconsistency you're trying to
#     get away from) -- it just means two builds racing inside that
#     window aren't caught. For how this project builds (hourly polling,
#     one maintainer), that's an acceptable trade against the alternative
#     of every machine having its own, permanently-diverging memory.
#
#     Also: if meta_url is set and the fetch fails or returns something
#     that doesn't parse, should_build() raises instead of guessing.
#     Buildbot maps an exception raised inside doStepIf to a step result
#     of EXCEPTION, which unconditionally halts the rest of the build
#     (see computeResultAndTermination in buildbot/process/results.py) --
#     so a meta.json outage shows up as a loud, stopped build rather than
#     silently building (or silently not building) on bad information.

import json
import os
import re
import ssl
import time
import urllib.error
import urllib.request

from buildbot.plugins import steps, util

# Python installed from python.org (as opposed to Apple's or Homebrew's)
# doesn't hook into the macOS system certificate store -- it ships its
# own CA handling via the `certifi` package, and HTTPS requests fail
# with CERTIFICATE_VERIFY_FAILED until something points at that bundle
# explicitly. Rather than depend on `Install Certificates.command` having
# been run (and staying in sync with whatever environment the buildbot
# LaunchAgent actually runs under, which can differ from an interactive
# shell), build the SSL context from certifi directly here.
try:
    import certifi
    _SSL_CONTEXT = ssl.create_default_context(cafile=certifi.where())
except ImportError:
    # Fall back to urllib's default behavior. On a host missing certifi
    # where the system store also isn't configured, this will still hit
    # the same CERTIFICATE_VERIFY_FAILED error -- `pip3 install certifi`
    # is the fix.
    _SSL_CONTEXT = None


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


# Shared across every VersionGuard instance that points at the same URL,
# so N projects' should_build() calls within a short window reuse one
# fetch of the (single, shared, possibly largeish) meta.json instead of
# each refetching it. Keyed by URL; value is (fetched_at_monotonic, data).
_meta_cache = {}
_META_CACHE_TTL_SECONDS = 60


def _fetch_meta(url, timeout=10):
    now = time.monotonic()
    cached = _meta_cache.get(url)
    if cached is not None and (now - cached[0]) < _META_CACHE_TTL_SECONDS:
        return cached[1]

    try:
        with urllib.request.urlopen(url, timeout=timeout, context=_SSL_CONTEXT) as resp:
            data = json.loads(resp.read().decode('utf-8'))
    except (urllib.error.URLError, TimeoutError, ValueError, OSError) as e:
        raise RuntimeError(f"VersionGuard: failed to fetch/parse {url}: {e}") from e

    _meta_cache[url] = (now, data)
    return data


class VersionGuard:
    """One instance per project (or per component within a project).

    should_build(step)  -> use as a step's doStepIf
    record_built(step)  -> call from a trailing BuildStep after a
                            successful build (no-op in meta_url mode --
                            see module docstring)
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
        meta_url="https://www.macsourceports.com/meta.json",            # e.g. "https://www.macsourceports.com/meta.json"
        meta_stub=None,           # sourcePortStub to match; defaults to project_name
    ):
        marker_name = f".last_built_tag_{component}.json" if component else ".last_built_tag.json"
        self.marker_path = os.path.expanduser(f"{base_dir}/{project_name}/{marker_name}")
        self.tag_property = tag_property
        self.extractor = extractor
        self.tag_filter = tag_filter
        self.force_scheduler_names = set(force_scheduler_names)
        self.meta_url = meta_url
        self.meta_stub = meta_stub or project_name

    def _load_local(self):
        if not os.path.exists(self.marker_path):
            return None
        try:
            with open(self.marker_path) as f:
                data = json.load(f)
            return data.get("tag"), tuple(data.get("version", []))
        except (json.JSONDecodeError, OSError, TypeError):
            return None

    def _load_from_meta(self):
        data = _fetch_meta(self.meta_url)

        if not isinstance(data, list):
            raise RuntimeError(
                f"VersionGuard: expected {self.meta_url} to contain a JSON array, "
                f"got {type(data).__name__}"
            )

        target_stub = self.meta_stub.casefold()
        best_tag, best_version = None, None
        for entry in data:
            if not isinstance(entry, dict):
                continue
            stub = entry.get('sourcePortStub')
            if not isinstance(stub, str) or stub.casefold() != target_stub:
                continue
            tag = entry.get('buildVersion')
            if not tag:
                continue
            version = self.extractor(tag)
            if best_version is None or version > best_version:
                best_tag, best_version = tag, version

        if best_tag is None:
            return None  # nothing published for this project yet

        return best_tag, best_version

    def _load(self):
        if self.meta_url:
            return self._load_from_meta()
        return self._load_local()

    def should_build(self, step):
        # Let a manually-forced build always through, regardless of version.
        if step.getProperty('scheduler') in self.force_scheduler_names:
            step.setProperty('build_skipped', False, 'VersionGuard')
            return True

        tag = step.getProperty(self.tag_property)
        step.setProperty('resolved_tag', tag, 'VersionGuard')

        if not tag:
            step.setProperty('build_skipped', True, 'VersionGuard')
            return False

        if self.tag_filter is not None and not self.tag_filter(tag):
            step.setProperty('build_skipped', True, 'VersionGuard')
            return False

        last = self._load()
        if last is None:
            step.setProperty('build_skipped', False, 'VersionGuard')
            return True  # nothing published yet -- build it, establish a baseline

        last_tag, last_version = last
        if tag == last_tag:
            step.setProperty('build_skipped', True, 'VersionGuard')
            return False  # identical tag -- definitely already published

        new_version = self.extractor(tag)
        if not new_version or not last_version:
            # Couldn't parse a numeric version out of one side. Don't
            # silently skip real work just because parsing failed --
            # fall back to "different string than last time" instead.
            step.setProperty('build_skipped', False, 'VersionGuard')
            return True

        result = new_version > last_version
        step.setProperty('build_skipped', not result, 'VersionGuard')
        return result

    def record_built(self, step):
        if self.meta_url:
            # Nothing to record locally -- the site's own publish process
            # is the source of truth in this mode. Harmless no-op; you
            # can remove the RecordBuiltTag step from the factory
            # entirely for projects using meta_url.
            return util.SUCCESS

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