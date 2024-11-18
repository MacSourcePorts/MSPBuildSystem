# OpenTyrian2000

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenTyrian2000",description="OpenTyrian2000 source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/OpenTyrian2000',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenTyrian2000"),
    #     project="OpenTyrian2000",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

OpenTyrian2000_factory = util.BuildFactory()
OpenTyrian2000_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/OpenTyrian2000',
    mode='incremental',
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenTyrian2000"),
    name="Git Pull Latest OpenTyrian2000 Code",
    haltOnFailure=True
))
OpenTyrian2000_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenTyrian2000/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenTyrian2000"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenTyrian2000-builder", workernames=["worker1"], factory=OpenTyrian2000_factory, project="OpenTyrian2000")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="OpenTyrian2000-changes",
    #     change_filter=util.ChangeFilter(project='OpenTyrian2000', branch='master'),
    #     treeStableTimer=None,
    #     builderNames=["OpenTyrian2000-builder"]),
    schedulers.ForceScheduler(
        name="OpenTyrian2000-force",
        builderNames=["OpenTyrian2000-builder"])
]