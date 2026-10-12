# chocolate-doom

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

chocolatedoom_guard = VersionGuard(
    project_name="chocolate-doom",
    tag_property="chocolatedoom_latest_tag",
    force_scheduler_names={"chocolate-doom-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="chocolatedoom",
)

chocolatedoom_publish_schedulers = {"chocolate-doom-changes", "chocolate-doom-publish"}

project_list = [
    util.Project(name="chocolate-doom", description="chocolate-doom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/chocolate-doom/chocolate-doom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/chocolate-doom"),
        project="chocolate-doom",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

chocolatedoom_factory = util.BuildFactory()

chocolatedoom_factory.addStep(steps.Git(
    repourl='https://github.com/chocolate-doom/chocolate-doom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-doom"),
    name="Git Pull Latest chocolate-doom Code",
    haltOnFailure=True
))

chocolatedoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-doom"),
    property="chocolatedoom_latest_tag",
    name="Fetch Latest chocolate-doom Tag",
    haltOnFailure=True
))

chocolatedoom_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('chocolatedoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-doom"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=chocolatedoom_guard.should_build
))

chocolatedoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/chocolate-doom/macsourceports_universal2.sh"), "notarize", util.Property('chocolatedoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/chocolate-doom"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=chocolatedoom_guard.should_build,
    extract_fn=make_dmg_extractor("chocolatedoom_dmg_path"),
))

chocolatedoom_factory.addStep(RequireProperty(
    "chocolatedoom_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=chocolatedoom_guard.should_build,
    haltOnFailure=True,
))

chocolatedoom_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "chocolate-doom",
        "--tag", util.Interpolate("chocolate-doom_%(prop:chocolatedoom_latest_tag)s"),
        "--version", util.Property('chocolatedoom_latest_tag'),
        "--dmg", util.Property('chocolatedoom_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-doom"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, chocolatedoom_publish_schedulers),
        chocolatedoom_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

chocolatedoom_factory.addStep(RecordBuiltTag(chocolatedoom_guard, doStepIf=chocolatedoom_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="chocolate-doom-builder", workernames=["worker1"], factory=chocolatedoom_factory, project="chocolate-doom")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="chocolate-doom-changes",
        change_filter=util.ChangeFilter(project='chocolate-doom'),
        treeStableTimer=60,
        builderNames=["chocolate-doom-builder"]),
    schedulers.ForceScheduler(
        name="chocolate-doom-force",
        builderNames=["chocolate-doom-builder"]),
    schedulers.ForceScheduler(
        name="chocolate-doom-publish",
        builderNames=["chocolate-doom-builder"])
]