# Abuse_1996

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Abuse_1996",description="Abuse_1996 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/Abuse_1996',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Abuse_1996"),
        project="Abuse_1996",
        branches=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

Abuse_1996_factory = util.BuildFactory()
Abuse_1996_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/Abuse_1996',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Abuse_1996"),
    name="Git Pull Latest Abuse_1996 Code",
    haltOnFailure=True
))
Abuse_1996_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Abuse_1996/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Abuse_1996"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Abuse_1996-builder", workernames=["worker1"], factory=Abuse_1996_factory, project="Abuse_1996")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Abuse_1996-changes",
        change_filter=util.ChangeFilter(project='Abuse_1996', branch='master'),
        treeStableTimer=None,
        builderNames=["Abuse_1996-builder"]),
    schedulers.ForceScheduler(
        name="Abuse_1996-force",
        builderNames=["Abuse_1996-builder"])
]