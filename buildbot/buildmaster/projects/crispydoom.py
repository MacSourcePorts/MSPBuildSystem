# crispy-doom

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

crispydoom_guard = VersionGuard(
    project_name="crispy-doom",
    tag_property="crispydoom_latest_tag",
    force_scheduler_names={"crispy-doom-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="crispydoom",
)

crispydoom_publish_schedulers = {"crispy-doom-changes", "crispy-doom-publish"}

project_list = [ 
    util.Project(name="crispy-doom",description="crispy-doom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/fabiangreffrath/crispy-doom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/crispy-doom"),
        project="crispy-doom",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

crispydoom_factory = util.BuildFactory()

crispydoom_factory.addStep(steps.Git(
    repourl='https://github.com/fabiangreffrath/crispy-doom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/crispy-doom"),
    name="Git Pull Latest crispy-doom Code",
    haltOnFailure=True
))

crispydoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/crispy-doom"),
    property="crispydoom_latest_tag",
    name="Fetch Latest crispy-doom Tag",
    haltOnFailure=True
))

crispydoom_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('crispydoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/crispy-doom"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=crispydoom_guard.should_build
))

crispydoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/crispy-doom/macsourceports_universal2.sh"), "notarize", util.Property('crispydoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/crispy-doom"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=crispydoom_guard.should_build,
    extract_fn=make_dmg_extractor("crispydoom_dmg_path"),
))

crispydoom_factory.addStep(RequireProperty(
    "crispydoom_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=crispydoom_guard.should_build,
    haltOnFailure=True,
))

crispydoom_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "crispy-doom",
        "--tag", util.Interpolate("crispy-doom_%(prop:crispydoom_latest_tag)s"),
        "--version", util.Property('crispydoom_latest_tag'),
        "--dmg", util.Property('crispydoom_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/crispy-doom"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, crispydoom_publish_schedulers),
        crispydoom_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

crispydoom_factory.addStep(RecordBuiltTag(crispydoom_guard, doStepIf=crispydoom_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="crispy-doom-builder", workernames=["worker1"], factory=crispydoom_factory, project="crispy-doom")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="crispy-doom-changes",
        change_filter=util.ChangeFilter(project='crispy-doom'),
        treeStableTimer=60,
        builderNames=["crispy-doom-builder"]),
    schedulers.ForceScheduler(
        name="crispy-doom-force",
        builderNames=["crispy-doom-builder"]),
    schedulers.ForceScheduler(
        name="crispy-doom-publish",
        builderNames=["crispy-doom-builder"])
]