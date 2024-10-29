# ioq3

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="ioq3",description="ioq3 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/ioquake/ioq3',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/ioq3"),
        project="ioq3",
        branches=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

ioq3_factory = util.BuildFactory()
ioq3_factory.addStep(steps.Git(
    repourl='https://github.com/ioquake/ioq3',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ioq3"),
    name="Git Pull Latest ioq3 Code",
    haltOnFailure=True
))
ioq3_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ioq3/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ioq3"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="ioq3-builder", workernames=["worker1"], factory=ioq3_factory, project="ioq3")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="ioq3-changes",
        change_filter=util.ChangeFilter(project='ioq3', branch='main'),
        treeStableTimer=None,
        builderNames=["ioq3-builder"]),
    schedulers.ForceScheduler(
        name="ioq3-force",
        builderNames=["ioq3-builder"])
]