# OpenTyrian2000

# Project where we build based off of release tags from KScl/opentyrian2000
# (v2000.* tags). Formerly built from a MacSourcePorts copy of the code;
# the build script applies MSPBuildSystem/opentyrian2000/msp-bundle-data.patch
# so it finds the game data inside the app bundle.

import os
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

OpenTyrian2000_guard = VersionGuard(
    project_name="OpenTyrian2000",
    tag_property="OpenTyrian2000_latest_tag",
    force_scheduler_names={"OpenTyrian2000-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="opentyrian2000",
)

OpenTyrian2000_publish_schedulers = {"OpenTyrian2000-changes", "OpenTyrian2000-publish"}

project_list = [
    util.Project(name="OpenTyrian2000",description="OpenTyrian2000 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/KScl/opentyrian2000',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenTyrian2000"),
        project="OpenTyrian2000",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenTyrian2000_factory = util.BuildFactory()

OpenTyrian2000_factory.addStep(steps.Git(
    repourl='https://github.com/KScl/opentyrian2000',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/opentyrian2000"),
    name="Git Pull Latest OpenTyrian2000 Code",
    haltOnFailure=True
))

# Highest v2000.* tag by version
OpenTyrian2000_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git tag --list 'v2000.*' --sort=-v:refname | head -1"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/opentyrian2000"),
    property="OpenTyrian2000_latest_tag",
    name="Fetch Latest OpenTyrian2000 Tag",
    haltOnFailure=True
))

OpenTyrian2000_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenTyrian2000_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/opentyrian2000"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=OpenTyrian2000_guard.should_build
))

# The build script names the version after the tag (v-less) and fetches the
# freeware game data into the app bundle.
OpenTyrian2000_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/opentyrian2000/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/opentyrian2000"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenTyrian2000_guard.should_build,
    extract_fn=make_release_extractor("OpenTyrian2000_dmg_path", "OpenTyrian2000_version"),
))

OpenTyrian2000_factory.addStep(RequireProperty(
    "OpenTyrian2000_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=OpenTyrian2000_guard.should_build,
    haltOnFailure=True,
))

OpenTyrian2000_factory.addStep(RequireProperty(
    "OpenTyrian2000_version",
    name="Verify Build Reported a Version",
    doStepIf=OpenTyrian2000_guard.should_build,
    haltOnFailure=True,
))

OpenTyrian2000_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "opentyrian2000",
        "--tag", util.Interpolate("opentyrian2000_%(prop:OpenTyrian2000_version)s"),
        "--version", util.Property('OpenTyrian2000_version'),
        "--dmg", util.Property('OpenTyrian2000_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/opentyrian2000"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenTyrian2000_publish_schedulers),
        OpenTyrian2000_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

OpenTyrian2000_factory.addStep(RecordBuiltTag(OpenTyrian2000_guard, doStepIf=OpenTyrian2000_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="OpenTyrian2000-builder", workernames=["worker1"], factory=OpenTyrian2000_factory, project="OpenTyrian2000")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="OpenTyrian2000-changes",
        change_filter=util.ChangeFilter(project='OpenTyrian2000'),
        treeStableTimer=60,
        builderNames=["OpenTyrian2000-builder"]),
    schedulers.ForceScheduler(
        name="OpenTyrian2000-force",
        builderNames=["OpenTyrian2000-builder"]),
    schedulers.ForceScheduler(
        name="OpenTyrian2000-publish",
        builderNames=["OpenTyrian2000-builder"])
]
