# Doom64EXPlus

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

Doom64EXPlus_guard = VersionGuard(
    project_name="Doom64EX-Plus",
    tag_property="Doom64EX-Plus_latest_tag",
    force_scheduler_names={"Doom64EX-Plus-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="doom64ex",
)

Doom64EXPlus_publish_schedulers = {"Doom64EX-Plus-changes", "Doom64EX-Plus-publish"}

project_list = [ 
    util.Project(name="Doom64EX-Plus",description="Doom64EX-Plus source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/atsb/Doom64EX-Plus',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Doom64EX-Plus"),
        project="Doom64EX-Plus",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

Doom64EXPlus_factory = util.BuildFactory()
Doom64EXPlus_factory.addStep(steps.Git(
    repourl='https://github.com/atsb/Doom64EX-Plus',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Doom64EX-Plus"),
    name="Git Pull Latest Doom64EX-Plus Code",
    haltOnFailure=True
))
Doom64EXPlus_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Doom64EX-Plus"),
    property="Doom64EX-Plus_latest_tag",
    name="Fetch Latest Doom64EX-Plus Tag",
    haltOnFailure=True
))
Doom64EXPlus_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('Doom64EX-Plus_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Doom64EX-Plus"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
Doom64EXPlus_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Doom64EX-Plus/macsourceports_universal2.sh"), "notarize", util.Property('Doom64EX-Plus_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Doom64EX-Plus"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=Doom64EXPlus_guard.should_build,
    extract_fn=make_dmg_extractor("Doom64EXPlus_dmg_path"),
))

Doom64EXPlus_factory.addStep(RequireProperty(
    "Doom64EXPlus_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=Doom64EXPlus_guard.should_build,
    haltOnFailure=True,
))

Doom64EXPlus_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Doom64EX-Plus",
        "--tag", util.Interpolate("Doom64EXPlus_%(prop:Doom64EXPlus_latest_tag)s"),
        "--version", util.Property('Doom64EXPlus_latest_tag'),
        "--dmg", util.Property('Doom64EXPlus_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Doom64EX-Plus"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Doom64EXPlus_publish_schedulers),
        Doom64EXPlus_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

Doom64EXPlus_factory.addStep(RecordBuiltTag(Doom64EXPlus_guard, doStepIf=Doom64EXPlus_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="Doom64EX-Plus-builder", workernames=["worker1"], factory=Doom64EXPlus_factory, project="Doom64EX-Plus")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Doom64EX-Plus-changes",
        change_filter=util.ChangeFilter(project='Doom64EX-Plus', branch='stable'),
        treeStableTimer=60,
        builderNames=["Doom64EX-Plus-builder"]),
    schedulers.ForceScheduler(
        name="Doom64EX-Plus-force",
        builderNames=["Doom64EX-Plus-builder"]),
    schedulers.ForceScheduler(
        name="Doom64EX-Plus-publish",
        builderNames=["Doom64EX-Plus-builder"])
]