# Selaco

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Selaco",description="Selaco source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/CrowEater/Selaco',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Selaco"),
        project="Selaco",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

Selaco_factory = util.BuildFactory()
Selaco_factory.addStep(steps.Git(
    repourl='https://github.com/CrowEater/Selaco',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Selaco"),
    name="Git Pull Latest Selaco Code",
    haltOnFailure=True,
    submodules=True
))
Selaco_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Selaco/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Selaco"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Selaco-builder", workernames=["worker1"], factory=Selaco_factory, project="Selaco")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Selaco-changes",
        change_filter=util.ChangeFilter(project='Selaco', branch='main'),
        treeStableTimer=None,
        builderNames=["Selaco-builder"]),
    schedulers.ForceScheduler(
        name="Selaco-force",
        builderNames=["Selaco-builder"])
]