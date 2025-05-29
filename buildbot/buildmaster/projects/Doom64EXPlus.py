# Doom64EXPlus

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Doom64EX-Plus",description="Doom64EX-Plus source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/tomkidd/Doom64EX-Plus',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Doom64EX-Plus"),
        project="Doom64EX-Plus",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

Doom64EXPlus_factory = util.BuildFactory()
Doom64EXPlus_factory.addStep(steps.Git(
    repourl='https://github.com/tomkidd/Doom64EX-Plus',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Doom64EX-Plus"),
    name="Git Pull Latest Doom64EX-Plus Code",
    haltOnFailure=True
))
Doom64EXPlus_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Doom64EX-Plus/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Doom64EX-Plus"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Doom64EX-Plus-builder", workernames=["worker1"], factory=Doom64EXPlus_factory, project="Doom64EX-Plus")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Doom64EX-Plus-changes",
        change_filter=util.ChangeFilter(project='Doom64EX-Plus', branch='master'),
        treeStableTimer=None,
        builderNames=["Doom64EX-Plus-builder"]),
    schedulers.ForceScheduler(
        name="Doom64EX-Plus-force",
        builderNames=["Doom64EX-Plus-builder"])
]