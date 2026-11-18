# RecklessDrivin

# Project where we build based off of release tags from the GitHub releases of DarrCoh/reckless-drivin-sdl.
# The tag is passed to the build script, which uses it as the version.

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

_RecklessDrivin_release_re = re.compile(r'^v\d+(\.\d+)+$')

RecklessDrivin_guard = VersionGuard(
    project_name="RecklessDrivin",
    tag_property="RecklessDrivin_latest_tag",
    tag_filter=lambda tag: bool(_RecklessDrivin_release_re.match(tag)),
    force_scheduler_names={"RecklessDrivin-force", "RecklessDrivin-forcepublish"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="recklessdrivin",
)

RecklessDrivin_publish_schedulers = {"RecklessDrivin-changes", "RecklessDrivin-publish", "RecklessDrivin-forcepublish"}

project_list = [
    util.Project(name="RecklessDrivin", description="RecklessDrivin source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/DarrCoh/reckless-drivin-sdl',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/RecklessDrivin"),
        project="RecklessDrivin",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

RecklessDrivin_factory = util.BuildFactory()

RecklessDrivin_factory.addStep(steps.Git(
    repourl='https://github.com/DarrCoh/reckless-drivin-sdl',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/reckless-drivin-sdl"),
    name="Git Pull Latest RecklessDrivin Code",
    haltOnFailure=True
))

RecklessDrivin_factory.addStep(steps.SetPropertyFromCommand(
    command=["gh", "api", "repos/DarrCoh/reckless-drivin-sdl/releases/latest", "--jq", ".tag_name"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/reckless-drivin-sdl"),
    property="RecklessDrivin_latest_tag",
    name="Fetch Latest RecklessDrivin Release",
    haltOnFailure=True
))

RecklessDrivin_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('RecklessDrivin_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/reckless-drivin-sdl"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=RecklessDrivin_guard.should_build
))

RecklessDrivin_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/reckless-drivin-sdl/macsourceports_universal2.sh"), "notarize", util.Property('RecklessDrivin_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/reckless-drivin-sdl"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=RecklessDrivin_guard.should_build,
    extract_fn=make_release_extractor("RecklessDrivin_dmg_path", "RecklessDrivin_version"),
))

RecklessDrivin_factory.addStep(RequireProperty(
    "RecklessDrivin_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=RecklessDrivin_guard.should_build,
    haltOnFailure=True,
))

RecklessDrivin_factory.addStep(RequireProperty(
    "RecklessDrivin_version",
    name="Verify Build Reported a Version",
    doStepIf=RecklessDrivin_guard.should_build,
    haltOnFailure=True,
))

RecklessDrivin_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "reckless-drivin-sdl",
        "--tag", util.Interpolate("RecklessDrivin_%(prop:RecklessDrivin_version)s"),
        "--version", util.Property('RecklessDrivin_version'),
        "--dmg", util.Property('RecklessDrivin_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/reckless-drivin-sdl"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, RecklessDrivin_publish_schedulers),
        RecklessDrivin_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

RecklessDrivin_factory.addStep(RecordBuiltTag(RecklessDrivin_guard, doStepIf=RecklessDrivin_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="RecklessDrivin-builder", workernames=["worker1"], factory=RecklessDrivin_factory, project="RecklessDrivin")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="RecklessDrivin-changes",
        change_filter=util.ChangeFilter(project='RecklessDrivin'),
        treeStableTimer=60,
        builderNames=["RecklessDrivin-builder"]),
    schedulers.ForceScheduler(
        name="RecklessDrivin-force",
        builderNames=["RecklessDrivin-builder"]),
    schedulers.ForceScheduler(
        name="RecklessDrivin-publish",
        builderNames=["RecklessDrivin-builder"]),
    # Rebuild and republish even when the site already has this tag
    # (e.g. a packaging fix with no new upstream release)
    schedulers.ForceScheduler(
        name="RecklessDrivin-forcepublish",
        builderNames=["RecklessDrivin-builder"])
]
