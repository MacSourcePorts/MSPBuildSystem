# PvZ-Portable

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

PvZPortable_guard = VersionGuard(
    project_name="PvZ-Portable",
    tag_property="PvZPortable_latest_tag",
    force_scheduler_names={"PvZ-Portable-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="pvzportable",
)

PvZPortable_publish_schedulers = {"PvZ-Portable-changes", "PvZ-Portable-publish"}

project_list = [ 
    util.Project(name="PvZ-Portable",description="PvZ-Portable source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/wszqkzqk/PvZ-Portable',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/PvZ-Portable"),
        project="PvZ-Portable",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

PvZPortable_factory = util.BuildFactory()
PvZPortable_factory.addStep(steps.Git(
    repourl='https://github.com/wszqkzqk/PvZ-Portable',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/PvZ-Portable"),
    name="Git Pull Latest PvZ-Portable Code",
    haltOnFailure=True
))
PvZPortable_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/PvZ-Portable"),
    property="PvZPortable_latest_tag",
    name="Fetch Latest PvZ-Portable Tag",
    haltOnFailure=True
))
PvZPortable_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('PvZPortable_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/PvZ-Portable"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=PvZPortable_guard.should_build
))
PvZPortable_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/PvZ-Portable/macsourceports_universal2.sh"), "notarize", util.Property('PvZPortable_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/PvZ-Portable"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=PvZPortable_guard.should_build,
    extract_fn=make_dmg_extractor("PvZPortable_dmg_path"),
))

PvZPortable_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "PvZ-Portable",
        "--tag", util.Interpolate("PvZPortable_%(prop:PvZPortable_latest_tag)s"),
        "--version", util.Property('PvZPortable_latest_tag'),
        "--dmg", util.Property('PvZPortable_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/PvZ-Portable"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, PvZPortable_publish_schedulers),
        PvZPortable_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

PvZPortable_factory.addStep(RecordBuiltTag(PvZPortable_guard, doStepIf=PvZPortable_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="PvZ-Portable-builder", workernames=["worker1"], factory=PvZPortable_factory, project="PvZ-Portable")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="PvZ-Portable-releases",
        change_filter=util.ChangeFilter(project='PvZ-Portable'),
        treeStableTimer=60,
        builderNames=["PvZ-Portable-builder"]),
    schedulers.ForceScheduler(
        name="PvZ-Portable-force",
        builderNames=["PvZ-Portable-builder"]),
    schedulers.ForceScheduler(
        name="PvZPortable-publish",
        builderNames=["PvZ-Portable-builder"])
]