# RBDOOM3BFG

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="RBDOOM-3-BFG",description="RBDOOM-3-BFG source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/SRSaunders/RBDOOM-3-BFG',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/RBDOOM-3-BFG"),
        project="RBDOOM-3-BFG",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

RBDOOM3BFG_factory = util.BuildFactory()
RBDOOM3BFG_factory.addStep(steps.Git(
    repourl='https://github.com/SRSaunders/RBDOOM-3-BFG',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/RBDOOM-3-BFG"),
    name="Git Pull Latest RBDOOM-3-BFG Code",
    haltOnFailure=True,
    submodules=True
))
RBDOOM3BFG_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/RBDOOM-3-BFG/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/RBDOOM-3-BFG"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="RBDOOM-3-BFG-builder", workernames=["worker1"], factory=RBDOOM3BFG_factory, project="RBDOOM-3-BFG")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="RBDOOM-3-BFG-changes",
        change_filter=util.ChangeFilter(project='RBDOOM-3-BFG', branch='rpsubsets-and-pc'),
        treeStableTimer=None,
        builderNames=["RBDOOM-3-BFG-builder"]),
    schedulers.ForceScheduler(
        name="RBDOOM-3-BFG-force",
        builderNames=["RBDOOM-3-BFG-builder"])
]