# OpenMoHAA 

# Project where we build based the latest code because we can't update the original

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

OpenMoHAA_guard = VersionGuard(
    project_name="OpenMoHAA",
    tag_property="OpenMoHAA_latest_tag",
    force_scheduler_names={"OpenMoHAA-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="openmohaa",
)

OpenMoHAA_publish_schedulers = {"OpenMoHAA-changes", "OpenMoHAA-publish"}

project_list = [ 
    util.Project(name="OpenMoHAA",description="OpenMoHAA source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/openmoh/openmohaa',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenMoHAA"),
        project="OpenMoHAA",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenMoHAA_factory = util.BuildFactory()

OpenMoHAA_factory.addStep(steps.Git(
    repourl='https://github.com/openmoh/openmohaa',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenMoHAA"),
    name="Git Pull Latest OpenMoHAA Code",
    haltOnFailure=True,
    submodules=True
))

OpenMoHAA_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenMoHAA"),
    property="OpenMoHAA_latest_tag",
    name="Fetch Latest OpenMoHAA Tag",
    haltOnFailure=True
))

OpenMoHAA_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenMoHAA_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenMoHAA"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=OpenMoHAA_guard.should_build
))

OpenMoHAA_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenMoHAA/macsourceports_universal2.sh"), "notarize", util.Property('OpenMoHAA_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenMoHAA"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenMoHAA_guard.should_build,
    extract_fn=make_dmg_extractor("OpenMoHAA_dmg_path"),
))

OpenMoHAA_factory.addStep(RequireProperty(
    "OpenMoHAA_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=OpenMoHAA_guard.should_build,
    haltOnFailure=True,
))

OpenMoHAA_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenMoHAA",
        "--tag", util.Interpolate("OpenMoHAA_%(prop:OpenMoHAA_latest_tag)s"),
        "--version", util.Property('OpenMoHAA_latest_tag'),
        "--dmg", util.Property('OpenMoHAA_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenMoHAA"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenMoHAA_publish_schedulers),
        OpenMoHAA_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

OpenMoHAA_factory.addStep(RecordBuiltTag(OpenMoHAA_guard, doStepIf=OpenMoHAA_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="OpenMoHAA-builder", workernames=["worker1"], factory=OpenMoHAA_factory, project="OpenMoHAA")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenMoHAA-changes",
        change_filter=util.ChangeFilter(project='OpenMoHAA'),
        treeStableTimer=60,
        builderNames=["OpenMoHAA-builder"]),
    schedulers.ForceScheduler(
        name="OpenMoHAA-force",
        builderNames=["OpenMoHAA-builder"]),
    schedulers.ForceScheduler(
        name="OpenMoHAA-publish",
        builderNames=["OpenMoHAA-builder"])
]