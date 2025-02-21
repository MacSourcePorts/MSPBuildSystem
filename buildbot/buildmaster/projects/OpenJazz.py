# OpenJazz

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenJazz",description="OpenJazz source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/openjazz',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenJazz"),
        project="OpenJazz",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenJazz_factory = util.BuildFactory()
OpenJazz_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/openjazz',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJazz"),
    name="Git Pull Latest OpenJazz Code",
    haltOnFailure=True
))
OpenJazz_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJazz/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJazz"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenJazz-builder", workernames=["worker1"], factory=OpenJazz_factory, project="OpenJazz")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenJazz-changes",
        change_filter=util.ChangeFilter(project='OpenJazz', branch='master'),
        treeStableTimer=None,
        builderNames=["OpenJazz-builder"]),
    schedulers.ForceScheduler(
        name="OpenJazz-force",
        builderNames=["OpenJazz-builder"])
]