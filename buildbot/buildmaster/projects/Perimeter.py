# Perimeter

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

Perimeter_guard = VersionGuard(
    project_name="Perimeter",
    tag_property="Perimeter_latest_tag",
    force_scheduler_names={"Perimeter-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="perimeter",
)

Perimeter_publish_schedulers = {"Perimeter-changes", "Perimeter-publish"}

project_list = [ 
    util.Project(name="Perimeter",description="Perimeter source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/KD-lab-Open-Source/Perimeter',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Perimeter"),
        project="Perimeter",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

Perimeter_factory = util.BuildFactory()

Perimeter_factory.addStep(steps.Git(
    repourl='https://github.com/KD-lab-Open-Source/Perimeter',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Perimeter"),
    name="Git Pull Latest Perimeter Code",
    haltOnFailure=True
))

Perimeter_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Perimeter"),
    property="Perimeter_latest_tag",
    name="Fetch Latest Perimeter Tag",
    haltOnFailure=True
))

Perimeter_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('Perimeter_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Perimeter"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=Perimeter_guard.should_build
))

Perimeter_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Perimeter/macsourceports_universal2.sh"), "notarize", util.Property('Perimeter_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Perimeter"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=Perimeter_guard.should_build,
    extract_fn=make_dmg_extractor("Perimeter_dmg_path"),
))

Perimeter_factory.addStep(RequireProperty(
    "Perimeter_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=Perimeter_guard.should_build,
    haltOnFailure=True,
))

Perimeter_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Perimeter",
        "--tag", util.Interpolate("Perimeter_%(prop:Perimeter_latest_tag)s"),
        "--version", util.Property('Perimeter_latest_tag'),
        "--dmg", util.Property('Perimeter_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Perimeter"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Perimeter_publish_schedulers),
        Perimeter_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

Perimeter_factory.addStep(RecordBuiltTag(Perimeter_guard, doStepIf=Perimeter_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="Perimeter-builder", workernames=["worker1"], factory=Perimeter_factory, project="Perimeter")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Perimeter-changes",
        change_filter=util.ChangeFilter(project='Perimeter', branch='main'),
        treeStableTimer=60,
        builderNames=["Perimeter-builder"]),
    schedulers.ForceScheduler(
        name="Perimeter-force",
        builderNames=["Perimeter-builder"]),
    schedulers.ForceScheduler(
        name="Perimeter-publish",
        builderNames=["Perimeter-builder"])
]