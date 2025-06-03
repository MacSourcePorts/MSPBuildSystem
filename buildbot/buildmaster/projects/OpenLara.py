# OpenLara

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenLara",description="OpenLara source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/OpenLara',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenLara"),
        project="OpenLara",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenLara_factory = util.BuildFactory()
OpenLara_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/OpenLara',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenLara"),
    name="Git Pull Latest OpenLara Code",
    haltOnFailure=True
))
OpenLara_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenLara/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenLara"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenLara-builder", workernames=["worker1"], factory=OpenLara_factory, project="OpenLara")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenLara-changes",
        change_filter=util.ChangeFilter(project='OpenLara', branch='master'),
        treeStableTimer=None,
        builderNames=["OpenLara-builder"]),
    schedulers.ForceScheduler(
        name="OpenLara-force",
        builderNames=["OpenLara-builder"])
]