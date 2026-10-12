# GZSelaco

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

GZSelaco_guard = VersionGuard(
    project_name="GZSelaco",
    tag_property="GZSelaco_latest_tag",
    force_scheduler_names={"GZSelaco-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="gzselaco",
)

GZSelaco_publish_schedulers = {"GZSelaco-changes", "GZSelaco-publish"}

project_list = [ 
    util.Project(name="GZSelaco",description="GZSelaco source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/CrowEater/GZSelaco',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/GZSelaco"),
        project="GZSelaco",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

GZSelaco_factory = util.BuildFactory()

GZSelaco_factory.addStep(steps.Git(
    repourl='https://github.com/CrowEater/GZSelaco',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GZSelaco"),
    name="Git Pull Latest GZSelaco Code",
    haltOnFailure=True,
    submodules=True
))

GZSelaco_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GZSelaco"),
    property="GZSelaco_latest_tag",
    name="Fetch Latest GZSelaco Tag",
    haltOnFailure=True
))

GZSelaco_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('GZSelaco_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GZSelaco"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=GZSelaco_guard.should_build
))

GZSelaco_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/GZSelaco/macsourceports_universal2.sh"), "notarize", util.Property('GZSelaco_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/GZSelaco"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=GZSelaco_guard.should_build,
    extract_fn=make_dmg_extractor("GZSelaco_dmg_path"),
))

GZSelaco_factory.addStep(RequireProperty(
    "GZSelaco_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=GZSelaco_guard.should_build,
    haltOnFailure=True,
))

GZSelaco_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "GZSelaco",
        "--tag", util.Interpolate("GZSelaco_%(prop:GZSelaco_latest_tag)s"),
        "--version", util.Property('GZSelaco_latest_tag'),
        "--dmg", util.Property('GZSelaco_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GZSelaco"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, GZSelaco_publish_schedulers),
        GZSelaco_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="GZSelaco-builder", workernames=["worker1"], factory=GZSelaco_factory, project="GZSelaco")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="GZSelaco-changes",
        change_filter=util.ChangeFilter(project='GZSelaco', branch='main'),
        treeStableTimer=60,
        builderNames=["GZSelaco-builder"]),
    schedulers.ForceScheduler(
        name="GZSelaco-force",
        builderNames=["GZSelaco-builder"]),
    schedulers.ForceScheduler(
        name="GZSelaco-publish",
        builderNames=["GZSelaco-builder"])
]