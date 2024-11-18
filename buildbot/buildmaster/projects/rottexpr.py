# rottexpr

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="rottexpr",description="rottexpr source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/rottexpr',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/rottexpr"),
    #     project="rottexpr",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

rottexpr_factory = util.BuildFactory()
rottexpr_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/rottexpr',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rottexpr"),
    name="Git Pull Latest rottexpr Code",
    haltOnFailure=True
))
rottexpr_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/rottexpr/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/rottexpr"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="rottexpr-builder", workernames=["worker1"], factory=rottexpr_factory, project="rottexpr")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="rottexpr-changes",
    #     change_filter=util.ChangeFilter(project='rottexpr', branch='master'),
    #     treeStableTimer=None,
    #     builderNames=["rottexpr-builder"]),
    schedulers.ForceScheduler(
        name="rottexpr-force",
        builderNames=["rottexpr-builder"])
]