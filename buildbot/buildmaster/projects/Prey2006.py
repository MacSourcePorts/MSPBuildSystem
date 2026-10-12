# Prey2006

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

Prey2006_guard = VersionGuard(
    project_name="Prey2006",
    tag_property="Prey2006_latest_tag",
    force_scheduler_names={"Prey2006-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="prey2006",
)

Prey2006_publish_schedulers = {"Prey2006-changes", "Prey2006-publish"}

project_list = [ 
    util.Project(name="Prey2006",description="Prey2006 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/FriskTheFallenHuman/Prey2006',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Prey2006"),
        project="Prey2006",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

Prey2006_factory = util.BuildFactory()

Prey2006_factory.addStep(steps.Git(
    repourl='https://github.com/FriskTheFallenHuman/Prey2006',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Prey2006"),
    name="Git Pull Latest Prey2006 Code",
    haltOnFailure=True
))

# Prey2006_factory.addStep(steps.SetPropertyFromCommand(
#     command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Prey2006"),
#     property="Prey2006_latest_tag",
#     name="Fetch Latest Prey2006 Tag",
#     haltOnFailure=True
# ))

# Prey2006_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('Prey2006_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Prey2006"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True
# ))

Prey2006_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Prey2006/macsourceports_universal2.sh"), "notarize", "1.5.4"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Prey2006"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=Prey2006_guard.should_build,
    extract_fn=make_dmg_extractor("Prey2006_dmg_path"),
))

Prey2006_factory.addStep(RequireProperty(
    "Prey2006_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=Prey2006_guard.should_build,
    haltOnFailure=True,
))

Prey2006_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Prey2006",
        "--tag", util.Interpolate("Prey2006_%(prop:Prey2006_latest_tag)s"),
        "--version", util.Property('Prey2006_latest_tag'),
        "--dmg", util.Property('Prey2006_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Prey2006"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Prey2006_publish_schedulers),
        Prey2006_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

Prey2006_factory.addStep(RecordBuiltTag(Prey2006_guard, doStepIf=Prey2006_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="Prey2006-builder", workernames=["worker1"], factory=Prey2006_factory, project="Prey2006")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Prey2006-changes",
        change_filter=util.ChangeFilter(project='Prey2006'),
        treeStableTimer=60,
        builderNames=["Prey2006-builder"]),
    schedulers.ForceScheduler(
        name="Prey2006-force",
        builderNames=["Prey2006-builder"]),
    schedulers.ForceScheduler(
        name="Prey2006-publish",
        builderNames=["Prey2006-builder"])
]