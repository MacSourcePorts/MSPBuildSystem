# defendguin

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="defendguin",description="defendguin source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/defendguin',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/defendguin"),
    #     project="defendguin",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

defendguin_factory = util.BuildFactory()
defendguin_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/defendguin',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/defendguin"),
    name="Git Pull Latest defendguin Code",
    haltOnFailure=True
))
defendguin_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/defendguin/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/defendguin"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="defendguin-builder", workernames=["worker1"], factory=defendguin_factory, project="defendguin")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="defendguin-changes",
    #     change_filter=util.ChangeFilter(project='defendguin', branch='main'),
    #     treeStableTimer=None,
    #     builderNames=["defendguin-builder"]),
    schedulers.ForceScheduler(
        name="defendguin-force",
        builderNames=["defendguin-builder"])
]