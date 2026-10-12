# dethrace

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

dethrace_guard = VersionGuard(
    project_name="dethrace",
    tag_property="dethrace_latest_tag",
    force_scheduler_names={"dethrace-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="dethrace",
)

dethrace_publish_schedulers = {"dethrace-changes", "dethrace-publish"}

project_list = [
    util.Project(name="dethrace", description="dethrace source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/dethrace-labs/dethrace',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/dethrace"),
        project="dethrace",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

dethrace_factory = util.BuildFactory()

dethrace_factory.addStep(steps.Git(
    repourl='https://github.com/dethrace-labs/dethrace',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dethrace"),
    name="Git Pull Latest dethrace Code",
    haltOnFailure=True,
    submodules=True
))

dethrace_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dethrace"),
    property="dethrace_latest_tag",
    name="Fetch Latest dethrace Tag",
    haltOnFailure=True
))
dethrace_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('dethrace_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dethrace"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=dethrace_guard.should_build
))

dethrace_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dethrace/macsourceports_universal2.sh"), "notarize", util.Property('dethrace_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dethrace"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=dethrace_guard.should_build,
    extract_fn=make_dmg_extractor("dethrace_dmg_path"),
))

dethrace_factory.addStep(RequireProperty(
    "dethrace_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=dethrace_guard.should_build,
    haltOnFailure=True,
))

dethrace_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "dethrace",
        "--tag", util.Interpolate("dethrace_%(prop:dethrace_latest_tag)s"),
        "--version", util.Property('dethrace_latest_tag'),
        "--dmg", util.Property('dethrace_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dethrace"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, dethrace_publish_schedulers),
        dethrace_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

dethrace_factory.addStep(RecordBuiltTag(dethrace_guard, doStepIf=dethrace_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="dethrace-builder", workernames=["worker1"], factory=dethrace_factory, project="dethrace")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="dethrace-changes",
        change_filter=util.ChangeFilter(project='dethrace'),
        treeStableTimer=60,
        builderNames=["dethrace-builder"]),
    schedulers.ForceScheduler(
        name="dethrace-force",
        builderNames=["dethrace-builder"]),
    schedulers.ForceScheduler(
        name="dethrace-publish",
        builderNames=["dethrace-builder"])
]