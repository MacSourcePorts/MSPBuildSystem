# UZDoom

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
)

UZDoom_guard = VersionGuard(
    project_name="UZDoom",
    tag_property="UZDoom_latest_tag",
    force_scheduler_names={"UZDoom-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="uzdoom",
)

# Only these builders publish rhe release
UZDoom_publish_schedulers = {"UZDoom-changes", "UZDoom-publish"}


project_list = [
    util.Project(name="UZDoom", description="UZDoom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/UZDoom/UZDoom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/UZDoom"),
        project="UZDoom",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

UZDoom_factory = util.BuildFactory()
UZDoom_factory.addStep(steps.Git(
    repourl='https://github.com/UZDoom/UZDoom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/UZDoom"),
    name="Git Pull Latest UZDoom Code",
    haltOnFailure=True,
    submodules=True
))
UZDoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git ls-remote --tags --sort='-version:refname' https://github.com/UZDoom/UZDoom.git | awk -F'/' '{print $3}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/UZDoom"),
    property="UZDoom_latest_tag",
    name="Fetch Latest UZDoom Tag",
    haltOnFailure=True
))
UZDoom_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('UZDoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/UZDoom"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=UZDoom_guard.should_build
))

UZDoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/UZDoom/macsourceports_universal2.sh"), "notarize", util.Property('UZDoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/UZDoom"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=UZDoom_guard.should_build,
    extract_fn=make_dmg_extractor("UZDoom_dmg_path"),
))

UZDoom_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "UZDoom",
        "--tag", util.Interpolate("UZDoom_%(prop:UZDoom_latest_tag)s"),
        "--version", util.Property('UZDoom_latest_tag'),
        "--dmg", util.Property('UZDoom_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/UZDoom"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, UZDoom_publish_schedulers),
        UZDoom_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

UZDoom_factory.addStep(RecordBuiltTag(UZDoom_guard, doStepIf=UZDoom_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="UZDoom-builder", workernames=["worker1"], factory=UZDoom_factory, project="UZDoom")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="UZDoom-changes",
        change_filter=util.ChangeFilter(project='UZDoom'),
        treeStableTimer=60,
        builderNames=["UZDoom-builder"]),
    schedulers.ForceScheduler(
        name="UZDoom-force",
        builderNames=["UZDoom-builder"]),
    schedulers.ForceScheduler(
        name="UZDoom-publish",
        builderNames=["UZDoom-builder"])
]