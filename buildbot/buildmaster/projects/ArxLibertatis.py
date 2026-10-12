# ArxLibertatis

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

ArxLibertatis_guard = VersionGuard(
    project_name="ArxLibertatis",
    tag_property="ArxLibertatis_latest_tag",
    force_scheduler_names={"ArxLibertatis-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="arxLibertatis",
)

ArxLibertatis_publish_schedulers = {"ArxLibertatis-changes", "ArxLibertatis-publish"}

project_list = [
    util.Project(name="ArxLibertatis", description="ArxLibertatis source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/arx/ArxLibertatis',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/ArxLibertatis"),
        project="ArxLibertatis",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

ArxLibertatis_factory = util.BuildFactory()
ArxLibertatis_factory.addStep(steps.Git(
    repourl='https://github.com/arx/ArxLibertatis',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ArxLibertatis"),
    name="Git Pull Latest ArxLibertatis Code",   
    haltOnFailure=True
))

ArxLibertatis_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ArxLibertatis"),
    property="ArxLibertatis_latest_tag",
    name="Fetch Latest ArxLibertatis Tag",
    haltOnFailure=True
))

ArxLibertatis_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('ArxLibertatis_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ArxLibertatis"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=ArxLibertatis_guard.should_build
))

ArxLibertatis_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ArxLibertatis/macsourceports_universal2.sh"), "notarize", util.Property('ArxLibertatis_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ArxLibertatis"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=ArxLibertatis_guard.should_build,
    extract_fn=make_dmg_extractor("ArxLibertatis_dmg_path"),
))

ArxLibertatis_factory.addStep(RequireProperty(
    "ArxLibertatis_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=ArxLibertatis_guard.should_build,
    haltOnFailure=True,
))

ArxLibertatis_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "ArxLibertatis",
        "--tag", util.Interpolate("ArxLibertatis_%(prop:ArxLibertatis_latest_tag)s"),
        "--version", util.Property('ArxLibertatis_latest_tag'),
        "--dmg", util.Property('ArxLibertatis_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ArxLibertatis"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, ArxLibertatis_publish_schedulers),
        ArxLibertatis_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

ArxLibertatis_factory.addStep(RecordBuiltTag(ArxLibertatis_guard, doStepIf=ArxLibertatis_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="ArxLibertatis-builder", workernames=["worker1"], factory=ArxLibertatis_factory, project="ArxLibertatis")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="ArxLibertatis-changes",
        change_filter=util.ChangeFilter(project='ArxLibertatis'),
        treeStableTimer=60,
        builderNames=["ArxLibertatis-builder"]),
    schedulers.ForceScheduler(
        name="ArxLibertatis-force",
        builderNames=["ArxLibertatis-builder"]),
    schedulers.ForceScheduler(
        name="ArxLibertatis-publish",
        builderNames=["ArxLibertatis-builder"])
]