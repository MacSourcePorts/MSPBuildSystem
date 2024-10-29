# madbomber

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="madbomber",description="madbomber source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/madbomber',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/madbomber"),
        project="madbomber",
        branches=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

madbomber_factory = util.BuildFactory()
madbomber_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/madbomber',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/madbomber"),
    name="Git Pull Latest madbomber Code",
    haltOnFailure=True
))
madbomber_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/madbomber/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/madbomber"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="madbomber-builder", workernames=["worker1"], factory=madbomber_factory, project="madbomber")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="madbomber-changes",
        change_filter=util.ChangeFilter(project='madbomber', branch='main'),
        treeStableTimer=None,
        builderNames=["madbomber-builder"]),
    schedulers.ForceScheduler(
        name="madbomber-force",
        builderNames=["madbomber-builder"])
]