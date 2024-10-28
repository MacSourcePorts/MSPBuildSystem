# OpenMoHAA 

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenMoHAA",description="OpenMoHAA source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/openmoh/openmohaa',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenMoHAA"),
        project="OpenMoHAA",
        branches=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

OpenMoHAA_factory = util.BuildFactory()
OpenMoHAA_factory.addStep(steps.Git(
    repourl='https://github.com/openmoh/openmohaa',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenMoHAA"),
    name="Git Pull Latest OpenMoHAA Code",
    haltOnFailure=True,
    submodules=True
))
OpenMoHAA_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenMoHAA/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenMoHAA"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenMoHAA-builder", workernames=["worker1"], factory=OpenMoHAA_factory, project="OpenMoHAA")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenMoHAA-changes",
        change_filter=util.ChangeFilter(project='OpenMoHAA', branch='main'),
        treeStableTimer=None,
        builderNames=["OpenMoHAA-builder"]),
    schedulers.ForceScheduler(
        name="OpenMoHAA-force",
        builderNames=["OpenMoHAA-builder"])
]