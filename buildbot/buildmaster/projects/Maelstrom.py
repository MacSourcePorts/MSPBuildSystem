# Maelstrom

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Maelstrom",description="Maelstrom source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/Maelstrom',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Maelstrom"),
    #     project="Maelstrom",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

Maelstrom_factory = util.BuildFactory()
Maelstrom_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/Maelstrom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Maelstrom"),
    name="Git Pull Latest Maelstrom Code",
    haltOnFailure=True
))
Maelstrom_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Maelstrom/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Maelstrom"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Maelstrom-builder", workernames=["worker1"], factory=Maelstrom_factory, project="Maelstrom")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="Maelstrom-changes",
    #     change_filter=util.ChangeFilter(project='Maelstrom', branch='main'),
    #     treeStableTimer=None,
    #     builderNames=["Maelstrom-builder"]),
    schedulers.ForceScheduler(
        name="Maelstrom-force",
        builderNames=["Maelstrom-builder"])
]