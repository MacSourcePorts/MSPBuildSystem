# GemRB

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

GemRB_guard = VersionGuard(
    project_name="GemRB",
    tag_property="GemRB_latest_tag",
    force_scheduler_names={"GemRB-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="gemrb",
)

GemRB_publish_schedulers = {"GemRB-changes", "GemRB-publish"}

project_list = [ 
    util.Project(name="GemRB",description="GemRB source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/gemrb/gemrb',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/GemRB"),
        project="GemRB",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

GemRB_factory = util.BuildFactory()
GemRB_factory.addStep(steps.Git(
    repourl='https://github.com/gemrb/gemrb',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GemRB"),
    name="Git Pull Latest GemRB Code",
    haltOnFailure=True
))
GemRB_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GemRB"),
    property="GemRB_latest_tag",
    name="Fetch Latest GemRB Tag",
    haltOnFailure=True
))
GemRB_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('GemRB_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GemRB"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=GemRB_guard.should_build
))
GemRB_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/GemRB/macsourceports_universal2.sh"), "notarize", util.Property('GemRB_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/GemRB"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=GemRB_guard.should_build,
    extract_fn=make_dmg_extractor("GemRB_dmg_path"),
))

GemRB_factory.addStep(RequireProperty(
    "GemRB_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=GemRB_guard.should_build,
    haltOnFailure=True,
))
GemRB_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "GemRB",
        "--tag", util.Interpolate("GemRB_%(prop:GemRB_latest_tag)s"),
        "--version", util.Property('GemRB_latest_tag'),
        "--dmg", util.Property('GemRB_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GemRB"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, GemRB_publish_schedulers),
        GemRB_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

GemRB_factory.addStep(RecordBuiltTag(GemRB_guard, doStepIf=GemRB_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="GemRB-builder", workernames=["worker1"], factory=GemRB_factory, project="GemRB")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="GemRB-changes",
        change_filter=util.ChangeFilter(project='GemRB'),
        treeStableTimer=60,
        builderNames=["GemRB-builder"]),
    schedulers.ForceScheduler(
        name="GemRB-force",
        builderNames=["GemRB-builder"]),
    schedulers.ForceScheduler(
        name="GemRB-publish",
        builderNames=["GemRB-builder"])
]