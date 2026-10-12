# CommanderGenius

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

CommanderGenius_guard = VersionGuard(
    project_name="CommanderGenius",
    tag_property="CommanderGenius_latest_tag",
    force_scheduler_names={"CommanderGenius-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="commander-genius",
)

CommanderGenius_publish_schedulers = {"CommanderGenius-changes", "CommanderGenius-publish"}

project_list = [ 
    util.Project(name="CommanderGenius",description="CommanderGenius source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://gitlab.com/Dringgstein/Commander-Genius',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Commander-Genius"),
        project="CommanderGenius",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

CommanderGenius_factory = util.BuildFactory()

CommanderGenius_factory.addStep(steps.Git(
    repourl='https://gitlab.com/Dringgstein/Commander-Genius',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Commander-Genius"),
    name="Git Pull Latest CommanderGenius Code",
    haltOnFailure=True
))

CommanderGenius_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Commander-Genius"),
    property="CommanderGenius_latest_tag",
    name="Fetch Latest CommanderGenius Tag",
    haltOnFailure=True
))

CommanderGenius_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('CommanderGenius_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Commander-Genius"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=CommanderGenius_guard.should_build
))

CommanderGenius_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Commander-Genius/macsourceports_universal2.sh"), "notarize", util.Property('CommanderGenius_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Commander-Genius"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=CommanderGenius_guard.should_build,
    extract_fn=make_dmg_extractor("CommanderGenius_dmg_path"),
))

CommanderGenius_factory.addStep(RequireProperty(
    "CommanderGenius_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=CommanderGenius_guard.should_build,
    haltOnFailure=True,
))

CommanderGenius_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Commander-Genius",
        "--tag", util.Interpolate("CGenius_%(prop:CommanderGenius_latest_tag)s"),
        "--version", util.Property('CommanderGenius_latest_tag'),
        "--dmg", util.Property('CommanderGenius_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Commander-Genius"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, CommanderGenius_publish_schedulers),
        CommanderGenius_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

CommanderGenius_factory.addStep(RecordBuiltTag(CommanderGenius_guard, doStepIf=CommanderGenius_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="CommanderGenius-builder", workernames=["worker1"], factory=CommanderGenius_factory, project="CommanderGenius")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="CommanderGenius-changes",
        change_filter=util.ChangeFilter(project='CommanderGenius'),
        treeStableTimer=60,
        builderNames=["CommanderGenius-builder"]),
    schedulers.ForceScheduler(
        name="CommanderGenius-force",
        builderNames=["CommanderGenius-builder"]),
    schedulers.ForceScheduler(
        name="CommanderGenius-publish",
        builderNames=["CommanderGenius-builder"])
]