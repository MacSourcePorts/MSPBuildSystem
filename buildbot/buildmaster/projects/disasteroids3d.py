# disasteroids3d

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="disasteroids3d",description="disasteroids3d source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/disasteroids3d',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/disasteroids3d"),
        project="disasteroids3d",
        branches=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

disasteroids3d_factory = util.BuildFactory()
disasteroids3d_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/disasteroids3d',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/disasteroids3d"),
    name="Git Pull Latest disasteroids3d Code",
    haltOnFailure=True
))
disasteroids3d_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/disasteroids3d/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/disasteroids3d"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="disasteroids3d-builder", workernames=["worker1"], factory=disasteroids3d_factory, project="disasteroids3d")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="disasteroids3d-changes",
        change_filter=util.ChangeFilter(project='disasteroids3d', branch='master'),
        treeStableTimer=None,
        builderNames=["disasteroids3d-builder"]),
    schedulers.ForceScheduler(
        name="disasteroids3d-force",
        builderNames=["disasteroids3d-builder"])
]