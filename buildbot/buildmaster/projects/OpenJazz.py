# OpenJazz

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

OpenJazz_guard = VersionGuard(
    project_name="OpenJazz",
    tag_property="OpenJazz_latest_tag",
    force_scheduler_names={"OpenJazz-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="openjazz",
)

OpenJazz_publish_schedulers = {"OpenJazz-changes", "OpenJazz-publish"}

project_list = [ 
    util.Project(name="OpenJazz",description="OpenJazz source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/AlisterT/openjazz',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenJazz"),
        project="OpenJazz",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenJazz_factory = util.BuildFactory()

OpenJazz_factory.addStep(steps.Git(
    repourl='https://github.com/AlisterT/openjazz',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJazz"),
    name="Git Pull Latest OpenJazz Code",
    haltOnFailure=True
))

OpenJazz_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git tag --sort=-creatordate | grep -v '^continuous$' | head -n 1"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJazz"),
    property="OpenJazz_latest_tag",
    name="Fetch Latest OpenJazz Tag",
    haltOnFailure=True
))

OpenJazz_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenJazz_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJazz"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=OpenJazz_guard.should_build
))

OpenJazz_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJazz/macsourceports_universal2.sh"), "notarize", util.Property('OpenJazz_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJazz"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenJazz_guard.should_build,
    extract_fn=make_dmg_extractor("OpenJazz_dmg_path"),
))

OpenJazz_factory.addStep(RequireProperty(
    "OpenJazz_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=OpenJazz_guard.should_build,
    haltOnFailure=True,
))

OpenJazz_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenJazz",
        "--tag", util.Interpolate("OpenJazz_%(prop:OpenJazz_latest_tag)s"),
        "--version", util.Property('OpenJazz_latest_tag'),
        "--dmg", util.Property('OpenJazz_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJazz"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenJazz_publish_schedulers),
        OpenJazz_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

OpenJazz_factory.addStep(RecordBuiltTag(OpenJazz_guard, doStepIf=OpenJazz_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="OpenJazz-builder", workernames=["worker1"], factory=OpenJazz_factory, project="OpenJazz")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenJazz-changes",
        change_filter=util.ChangeFilter(project='OpenJazz'),
        treeStableTimer=60,
        builderNames=["OpenJazz-builder"]),
    schedulers.ForceScheduler(
        name="OpenJazz-force",
        builderNames=["OpenJazz-builder"]),
    schedulers.ForceScheduler(
        name="OpenJazz-publish",
        builderNames=["OpenJazz-builder"])
]