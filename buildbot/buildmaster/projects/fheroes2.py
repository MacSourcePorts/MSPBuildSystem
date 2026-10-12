# fheroes2

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

fheroes2_guard = VersionGuard(
    project_name="fheroes2",
    tag_property="fheroes2_latest_tag",
    force_scheduler_names={"fheroes2-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="fheroes2",
)

fheroes2_publish_schedulers = {"fheroes2-changes", "fheroes2-publish"}

project_list = [ 
    util.Project(name="fheroes2",description="fheroes2 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/ihhub/fheroes2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/fheroes2"),
        project="fheroes2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

fheroes2_factory = util.BuildFactory()

fheroes2_factory.addStep(steps.Git(
    repourl='https://github.com/ihhub/fheroes2',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/fheroes2"),
    name="Git Pull Latest fheroes2 Code",   
    haltOnFailure=True
))

fheroes2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/fheroes2"),
    property="fheroes2_latest_tag",
    name="Fetch Latest fheroes2 Tag",
    haltOnFailure=True
))

fheroes2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('fheroes2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/fheroes2"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=fheroes2_guard.should_build
))

fheroes2_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/fheroes2/macsourceports_universal2.sh"), "notarize", util.Property('fheroes2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/fheroes2"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=fheroes2_guard.should_build,
    extract_fn=make_dmg_extractor("fheroes2_dmg_path"),
))

fheroes2_factory.addStep(RequireProperty(
    "fheroes2_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=fheroes2_guard.should_build,
    haltOnFailure=True,
))

fheroes2_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "fheroes2",
        "--tag", util.Interpolate("fheroes2_%(prop:fheroes2_latest_tag)s"),
        "--version", util.Property('fheroes2_latest_tag'),
        "--dmg", util.Property('fheroes2_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/fheroes2"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, fheroes2_publish_schedulers),
        fheroes2_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

fheroes2_factory.addStep(RecordBuiltTag(fheroes2_guard, doStepIf=fheroes2_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="fheroes2-builder", workernames=["worker1"], factory=fheroes2_factory, project="fheroes2")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="fheroes2-changes",
        change_filter=util.ChangeFilter(project='fheroes2'),
        treeStableTimer=60,
        builderNames=["fheroes2-builder"]),
    schedulers.ForceScheduler(
        name="fheroes2-force",
        builderNames=["fheroes2-builder"]),
    schedulers.ForceScheduler(
        name="fheroes2-publish",
        builderNames=["fheroes2-builder"])
]