# dhewm3

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

dhewm3_guard = VersionGuard(
    project_name="dhewm3",
    tag_property="dhewm3_latest_tag",
    force_scheduler_names={"dhewm3-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="dhewm3",
)

dhewm3_publish_schedulers = {"dhewm3-changes", "dhewm3-publish"}

project_list = [
    util.Project(name="dhewm3", description="dhewm3 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/dhewm/dhewm3',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/dhewm3"),
        project="dhewm3",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

dhewm3_factory = util.BuildFactory()

dhewm3_factory.addStep(steps.Git(
    repourl='https://github.com/dhewm/dhewm3',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dhewm3"),
    name="Git Pull Latest dhewm3 Code",
    haltOnFailure=True
))

dhewm3_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dhewm3"),
    property="dhewm3_latest_tag",
    name="Fetch Latest dhewm3 Tag",
    haltOnFailure=True
))

dhewm3_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('dhewm3_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dhewm3"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=dhewm3_guard.should_build
))

dhewm3_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dhewm3/macsourceports_universal2.sh"), "notarize", util.Property('dhewm3_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dhewm3"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=dhewm3_guard.should_build,
    extract_fn=make_dmg_extractor("dhewm3_dmg_path"),
))

dhewm3_factory.addStep(RequireProperty(
    "dhewm3_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=dhewm3_guard.should_build,
    haltOnFailure=True,
))

dhewm3_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "dhewm3",
        "--tag", util.Interpolate("dhewm3_%(prop:dhewm3_latest_tag)s"),
        "--version", util.Property('dhewm3_latest_tag'),
        "--dmg", util.Property('dhewm3_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dhewm3"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, dhewm3_publish_schedulers),
        dhewm3_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

dhewm3_factory.addStep(RecordBuiltTag(dhewm3_guard, doStepIf=dhewm3_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="dhewm3-builder", workernames=["worker1"], factory=dhewm3_factory, project="dhewm3")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="dhewm3-changes",
        change_filter=util.ChangeFilter(project='dhewm3'),
        treeStableTimer=60,
        builderNames=["dhewm3-builder"]),
    schedulers.ForceScheduler(
        name="dhewm3-force",
        builderNames=["dhewm3-builder"]),
    schedulers.ForceScheduler(
        name="dhewm3-publish",
        builderNames=["dhewm3-builder"])
]