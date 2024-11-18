# OpenJK

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenJK",description="OpenJK source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/JACoders/OpenJK',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenJK"),
        project="OpenJK",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenJK_factory = util.BuildFactory()
OpenJK_factory.addStep(steps.Git(
    repourl='https://github.com/JACoders/OpenJK',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJK"),
    name="Git Pull Latest OpenJK Code",
    haltOnFailure=True
))
OpenJK_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJK/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJK"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenJK-builder", workernames=["worker1"], factory=OpenJK_factory, project="OpenJK")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenJK-changes",
        change_filter=util.ChangeFilter(project='OpenJK', branch='master'),
        treeStableTimer=None,
        builderNames=["OpenJK-builder"]),
    schedulers.ForceScheduler(
        name="OpenJK-force",
        builderNames=["OpenJK-builder"])
]