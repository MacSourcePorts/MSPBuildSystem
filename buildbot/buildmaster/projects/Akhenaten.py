# Akhenaten

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

Akhenaten_guard = VersionGuard(
    project_name="Akhenaten",
    tag_property="Akhenaten_latest_tag",
    force_scheduler_names={"Akhenaten-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="akhenaten",
)

Akhenaten_publish_schedulers = {"Akhenaten-changes", "Akhenaten-publish"}

project_list = [
    util.Project(name="Akhenaten", description="Akhenaten source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/dalerank/Akhenaten',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Akhenaten"),
        project="Akhenaten",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

Akhenaten_factory = util.BuildFactory()

Akhenaten_factory.addStep(steps.Git(
    repourl='https://github.com/dalerank/Akhenaten',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Akhenaten"),
    name="Git Pull Latest Akhenaten Code",
    haltOnFailure=True
))

Akhenaten_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Akhenaten"),
    property="Akhenaten_latest_tag",
    name="Fetch Latest Akhenaten Tag",
    haltOnFailure=True
))

Akhenaten_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('Akhenaten_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Akhenaten"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=Akhenaten_guard.should_build
))

Akhenaten_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Akhenaten/macsourceports_universal2.sh"), "notarize", util.Property('Akhenaten_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Akhenaten"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=Akhenaten_guard.should_build,
    extract_fn=make_dmg_extractor("Akhenaten_dmg_path"),
))

Akhenaten_factory.addStep(RequireProperty(
    "Akhenaten_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=Akhenaten_guard.should_build,
    haltOnFailure=True,
))

Akhenaten_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Akhenaten",
        "--tag", util.Interpolate("Akhenaten_%(prop:Akhenaten_latest_tag)s"),
        "--version", util.Property('Akhenaten_latest_tag'),
        "--dmg", util.Property('Akhenaten_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Akhenaten"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Akhenaten_publish_schedulers),
        Akhenaten_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

Akhenaten_factory.addStep(RecordBuiltTag(Akhenaten_guard, doStepIf=Akhenaten_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="Akhenaten-builder", workernames=["worker1"], factory=Akhenaten_factory, project="Akhenaten")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Akhenaten-changes",
        change_filter=util.ChangeFilter(project='Akhenaten'),
        treeStableTimer=60,
        builderNames=["Akhenaten-builder"]),
    schedulers.ForceScheduler(
        name="Akhenaten-force",
        builderNames=["Akhenaten-builder"]),
    schedulers.ForceScheduler(
        name="Akhenaten-publish",
        builderNames=["Akhenaten-builder"])
]