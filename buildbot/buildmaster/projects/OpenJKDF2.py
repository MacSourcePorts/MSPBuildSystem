# OpenJKDF2

# Project where we build based off of release tags from the project

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

OpenJKDF2_guard = VersionGuard(
    project_name="OpenJKDF2",
    tag_property="OpenJKDF2_latest_tag",
    force_scheduler_names={"OpenJKDF2-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="openjkdf2",
)

OpenJKDF2_publish_schedulers = {"OpenJKDF2-changes", "OpenJKDF2-publish"}

project_list = [ 
    util.Project(name="OpenJKDF2",description="OpenJKDF2 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/shinyquagsire23/OpenJKDF2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenJKDF2"),
        project="OpenJKDF2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenJKDF2_factory = util.BuildFactory()

OpenJKDF2_factory.addStep(steps.Git(
    repourl='https://github.com/shinyquagsire23/OpenJKDF2',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJKDF2"),
    name="Git Pull Latest OpenJKDF2 Code",
    haltOnFailure=True,
    submodules=True
))

OpenJKDF2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJKDF2"),
    property="OpenJKDF2_latest_tag",
    name="Fetch Latest OpenJKDF2 Tag",
    haltOnFailure=True
))

OpenJKDF2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenJKDF2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJKDF2"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=OpenJKDF2_guard.should_build
))

OpenJKDF2_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJKDF2/macsourceports_universal2.sh"), "notarize", util.Property('OpenJKDF2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJKDF2"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenJKDF2_guard.should_build,
    extract_fn=make_dmg_extractor("OpenJKDF2_dmg_path"),
))

OpenJKDF2_factory.addStep(RequireProperty(
    "OpenJKDF2_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=OpenJKDF2_guard.should_build,
    haltOnFailure=True,
))

OpenJKDF2_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenJKDF2",
        "--tag", util.Interpolate("OpenJKDF2_%(prop:OpenJKDF2_latest_tag)s"),
        "--version", util.Property('OpenJKDF2_latest_tag'),
        "--dmg", util.Property('OpenJKDF2_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJKDF2"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenJKDF2_publish_schedulers),
        OpenJKDF2_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

OpenJKDF2_factory.addStep(RecordBuiltTag(OpenJKDF2_guard, doStepIf=OpenJKDF2_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="OpenJKDF2-builder", workernames=["worker1"], factory=OpenJKDF2_factory, project="OpenJKDF2")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenJKDF2-changes",
        change_filter=util.ChangeFilter(project='OpenJKDF2', branch='master'),
        treeStableTimer=60,
        builderNames=["OpenJKDF2-builder"]),
    schedulers.ForceScheduler(
        name="OpenJKDF2-force",
        builderNames=["OpenJKDF2-builder"]),
    schedulers.ForceScheduler(
        name="OpenJKDF2-publish",
        builderNames=["OpenJKDF2-builder"])
]