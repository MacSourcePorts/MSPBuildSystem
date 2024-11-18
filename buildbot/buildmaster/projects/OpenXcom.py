# OpenXcom

# Project where we build based the latest code because the tags are old and/or they don't do versioned releases

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenXcom",description="OpenXcom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/OpenXcom/OpenXcom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenXcom"),
        project="OpenXcom",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenXcom_factory = util.BuildFactory()
OpenXcom_factory.addStep(steps.Git(
    repourl='https://github.com/OpenXcom/OpenXcom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenXcom"),
    name="Git Pull Latest OpenXcom Code",
    haltOnFailure=True
))
OpenXcom_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenXcom/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenXcom"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenXcom-builder", workernames=["worker1"], factory=OpenXcom_factory, project="OpenXcom")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenXcom-changes",
        change_filter=util.ChangeFilter(project='OpenXcom', branch='master'),
        treeStableTimer=None,
        builderNames=["OpenXcom-builder"]),
    schedulers.ForceScheduler(
        name="OpenXcom-force",
        builderNames=["OpenXcom-builder"])
]