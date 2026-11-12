# daikatana

# Project where we build based off of release tags from the project.
#
# Upstream tags a release about once a year (around Christmas), named by date
# rather than version -- 12-21-2025-Release, then 12-21-2025_Release-2 and so
# on for re-spins. The version is always 1.3 (it's in the project's name), so
# each tag becomes 1.3-<tag date>[-<re-spin>]:
#
#   12-21-2025-Release   -> 1.3-20251221
#   12-21-2025_Release-4 -> 1.3-20251221-4
#
# The date part goes to the build script as MSP_VERSION_DATE (see
# common/constants.sh), which names the DMG and fills the Info.plist versions.
# The version guard compares tags and published versions by (year, month,
# day, re-spin), since the default digits-in-order comparison would read
# 12-21-2025 as 12.21.2025.

import os
import re
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import (
    VersionGuard,
    RecordBuiltTag,
    scheduler_in,
    and_steps,
    is_publish_machine,
    RequireProperty,
)
from projects.latest_code import make_release_extractor

_daikatana_tag_re = re.compile(r'^(\d{2})-(\d{2})-(\d{4})[-_]Release(?:-(\d+))?$')
_daikatana_version_re = re.compile(r'^1\.3-(\d{4})(\d{2})(\d{2})(?:-(\d+))?$')


def daikatana_version_key(value):
    """(year, month, day, re-spin) for a release tag or a published
    version; () for anything else (old tag styles, the plain "1.3")."""
    m = _daikatana_tag_re.match(value or "")
    if m:
        month, day, year, respin = m.groups()
    else:
        m = _daikatana_version_re.match(value or "")
        if not m:
            return ()
        year, month, day, respin = m.groups()
    return (int(year), int(month), int(day), int(respin or 1))


def daikatana_latest_tag(rc, stdout, stderr):
    """extract_fn for `git tag --list`: the newest release tag by date and
    re-spin, plus its MSP_VERSION_DATE suffix (20251221 or 20251221-4)."""
    tags = [t.strip() for t in stdout.splitlines() if _daikatana_tag_re.match(t.strip())]
    if not tags:
        return {"daikatana_latest_tag": None, "daikatana_version_date": None}
    tag = max(tags, key=daikatana_version_key)
    year, month, day, respin = daikatana_version_key(tag)
    version_date = f"{year:04d}{month:02d}{day:02d}" + (f"-{respin}" if respin > 1 else "")
    return {"daikatana_latest_tag": tag, "daikatana_version_date": version_date}


daikatana_guard = VersionGuard(
    project_name="daikatana-1.3",
    tag_property="daikatana_latest_tag",
    extractor=daikatana_version_key,
    tag_filter=lambda tag: bool(_daikatana_tag_re.match(tag)),
    force_scheduler_names={"daikatana-force", "daikatana-forcepublish"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="daikatana",
)

daikatana_publish_schedulers = {"daikatana-changes", "daikatana-publish", "daikatana-forcepublish"}

project_list = [
    util.Project(name="daikatana",description="daikatana source port project")
]

secretsPath = os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/buildmaster/secrets")

def load_secret(name):
    with open(f"{secretsPath}/{name}") as f:
        return f.read().strip()

github_token = load_secret("githubToken")
repo_url = load_secret("daikatanaUrl")
repoUrl = f"https://{github_token}@{repo_url}"

change_source_list = [
    changes.GitPoller(
        repourl=repoUrl,
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/daikatana-1.3"),
        project="daikatana",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

daikatana_factory = util.BuildFactory()

daikatana_factory.addStep(steps.Git(
    repourl=repoUrl,
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/daikatana-1.3"),
    name="Git Pull Latest daikatana Code",
    haltOnFailure=True
))

daikatana_factory.addStep(steps.SetPropertyFromCommand(
    command=["git", "tag", "--list"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/daikatana-1.3"),
    extract_fn=daikatana_latest_tag,
    name="Fetch Latest daikatana Release Tag",
    haltOnFailure=True
))

daikatana_factory.addStep(RequireProperty(
    "daikatana_latest_tag",
    name="Verify a Release Tag Was Found",
    haltOnFailure=True,
))

daikatana_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('daikatana_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/daikatana-1.3"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=daikatana_guard.should_build
))

daikatana_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/daikatana-1.3/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/daikatana-1.3"),
    env={"MSP_VERSION_DATE": util.Property("daikatana_version_date")},
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=daikatana_guard.should_build,
    extract_fn=make_release_extractor("daikatana_dmg_path", "daikatana_version"),
))

daikatana_factory.addStep(RequireProperty(
    "daikatana_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=daikatana_guard.should_build,
    haltOnFailure=True,
))

daikatana_factory.addStep(RequireProperty(
    "daikatana_version",
    name="Verify Build Reported a Version",
    doStepIf=daikatana_guard.should_build,
    haltOnFailure=True,
))

daikatana_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "daikatana-1.3",
        "--tag", util.Interpolate("daikatana_%(prop:daikatana_version)s"),
        "--version", util.Property('daikatana_version'),
        "--dmg", util.Property('daikatana_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/daikatana-1.3"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, daikatana_publish_schedulers),
        daikatana_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

daikatana_factory.addStep(RecordBuiltTag(daikatana_guard, doStepIf=daikatana_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="daikatana-builder", workernames=["worker1"], factory=daikatana_factory, project="daikatana")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="daikatana-changes",
        change_filter=util.ChangeFilter(project='daikatana'),
        treeStableTimer=60,
        builderNames=["daikatana-builder"]),
    schedulers.ForceScheduler(
        name="daikatana-force",
        builderNames=["daikatana-builder"]),
    schedulers.ForceScheduler(
        name="daikatana-publish",
        builderNames=["daikatana-builder"]),
    # Rebuild and republish even when the site already has this tag
    # (e.g. a packaging fix with no new upstream release)
    schedulers.ForceScheduler(
        name="daikatana-forcepublish",
        builderNames=["daikatana-builder"])
]
