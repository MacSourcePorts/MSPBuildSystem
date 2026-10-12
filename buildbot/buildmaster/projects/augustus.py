# augustus

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

augustus_guard = VersionGuard(
    project_name="augustus",
    tag_property="augustus_latest_tag",
    force_scheduler_names={"augustus-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="augustus",
)

augustus_publish_schedulers = {"augustus-changes", "augustus-publish"}

project_list = [
    util.Project(name="augustus", description="augustus source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Keriew/augustus',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/augustus"),
        project="augustus",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

augustus_factory = util.BuildFactory()

augustus_factory.addStep(steps.Git(
    repourl='https://github.com/Keriew/augustus',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/augustus"),
    name="Git Pull Latest augustus Code",   
    haltOnFailure=True
))

augustus_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/augustus"),
    property="augustus_latest_tag",
    name="Fetch Latest augustus Tag",
    haltOnFailure=True
))

augustus_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('augustus_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/augustus"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=augustus_guard.should_build
))

augustus_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/augustus/macsourceports_universal2.sh"), "notarize", util.Property('augustus_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/augustus"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=augustus_guard.should_build,
    extract_fn=make_dmg_extractor("augustus_dmg_path"),
))

augustus_factory.addStep(RequireProperty(
    "augustus_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=augustus_guard.should_build,
    haltOnFailure=True,
))

augustus_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "augustus",
        "--tag", util.Interpolate("augustus_%(prop:augustus_latest_tag)s"),
        "--version", util.Property('augustus_latest_tag'),
        "--dmg", util.Property('augustus_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/augustus"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, augustus_publish_schedulers),
        augustus_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

augustus_factory.addStep(RecordBuiltTag(augustus_guard, doStepIf=augustus_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="augustus-builder", workernames=["worker1"], factory=augustus_factory, project="augustus")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="augustus-changes",
        change_filter=util.ChangeFilter(project='augustus'),
        treeStableTimer=60,
        builderNames=["augustus-builder"]),
    schedulers.ForceScheduler(
        name="augustus-force",
        builderNames=["augustus-builder"]),
    schedulers.ForceScheduler(
        name="augustus-publish",
        builderNames=["augustus-builder"])
]