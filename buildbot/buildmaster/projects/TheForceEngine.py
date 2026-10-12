# TheForceEngine

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

TheForceEngine_guard = VersionGuard(
    project_name="TheForceEngine",
    tag_property="TheForceEngine_latest_tag",
    force_scheduler_names={"TheForceEngine-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="theforceengine",
)

TheForceEngine_publish_schedulers = {"TheForceEngine-changes", "TheForceEngine-publish"}

project_list = [ 
    util.Project(name="TheForceEngine",description="TheForceEngine source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/luciusDXL/TheForceEngine',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/TheForceEngine"),
        project="TheForceEngine",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

TheForceEngine_factory = util.BuildFactory()

TheForceEngine_factory.addStep(steps.Git(
    repourl='https://github.com/luciusDXL/TheForceEngine',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TheForceEngine"),
    name="Git Pull Latest TheForceEngine Code",
    haltOnFailure=True
))

TheForceEngine_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TheForceEngine"),
    property="TheForceEngine_latest_tag",
    name="Fetch Latest TheForceEngine Tag",
    haltOnFailure=True
))

# TheForceEngine_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('TheForceEngine_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TheForceEngine"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True,
#     doStepIf=TheForceEngine_guard.should_build
# ))

TheForceEngine_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/TheForceEngine/macsourceports_universal2.sh"), "notarize", "1.22.420"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/TheForceEngine"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=TheForceEngine_guard.should_build,
    extract_fn=make_dmg_extractor("TheForceEngine_dmg_path"),
))

TheForceEngine_factory.addStep(RequireProperty(
    "TheForceEngine_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=TheForceEngine_guard.should_build,
    haltOnFailure=True,
))

TheForceEngine_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "TheForceEngine",
        "--tag", util.Interpolate("TheForceEngine_%(prop:TheForceEngine_latest_tag)s"),
        "--version", util.Property('TheForceEngine_latest_tag'),
        "--dmg", util.Property('TheForceEngine_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TheForceEngine"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, TheForceEngine_publish_schedulers),
        TheForceEngine_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

TheForceEngine_factory.addStep(RecordBuiltTag(TheForceEngine_guard, doStepIf=TheForceEngine_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="TheForceEngine-builder", workernames=["worker1"], factory=TheForceEngine_factory, project="TheForceEngine")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="TheForceEngine-changes",
        change_filter=util.ChangeFilter(project='TheForceEngine'),
        treeStableTimer=60,
        builderNames=["TheForceEngine-builder"]),
    schedulers.ForceScheduler(
        name="TheForceEngine-force",
        builderNames=["TheForceEngine-builder"]),
    schedulers.ForceScheduler(
        name="TheForceEngine-publish",
        builderNames=["TheForceEngine-builder"])
]