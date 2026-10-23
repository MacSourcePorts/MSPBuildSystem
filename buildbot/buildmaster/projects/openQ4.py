# openQ4

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

openQ4_guard = VersionGuard(
    project_name="openQ4",
    tag_property="openQ4_latest_tag",
    force_scheduler_names={"openQ4-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="openQ4",
)

openQ4_publish_schedulers = {"openQ4-changes", "openQ4-publish"}

project_list = [
    util.Project(name="openQ4", description="openQ4 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/themuffinator/openQ4',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/openQ4"),
        project="openQ4",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

openQ4_factory = util.BuildFactory()

openQ4_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git ls-remote --tags --sort='-version:refname' https://github.com/themuffinator/openQ4.git | awk -F'/' '{print $3}' | head -n 1"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/openQ4"),
    property="openQ4_latest_tag",
    name="Fetch Latest openQ4 Tag",
    haltOnFailure=True
))

openQ4_factory.addStep(steps.Git(
    repourl='https://github.com/themuffinator/openQ4',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/openQ4"),
    name="Git Pull Latest openQ4 Code",
    haltOnFailure=True
))

openQ4_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('openQ4_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/openQ4"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=openQ4_guard.should_build
))

openQ4_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/openQ4/macsourceports_universal2.sh"), "notarize", util.Property('openQ4_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/openQ4"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=openQ4_guard.should_build,
    extract_fn=make_dmg_extractor("openQ4_dmg_path"),
))

openQ4_factory.addStep(RequireProperty(
    "openQ4_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=openQ4_guard.should_build,
    haltOnFailure=True,
))

openQ4_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "openQ4",
        "--tag", util.Interpolate("openQ4_%(prop:openQ4_latest_tag)s"),
        "--version", util.Property('openQ4_latest_tag'),
        "--dmg", util.Property('openQ4_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/openQ4"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, openQ4_publish_schedulers),
        openQ4_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

openQ4_factory.addStep(RecordBuiltTag(openQ4_guard, doStepIf=openQ4_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="openQ4-builder", workernames=["worker1"], factory=openQ4_factory, project="openQ4")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="openQ4-changes",
        change_filter=util.ChangeFilter(project='openQ4'),
        treeStableTimer=60,
        builderNames=["openQ4-builder"]),
    schedulers.ForceScheduler(
        name="openQ4-force",
        builderNames=["openQ4-builder"]),
    schedulers.ForceScheduler(
        name="openQ4-publish",
        builderNames=["openQ4-builder"])
]