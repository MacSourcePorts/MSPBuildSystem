# Serious-Engine

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Serious-Engine",description="Serious-Engine source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/Serious-Engine',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Serious-Engine"),
        project="Serious-Engine",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

SeriousEngine_factory = util.BuildFactory()
SeriousEngine_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/Serious-Engine',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Serious-Engine"),
    name="Git Pull Latest Serious-Engine Code",
    haltOnFailure=True
))
SeriousEngine_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Serious-Engine/macsourceports_universal2-ssfe.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Serious-Engine"),
    name="Run Build Script for First Encounter",
    haltOnFailure=True
))
SeriousEngine_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Serious-Engine/macsourceports_universal2-ssse.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Serious-Engine"),
    name="Run Build Script for Second Encounter",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Serious-Engine-builder", workernames=["worker1"], factory=SeriousEngine_factory, project="Serious-Engine")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Serious-Engine-changes",
        change_filter=util.ChangeFilter(project='Serious-Engine', branch='main'),
        treeStableTimer=None,
        builderNames=["Serious-Engine-builder"]),
    schedulers.ForceScheduler(
        name="Serious-Engine-force",
        builderNames=["Serious-Engine-builder"])
]