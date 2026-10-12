# chocolate-quake

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

chocolatequake_guard = VersionGuard(
    project_name="chocolate-quake",
    tag_property="chocolatequake_latest_tag",
    force_scheduler_names={"chocolate-quake-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="chocolatequake",
)

chocolatequake_publish_schedulers = {"chocolate-quake-changes", "chocolate-quake-publish"}

project_list = [
    util.Project(name="chocolate-quake", description="chocolat-equake source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Henrique194/chocolate-quake',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/chocolate-quake"),
        project="chocolate-quake",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

chocolatequake_factory = util.BuildFactory()

chocolatequake_factory.addStep(steps.Git(
    repourl='https://github.com/Henrique194/chocolate-quake',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-quake"),
    name="Git Pull Latest chocolate-quake Code",
    haltOnFailure=True
))

chocolatequake_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-quake"),
    property="chocolatequake_latest_tag",
    name="Fetch Latest chocolate-quake Tag",
    haltOnFailure=True
))

# chocolatequake_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('chocolatequake_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-quake"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True
#    doStepIf=chocolatequake_guard.should_build
# ))

chocolatequake_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/chocolate-quake/macsourceports_universal2.sh"), "notarize", util.Property('chocolatequake_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/chocolate-quake"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=chocolatequake_guard.should_build,
    extract_fn=make_dmg_extractor("chocolatequake_dmg_path"),
))

chocolatequake_factory.addStep(RequireProperty(
    "chocolatequake_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=chocolatequake_guard.should_build,
    haltOnFailure=True,
))

chocolatequake_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "chocolate-quake",
        "--tag", util.Interpolate("chocolate-quake_%(prop:chocolatequake_latest_tag)s"),
        "--version", util.Property('chocolatequake_latest_tag'),
        "--dmg", util.Property('chocolatequake_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-quake"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, chocolatequake_publish_schedulers),
        chocolatequake_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

chocolatequake_factory.addStep(RecordBuiltTag(chocolatequake_guard, doStepIf=chocolatequake_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="chocolate-quake-builder", workernames=["worker1"], factory=chocolatequake_factory, project="chocolate-quake")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="chocolate-quake-changes",
        change_filter=util.ChangeFilter(project='chocolate-quake'),
        treeStableTimer=60,
        builderNames=["chocolate-quake-builder"]),
    schedulers.ForceScheduler(
        name="chocolate-quake-force",
        builderNames=["chocolate-quake-builder"]),
    schedulers.ForceScheduler(
        name="chocolate-quake-publish",
        builderNames=["chocolate-quake-builder"])
]