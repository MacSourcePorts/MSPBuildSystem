# vkQuake

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

vkQuake_guard = VersionGuard(
    project_name="vkQuake",
    tag_property="vkQuake_latest_tag",
    force_scheduler_names={"vkQuake-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="vkquake",
)

vkQuake_publish_schedulers = {"vkQuake-changes", "vkQuake-publish"}

project_list = [ 
    util.Project(name="vkQuake",description="vkQuake source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Novum/vkQuake',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/vkQuake"),
        project="vkQuake",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

vkQuake_factory = util.BuildFactory()

vkQuake_factory.addStep(steps.Git(
    repourl='https://github.com/Novum/vkQuake',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vkQuake"),
    name="Git Pull Latest vkQuake Code",
    haltOnFailure=True
))

vkQuake_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vkQuake"),
    property="vkQuake_latest_tag",
    name="Fetch Latest vkQuake Tag",
    haltOnFailure=True
))

vkQuake_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('vkQuake_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vkQuake"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=vkQuake_guard.should_build
))

vkQuake_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/vkQuake/macsourceports_universal2.sh"), "notarize", util.Property('vkQuake_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/vkQuake"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=vkQuake_guard.should_build,
    extract_fn=make_dmg_extractor("vkQuake_dmg_path"),
))

vkQuake_factory.addStep(RequireProperty(
    "vkQuake_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=vkQuake_guard.should_build,
    haltOnFailure=True,
))

vkQuake_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "vkQuake",
        "--tag", util.Interpolate("vkQuake_%(prop:vkQuake_latest_tag)s"),
        "--version", util.Property('vkQuake_latest_tag'),
        "--dmg", util.Property('vkQuake_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vkQuake"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, vkQuake_publish_schedulers),
        vkQuake_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

vkQuake_factory.addStep(RecordBuiltTag(vkQuake_guard, doStepIf=vkQuake_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="vkQuake-builder", workernames=["worker1"], factory=vkQuake_factory, project="vkQuake")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="vkQuake-changes",
        change_filter=util.ChangeFilter(project='vkQuake'),
        treeStableTimer=60,
        builderNames=["vkQuake-builder"]),
    schedulers.ForceScheduler(
        name="vkQuake-force",
        builderNames=["vkQuake-builder"]),
    schedulers.ForceScheduler(
        name="vkQuake-publish",
        builderNames=["vkQuake-builder"])
]