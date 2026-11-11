# BurgerDoom

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

BurgerDoom_guard = VersionGuard(
    project_name="BurgerDoom",
    tag_property="BurgerDoom_latest_tag",
    force_scheduler_names={"BurgerDoom-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="burgerdoom",
)

BurgerDoom_publish_schedulers = {"BurgerDoom-changes", "BurgerDoom-publish"}

project_list = [ 
    util.Project(name="BurgerDoom",description="BurgerDoom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/atsb/BurgerDoom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/BurgerDoom"),
        project="BurgerDoom",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

BurgerDoom_factory = util.BuildFactory()
BurgerDoom_factory.addStep(steps.Git(
    repourl='https://github.com/atsb/BurgerDoom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/BurgerDoom"),
    name="Git Pull Latest BurgerDoom Code",
    haltOnFailure=True
))

BurgerDoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/BurgerDoom"),
    property="BurgerDoom_latest_tag",
    name="Fetch Latest BurgerDoom Tag",
    haltOnFailure=True
))

# -f is required: upstream master carries case-duplicate headers (source/Doom.h and
# source/doom.h, etc.), which on a case-insensitive macOS volume always show up as
# locally modified right after the clone and make a plain checkout refuse to switch.
BurgerDoom_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", "-f", util.Property('BurgerDoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/BurgerDoom"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=BurgerDoom_guard.should_build
))

BurgerDoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/BurgerDoom/macsourceports_universal2.sh"), "notarize", util.Property('BurgerDoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/BurgerDoom"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=BurgerDoom_guard.should_build,
    extract_fn=make_dmg_extractor("BurgerDoom_dmg_path"),
))

BurgerDoom_factory.addStep(RequireProperty(
    "BurgerDoom_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=BurgerDoom_guard.should_build,
    haltOnFailure=True,
))

BurgerDoom_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "BurgerDoom",
        "--tag", util.Interpolate("BurgerDoom_%(prop:BurgerDoom_latest_tag)s"),
        "--version", util.Property('BurgerDoom_latest_tag'),
        "--dmg", util.Property('BurgerDoom_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/BurgerDoom"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, BurgerDoom_publish_schedulers),
        BurgerDoom_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

BurgerDoom_factory.addStep(RecordBuiltTag(BurgerDoom_guard, doStepIf=BurgerDoom_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="BurgerDoom-builder", workernames=["worker1"], factory=BurgerDoom_factory, project="BurgerDoom")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="BurgerDoom-changes",
        change_filter=util.ChangeFilter(project='BurgerDoom'),
        treeStableTimer=60,
        builderNames=["BurgerDoom-builder"]),
    schedulers.ForceScheduler(
        name="BurgerDoom-force",
        builderNames=["BurgerDoom-builder"]),
    schedulers.ForceScheduler(
        name="BurgerDoom-publish",
        builderNames=["BurgerDoom-builder"])
]