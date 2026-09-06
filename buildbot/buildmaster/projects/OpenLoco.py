# OpenLoco

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenLoco",description="OpenLoco source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/OpenLoco/OpenLoco',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenLoco"),
        project="OpenLoco",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenLoco_factory = util.BuildFactory()
OpenLoco_factory.addStep(steps.Git(
    repourl='https://github.com/OpenLoco/OpenLoco',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenLoco"),
    name="Git Pull Latest OpenLoco Code",
    haltOnFailure=True
))

OpenLoco_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenLoco"),
    property="OpenLoco_latest_tag",
    name="Fetch Latest OpenLoco Tag",
    haltOnFailure=True
))
OpenLoco_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenLoco_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenLoco"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))

OpenLoco_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenLoco/macsourceports_universal2.sh"), "notarize", util.Property('OpenLoco_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenLoco"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenLoco-builder", workernames=["worker1"], factory=OpenLoco_factory, project="OpenLoco")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenLoco-releases",
        change_filter=util.ChangeFilter(project='OpenLoco'),
        treeStableTimer=None,
        builderNames=["OpenLoco-builder"]),
    schedulers.ForceScheduler(
        name="OpenLoco-force",
        builderNames=["OpenLoco-builder"])
]