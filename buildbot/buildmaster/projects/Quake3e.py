# Quake3e

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Quake3e",description="Quake3e source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/ec-/quake3e',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Quake3e"),
        project="Quake3e",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

Quake3e_factory = util.BuildFactory()
Quake3e_factory.addStep(steps.Git(
    repourl='https://github.com/ec-/quake3e',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Quake3e"),
    name="Git Pull Latest Quake3e Code",
    haltOnFailure=True
))
Quake3e_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Quake3e/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Quake3e"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Quake3e-builder", workernames=["worker1"], factory=Quake3e_factory, project="Quake3e")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Quake3e-changes",
        change_filter=util.ChangeFilter(project='Quake3e', branch='main'),
        treeStableTimer=None,
        builderNames=["Quake3e-builder"]),
    schedulers.ForceScheduler(
        name="Quake3e-force",
        builderNames=["Quake3e-builder"])
]