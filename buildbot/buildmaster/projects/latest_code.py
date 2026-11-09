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

import re
from buildbot.plugins import steps, util, schedulers

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
