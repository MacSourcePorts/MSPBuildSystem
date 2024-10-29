# circuslinux

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="circuslinux",description="circuslinux source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/circuslinux',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/circuslinux"),
        project="circuslinux",
        branches=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

circuslinux_factory = util.BuildFactory()
circuslinux_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/circuslinux',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/circuslinux"),
    name="Git Pull Latest circuslinux Code",
    haltOnFailure=True
))
circuslinux_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/circuslinux/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/circuslinux"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="circuslinux-builder", workernames=["worker1"], factory=circuslinux_factory, project="circuslinux")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="circuslinux-changes",
        change_filter=util.ChangeFilter(project='circuslinux', branch='main'),
        treeStableTimer=None,
        builderNames=["circuslinux-builder"]),
    schedulers.ForceScheduler(
        name="circuslinux-force",
        builderNames=["circuslinux-builder"])
]