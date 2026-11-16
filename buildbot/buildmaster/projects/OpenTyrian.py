# OpenTyrian

# Project where we build based off of release tags from opentyrian/opentyrian
# (v2.1.* tags). Formerly built from a MacSourcePorts copy of the code;
# upstream now finds the game data inside the app bundle itself.

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

OpenTyrian_guard = VersionGuard(
    project_name="OpenTyrian",
    tag_property="OpenTyrian_latest_tag",
    force_scheduler_names={"OpenTyrian-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="opentyrian",
)

OpenTyrian_publish_schedulers = {"OpenTyrian-changes", "OpenTyrian-publish"}

project_list = [
    util.Project(name="OpenTyrian",description="OpenTyrian source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/opentyrian/opentyrian',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenTyrian"),
        project="OpenTyrian",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenTyrian_factory = util.BuildFactory()

OpenTyrian_factory.addStep(steps.Git(
    repourl='https://github.com/opentyrian/opentyrian',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/opentyrian"),
    name="Git Pull Latest OpenTyrian Code",
    haltOnFailure=True
))

# Highest v2.1.* tag by version
OpenTyrian_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git tag --list 'v2.1.*' --sort=-v:refname | head -1"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/opentyrian"),
    property="OpenTyrian_latest_tag",
    name="Fetch Latest OpenTyrian Tag",
    haltOnFailure=True
))

OpenTyrian_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenTyrian_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/opentyrian"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=OpenTyrian_guard.should_build
))

# The build script names the version after the tag (v-less) and fetches the
# freeware game data into the app bundle.
OpenTyrian_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/opentyrian/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/opentyrian"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenTyrian_guard.should_build,
    extract_fn=make_release_extractor("OpenTyrian_dmg_path", "OpenTyrian_version"),
))

OpenTyrian_factory.addStep(RequireProperty(
    "OpenTyrian_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=OpenTyrian_guard.should_build,
    haltOnFailure=True,
))

OpenTyrian_factory.addStep(RequireProperty(
    "OpenTyrian_version",
    name="Verify Build Reported a Version",
    doStepIf=OpenTyrian_guard.should_build,
    haltOnFailure=True,
))

OpenTyrian_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "opentyrian",
        "--tag", util.Interpolate("opentyrian_%(prop:OpenTyrian_version)s"),
        "--version", util.Property('OpenTyrian_version'),
        "--dmg", util.Property('OpenTyrian_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/opentyrian"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenTyrian_publish_schedulers),
        OpenTyrian_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

OpenTyrian_factory.addStep(RecordBuiltTag(OpenTyrian_guard, doStepIf=OpenTyrian_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="OpenTyrian-builder", workernames=["worker1"], factory=OpenTyrian_factory, project="OpenTyrian")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="OpenTyrian-changes",
        change_filter=util.ChangeFilter(project='OpenTyrian'),
        treeStableTimer=60,
        builderNames=["OpenTyrian-builder"]),
    schedulers.ForceScheduler(
        name="OpenTyrian-force",
        builderNames=["OpenTyrian-builder"]),
    schedulers.ForceScheduler(
        name="OpenTyrian-publish",
        builderNames=["OpenTyrian-builder"])
]
