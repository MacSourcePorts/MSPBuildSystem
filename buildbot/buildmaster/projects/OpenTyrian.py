# OpenTyrian

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenTyrian",description="OpenTyrian source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/OpenTyrian',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenTyrian"),
    #     project="OpenTyrian",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

OpenTyrian_factory = util.BuildFactory()
OpenTyrian_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/OpenTyrian',
    mode='incremental',
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenTyrian"),
    name="Git Pull Latest OpenTyrian Code",
    haltOnFailure=True
))
OpenTyrian_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenTyrian/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenTyrian"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenTyrian-builder", workernames=["worker1"], factory=OpenTyrian_factory, project="OpenTyrian")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="OpenTyrian-changes",
    #     change_filter=util.ChangeFilter(project='OpenTyrian', branch='master'),
    #     treeStableTimer=None,
    #     builderNames=["OpenTyrian-builder"]),
    schedulers.ForceScheduler(
        name="OpenTyrian-force",
        builderNames=["OpenTyrian-builder"])
]