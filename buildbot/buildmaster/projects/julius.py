# julius

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

julius_guard = VersionGuard(
    project_name="julius",
    tag_property="julius_latest_tag",
    force_scheduler_names={"julius-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="julius",
)

julius_publish_schedulers = {"julius-changes", "julius-publish"}

project_list = [ 
    util.Project(name="julius",description="julius source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/bvschaik/julius',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/julius"),
        project="julius",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

julius_factory = util.BuildFactory()

julius_factory.addStep(steps.Git(
    repourl='https://github.com/bvschaik/julius',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/julius"),
    name="Git Pull Latest julius Code",   
    haltOnFailure=True
))

julius_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/julius"),
    property="julius_latest_tag",
    name="Fetch Latest julius Tag",
    haltOnFailure=True
))

julius_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('julius_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/julius"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=julius_guard.should_build
))

julius_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/julius/macsourceports_universal2.sh"), "notarize", util.Property('julius_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/julius"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=julius_guard.should_build,
    extract_fn=make_dmg_extractor("julius_dmg_path"),
))

julius_factory.addStep(RequireProperty(
    "julius_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=julius_guard.should_build,
    haltOnFailure=True,
))

julius_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "julius",
        "--tag", util.Interpolate("julius_%(prop:julius_latest_tag)s"),
        "--version", util.Property('julius_latest_tag'),
        "--dmg", util.Property('julius_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/julius"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, julius_publish_schedulers),
        julius_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

julius_factory.addStep(RecordBuiltTag(julius_guard, doStepIf=julius_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="julius-builder", workernames=["worker1"], factory=julius_factory, project="julius")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="julius-changes",
        change_filter=util.ChangeFilter(project='julius'),
        treeStableTimer=60,
        builderNames=["julius-builder"]),
    schedulers.ForceScheduler(
        name="julius-force",
        builderNames=["julius-builder"]),
    schedulers.ForceScheduler(
        name="julius-publish",
        builderNames=["julius-builder"])
]