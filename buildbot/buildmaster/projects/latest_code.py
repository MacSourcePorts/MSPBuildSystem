# Helpers for "latest code" projects: ones built from the tip of upstream's
# branch because upstream has no releases, or stopped making them (e.g.
# Xash3D-FWGS still calls itself 0.20).
#
# The pattern (see xash3dfwgs.py / OpenEnroth.py):
#   - GitPollers record upstream commits as usual, but instead of building
#     on every commit, daily_scheduler() builds at most once a day, and only
#     if something changed since the last run.
#   - version_date_step() records today's date once per build, and the build
#     step passes it as MSP_VERSION_DATE so common/constants.sh turns the
#     script's APP_VERSION into e.g. 0.20-20261030 -- which then names the
#     DMG and fills the Info.plist version keys.
#   - make_release_extractor() reads the DMG path and that dated version back
#     out of the build's output for the publish step.
#   - CommitGuard skips the nightly build when the site already has a build
#     made since the last commit -- see below.

import json
import os
import re
from buildbot.plugins import steps, util, schedulers
from projects.version_guard import _fetch_meta

VERSION_DATE_PROPERTY = "msp_version_date"


def daily_scheduler(project, builder_name, branches, hour=3, minute=0):
    """Nightly build at hour:minute, skipped when no upstream changes on
    `branches` came in since the last one."""
    return schedulers.Nightly(
        name=f"{project}-daily",
        builderNames=[builder_name],
        change_filter=util.ChangeFilter(project=project, branch=branches),
        onlyIfChanged=True,
        hour=hour,
        minute=minute,
    )


def version_date_step():
    return steps.SetPropertyFromCommand(
        command=["date", "+%Y%m%d"],
        property=VERSION_DATE_PROPERTY,
        name="Set Version Date",
        haltOnFailure=True,
    )


def version_date_env():
    """env= for the build step, so constants.sh dates APP_VERSION."""
    return {"MSP_VERSION_DATE": util.Property(VERSION_DATE_PROPERTY)}


def make_release_extractor(dmg_property, version_property, dmg_count=1):
    """extract_fn for the build step's SetPropertyFromCommand: reads the
    MSP_RELEASE_DMG= and MSP_RELEASE_VERSION= lines package_dmg.sh prints.
    Missing lines become None; pair with RequireProperty for each.

    A script that packages several apps (OpenJK) prints one DMG line per
    app: pass dmg_count, and dmg_property becomes a list of the paths --
    or None unless there are exactly that many. Pass it to the publish
    step with dmg_args()."""
    dmg_re = re.compile(r'^MSP_RELEASE_DMG=(.*)$', re.MULTILINE)
    version_re = re.compile(r'^MSP_RELEASE_VERSION=(.*)$', re.MULTILINE)

    def _extract(rc, stdout, stderr):
        dmgs = [m.strip() for m in dmg_re.findall(stdout)]
        version = version_re.search(stdout)
        version = version.group(1).strip() if version else None
        if dmg_count == 1:
            dmg = dmgs[0] if dmgs else None
        else:
            dmg = dmgs if len(dmgs) == dmg_count else None
        return {
            dmg_property: dmg,
            version_property: version,
            # shown in the notification email's subject (master.cfg)
            "resolved_tag": version or "?",
        }

    return _extract


def dmg_args(dmg_property):
    """publish_release.py arguments for a dmg_count > 1 extractor's list:
    --dmg a --dmg b ... (Buildbot flattens the nested list)."""
    @util.renderer
    def _args(props):
        return [["--dmg", dmg] for dmg in props.getProperty(dmg_property)]

    return _args


# ---------------------------------------------------------------------------
# CommitGuard: VersionGuard's counterpart for latest-code projects.
#
# The daily scheduler's onlyIfChanged only knows what its GitPoller reported,
# and a poller reports a branch's tip the first time it sees it -- so a new
# or reset poller (a reconfig, a wiped workdir) sets off a build that
# publishes the same code again under a new date. CommitGuard asks the site
# instead: if every port this project publishes already has a build dated
# after the checkout's last commit, there's nothing new to build.
#
# Both dates are days, in the build machine's time zone: the published
# build's comes from its dated version (1.0-20261117), or its buildDate when
# it has none; the commit's is its committer date. A commit on the same day
# as the published build might be in it or not, so that builds -- at worst
# one extra build the next night, never a missed commit.
#
# Like VersionGuard in meta_url mode, it raises (halting the build as an
# EXCEPTION) when meta.json can't be fetched, rather than guessing.

LAST_COMMIT_DATE_PROPERTY = "msp_last_commit_date"

# publish.json buildType -> meta.json sourcePortType
_BUILD_TYPE_NAMES = {
    1: "Universal 2",
    2: "Universal 1",
    3: "Apple Silicon",
    4: "Intel 64-bit",
    5: "Intel 32-bit",
    6: "PowerPC",
}

_DATED_VERSION_RE = re.compile(r'-(\d{8})$')
_BUILD_DATE_RE = re.compile(r'^(\d{4})-(\d{2})-(\d{2})')


def last_commit_date_step(*checkouts):
    """Sets LAST_COMMIT_DATE_PROPERTY to the newest committer date (YYYYMMDD,
    local time) across the given checkout folders. Run it after the Git
    step(s)."""
    dirs = " ".join(f'"{os.path.expanduser(d)}"' for d in checkouts)
    return steps.SetPropertyFromCommand(
        command=(f"for d in {dirs}; do "
                 "git -C \"$d\" log -1 --date=format-local:%Y%m%d --format=%cd; "
                 "done | sort | tail -1"),
        property=LAST_COMMIT_DATE_PROPERTY,
        name="Find Last Commit Date",
        haltOnFailure=True,
    )


class CommitGuard:
    """should_build(step) -> use as the doStepIf of the build, verify and
    publish steps.

    msp_project is the MSPBuildSystem folder whose publish.json says which
    ports (stub + buildType) the project publishes. Builds from the
    schedulers in force_scheduler_names always go through."""

    def __init__(
        self,
        msp_project,
        force_scheduler_names=(),
        base_dir="~/Documents/GitHub/MacSourcePorts/MSPBuildSystem",
        meta_url="https://www.macsourceports.com/meta.json",
    ):
        self.manifest_path = os.path.expanduser(f"{base_dir}/{msp_project}/publish.json")
        self.force_scheduler_names = set(force_scheduler_names)
        self.meta_url = meta_url

    def _targets(self):
        with open(self.manifest_path) as f:
            return {(e["sourcePortStub"].casefold(), _BUILD_TYPE_NAMES.get(e["buildType"]))
                    for e in json.load(f)}

    @staticmethod
    def _published_date(entry):
        m = _DATED_VERSION_RE.search(str(entry.get("buildVersion") or ""))
        if m:
            return m.group(1)
        m = _BUILD_DATE_RE.match(str(entry.get("buildDate") or ""))
        if m:
            return "".join(m.groups())
        return None

    def published_date(self):
        """The oldest published build date (YYYYMMDD) across this project's
        ports, or None if any of them has none -- then there's something
        to build."""
        data = _fetch_meta(self.meta_url)
        if not isinstance(data, list):
            raise RuntimeError(f"CommitGuard: expected {self.meta_url} to contain a JSON array")
        dates = {}
        for entry in data:
            if not isinstance(entry, dict):
                continue
            key = (str(entry.get("sourcePortStub", "")).casefold(), entry.get("sourcePortType"))
            dates[key] = self._published_date(entry)
        found = [dates.get(t) for t in self._targets()]
        if not found or None in found:
            return None
        return min(found)

    def should_build(self, step):
        # Re-checked by every step that uses it; remember the answer.
        decided = step.getProperty("commit_guard_build")
        if decided is not None:
            return decided

        result, reason = self._decide(step)
        step.setProperty("commit_guard_build", result, "CommitGuard")
        step.setProperty("commit_guard_reason", reason, "CommitGuard")
        step.setProperty("build_skipped", not result, "CommitGuard")
        return result

    def _decide(self, step):
        if step.getProperty("scheduler") in self.force_scheduler_names:
            return True, "forced"
        commit = step.getProperty(LAST_COMMIT_DATE_PROPERTY)
        if not commit:
            return True, "no last commit date"
        published = self.published_date()
        if published is None:
            return True, "nothing dated published yet"
        if commit < published:
            return False, f"last commit {commit} is older than the published build {published}"
        return True, f"last commit {commit} is not older than the published build {published}"
