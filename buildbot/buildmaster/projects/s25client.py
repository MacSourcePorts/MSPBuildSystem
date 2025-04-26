# s25client

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="s25client",description="s25client source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Return-To-The-Roots/s25client',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/s25client"),
        project="s25client",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

s25client_factory = util.BuildFactory()
s25client_factory.addStep(steps.Git(
    repourl='https://github.com/Return-To-The-Roots/s25client',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/s25client"),
    name="Git Pull Latest s25client Code",
    haltOnFailure=True,
    submodules=True
))
s25client_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/s25client/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/s25client"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="s25client-builder", workernames=["worker1"], factory=s25client_factory, project="s25client")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="s25client-changes",
        change_filter=util.ChangeFilter(project='s25client', branch='main'),
        treeStableTimer=None,
        builderNames=["s25client-builder"]),
    schedulers.ForceScheduler(
        name="s25client-force",
        builderNames=["s25client-builder"])
]