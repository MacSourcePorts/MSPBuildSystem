# bstone

# Project where we build based off of release tags from the project

import os
import re
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import VersionGuard, RecordBuiltTag

bstone_guard = VersionGuard(
    project_name="bstone",
    tag_property="bstone_latest_tag",
    force_scheduler_names={"bstone-force"},
)

project_list = [ 
    util.Project(name="bstone",description="bstone source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/bibendovsky/bstone',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/bstone"),
        project="bstone",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

bstone_factory = util.BuildFactory()
bstone_factory.addStep(steps.Git(
    repourl='https://github.com/bibendovsky/bstone',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/bstone"),
    name="Git Pull Latest bstone Code",
    haltOnFailure=True
))

bstone_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/bstone"),
    property="bstone_latest_tag",
    name="Fetch Latest bstone Tag",
    haltOnFailure=True
))
bstone_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('bstone_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/bstone"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=bstone_guard.should_build
))
bstone_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/bstone/macsourceports_universal2.sh"), "notarize", util.Property('bstone_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/bstone"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=bstone_guard.should_build
))

bstone_factory.addStep(RecordBuiltTag(bstone_guard, doStepIf=bstone_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="bstone-builder", workernames=["worker1"], factory=bstone_factory, project="bstone")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="bstone-releases",
        change_filter=util.ChangeFilter(project='bstone'),
        treeStableTimer=60,
        builderNames=["bstone-builder"]),
    schedulers.ForceScheduler(
        name="bstone-force",
        builderNames=["bstone-builder"])
]