# bstone

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

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
    haltOnFailure=True
))
bstone_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/bstone/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('bstone_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/bstone"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="bstone-builder", workernames=["worker1"], factory=bstone_factory, project="bstone")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="bstone-releases",
        change_filter=util.ChangeFilter(project='bstone'),
        treeStableTimer=None,
        builderNames=["bstone-builder"]),
    schedulers.ForceScheduler(
        name="bstone-force",
        builderNames=["bstone-builder"])
]