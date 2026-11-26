# OpenApoc (X-COM: Apocalypse)

# Project where we build based off of release tags from the project. OpenApoc
# tags its (pre-)releases by date (e.g. 20260916), which is also our version.
#
# Our macOS changes (CD image and saves in Application Support, GOG cue/bin
# detection) are applied by the build script from
# MSPBuildSystem/OpenApoc/msp-macos.patch. The build runs OpenApoc's data
# extractor, which needs a CD image: the build script downloads the same
# minimal one OpenApoc's own CI uses.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import (
    VersionGuard,
    RecordBuiltTag,
    scheduler_in,
    and_steps,
    make_dmg_extractor,
    is_publish_machine,
    RequireProperty,
)

OpenApoc_guard = VersionGuard(
    project_name="OpenApoc",
    tag_property="OpenApoc_latest_tag",
    force_scheduler_names={"OpenApoc-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="openapoc",
)

OpenApoc_publish_schedulers = {"OpenApoc-changes", "OpenApoc-publish"}

project_list = [
    util.Project(name="OpenApoc",description="OpenApoc source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/OpenApoc/OpenApoc',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenApoc"),
        project="OpenApoc",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenApoc_factory = util.BuildFactory()

OpenApoc_factory.addStep(steps.Git(
    repourl='https://github.com/OpenApoc/OpenApoc',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenApoc"),
    name="Git Pull Latest OpenApoc Code",
    haltOnFailure=True,
    submodules=True
))

OpenApoc_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenApoc"),
    property="OpenApoc_latest_tag",
    name="Fetch Latest OpenApoc Tag",
    haltOnFailure=True
))

OpenApoc_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenApoc_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenApoc"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=OpenApoc_guard.should_build
))

OpenApoc_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenApoc/macsourceports_universal2.sh"), "notarize", util.Property('OpenApoc_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenApoc"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenApoc_guard.should_build,
    timeout=3600,
    extract_fn=make_dmg_extractor("OpenApoc_dmg_path"),
))

OpenApoc_factory.addStep(RequireProperty(
    "OpenApoc_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=OpenApoc_guard.should_build,
    haltOnFailure=True,
))

OpenApoc_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenApoc",
        "--tag", util.Interpolate("OpenApoc_%(prop:OpenApoc_latest_tag)s"),
        "--version", util.Property('OpenApoc_latest_tag'),
        "--dmg", util.Property('OpenApoc_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenApoc"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenApoc_publish_schedulers),
        OpenApoc_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

OpenApoc_factory.addStep(RecordBuiltTag(OpenApoc_guard, doStepIf=OpenApoc_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="OpenApoc-builder", workernames=["worker1"], factory=OpenApoc_factory, project="OpenApoc")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="OpenApoc-changes",
        change_filter=util.ChangeFilter(project='OpenApoc'),
        treeStableTimer=60,
        builderNames=["OpenApoc-builder"]),
    schedulers.ForceScheduler(
        name="OpenApoc-force",
        builderNames=["OpenApoc-builder"]),
    schedulers.ForceScheduler(
        name="OpenApoc-publish",
        builderNames=["OpenApoc-builder"])
]
