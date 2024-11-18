# bugsquish

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="bugsquish",description="bugsquish source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/bugsquish',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/bugsquish"),
    #     project="bugsquish",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

bugsquish_factory = util.BuildFactory()
bugsquish_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/bugsquish',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/bugsquish"),
    name="Git Pull Latest bugsquish Code",
    haltOnFailure=True
))
bugsquish_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/bugsquish/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/bugsquish"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="bugsquish-builder", workernames=["worker1"], factory=bugsquish_factory, project="bugsquish")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="bugsquish-changes",
    #     change_filter=util.ChangeFilter(project='bugsquish', branch='main'),
    #     treeStableTimer=None,
    #     builderNames=["bugsquish-builder"]),
    schedulers.ForceScheduler(
        name="bugsquish-force",
        builderNames=["bugsquish-builder"])
]