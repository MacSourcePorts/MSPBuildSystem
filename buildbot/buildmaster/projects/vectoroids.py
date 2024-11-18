# vectoroids

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="vectoroids",description="vectoroids source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/vectoroids',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/vectoroids"),
    #     project="vectoroids",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

vectoroids_factory = util.BuildFactory()
vectoroids_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/vectoroids',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vectoroids"),
    name="Git Pull Latest vectoroids Code",
    haltOnFailure=True
))
vectoroids_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/vectoroids/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/vectoroids"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="vectoroids-builder", workernames=["worker1"], factory=vectoroids_factory, project="vectoroids")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="vectoroids-changes",
    #     change_filter=util.ChangeFilter(project='vectoroids', branch='main'),
    #     treeStableTimer=None,
    #     builderNames=["vectoroids-builder"]),
    schedulers.ForceScheduler(
        name="vectoroids-force",
        builderNames=["vectoroids-builder"])
]