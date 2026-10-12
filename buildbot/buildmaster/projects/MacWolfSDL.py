# MacWolfSDL

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

MacWolfSDL_guard = VersionGuard(
    project_name="MacWolfSDL",
    tag_property="MacWolfSDL_latest_tag",
    force_scheduler_names={"MacWolfSDL-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="macwolfsdl",
)

MacWolfSDL_publish_schedulers = {"MacWolfSDL-changes", "MacWolfSDL-publish"}

project_list = [ 
    util.Project(name="MacWolfSDL",description="MacWolfSDL source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/LateGator/MacWolfSDL',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/MacWolfSDL"),
        project="MacWolfSDL",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

MacWolfSDL_factory = util.BuildFactory()

MacWolfSDL_factory.addStep(steps.Git(
    repourl='https://github.com/LateGator/MacWolfSDL',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MacWolfSDL"),
    name="Git Pull Latest MacWolfSDL Code",
    haltOnFailure=True
))

MacWolfSDL_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MacWolfSDL"),
    property="MacWolfSDL_latest_tag",
    name="Fetch Latest MacWolfSDL Tag",
    haltOnFailure=True
))

MacWolfSDL_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('MacWolfSDL_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MacWolfSDL"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=MacWolfSDL_guard.should_build
))

MacWolfSDL_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/MacWolfSDL/macsourceports_universal2.sh"), "notarize", util.Property('MacWolfSDL_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/MacWolfSDL"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=MacWolfSDL_guard.should_build,
    extract_fn=make_dmg_extractor("MacWolfSDL_dmg_path"),
))

MacWolfSDL_factory.addStep(RequireProperty(
    "MacWolfSDL_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=MacWolfSDL_guard.should_build,
    haltOnFailure=True,
))

MacWolfSDL_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "MacWolfSDL",
        "--tag", util.Interpolate("MacWolfSDL_%(prop:MacWolfSDL_latest_tag)s"),
        "--version", util.Property('MacWolfSDL_latest_tag'),
        "--dmg", util.Property('MacWolfSDL_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MacWolfSDL"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, MacWolfSDL_publish_schedulers),
        MacWolfSDL_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

MacWolfSDL_factory.addStep(RecordBuiltTag(MacWolfSDL_guard, doStepIf=MacWolfSDL_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="MacWolfSDL-builder", workernames=["worker1"], factory=MacWolfSDL_factory, project="MacWolfSDL")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="MacWolfSDL-changes",
        change_filter=util.ChangeFilter(project='MacWolfSDL'),
        treeStableTimer=60,
        builderNames=["MacWolfSDL-builder"]),
    schedulers.ForceScheduler(
        name="MacWolfSDL-force",
        builderNames=["MacWolfSDL-builder"]),
    schedulers.ForceScheduler(
        name="MacWolfSDL-publish",
        builderNames=["MacWolfSDL-builder"])
]