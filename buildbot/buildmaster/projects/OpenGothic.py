# OpenGothic

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

OpenGothic_guard = VersionGuard(
    project_name="OpenGothic",
    tag_property="OpenGothic_latest_tag",
    force_scheduler_names={"OpenGothic-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="opengothic",
)

OpenGothic_publish_schedulers = {"OpenGothic-changes", "OpenGothic-publish"}

project_list = [ 
    util.Project(name="OpenGothic",description="OpenGothic source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Try/OpenGothic',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenGothic"),
        project="OpenGothic",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenGothic_factory = util.BuildFactory()

OpenGothic_factory.addStep(steps.Git(
    repourl='https://github.com/Try/OpenGothic',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenGothic"),
    name="Git Pull Latest OpenGothic Code",
    haltOnFailure=True,
    submodules=True
))

OpenGothic_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenGothic"),
    property="OpenGothic_latest_tag",
    name="Fetch Latest OpenGothic Tag",
    haltOnFailure=True
))

OpenGothic_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenGothic_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenGothic"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=OpenGothic_guard.should_build
))

OpenGothic_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenGothic/macsourceports_universal2.sh"), "notarize", util.Property('OpenGothic_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenGothic"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenGothic_guard.should_build,
    extract_fn=make_dmg_extractor("OpenGothic_dmg_path"),
))

OpenGothic_factory.addStep(RequireProperty(
    "OpenGothic_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=OpenGothic_guard.should_build,
    haltOnFailure=True,
))

OpenGothic_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenGothic",
        "--tag", util.Interpolate("OpenGothic_%(prop:OpenGothic_latest_tag)s"),
        "--version", util.Property('OpenGothic_latest_tag'),
        "--dmg", util.Property('OpenGothic_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenGothic"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenGothic_publish_schedulers),
        OpenGothic_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

OpenGothic_factory.addStep(RecordBuiltTag(OpenGothic_guard, doStepIf=OpenGothic_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="OpenGothic-builder", workernames=["worker1"], factory=OpenGothic_factory, project="OpenGothic")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenGothic-changes",
        change_filter=util.ChangeFilter(project='OpenGothic'),
        treeStableTimer=60,
        builderNames=["OpenGothic-builder"]),
    schedulers.ForceScheduler(
        name="OpenGothic-force",
        builderNames=["OpenGothic-builder"]),
    schedulers.ForceScheduler(
        name="OpenGothic-publish",
        builderNames=["OpenGothic-builder"])
]