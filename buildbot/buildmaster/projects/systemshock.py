# systemshock

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="systemshock",description="systemshock source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/systemshock',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/systemshock"),
        project="systemshock",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

systemshock_factory = util.BuildFactory()
systemshock_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/systemshock',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/systemshock"),
    name="Git Pull Latest systemshock Code",
    haltOnFailure=True
))
systemshock_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/systemshock/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/systemshock"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="systemshock-builder", workernames=["worker1"], factory=systemshock_factory, project="systemshock")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="systemshock-changes",
        change_filter=util.ChangeFilter(project='systemshock', branch='main'),
        treeStableTimer=None,
        builderNames=["systemshock-builder"]),
    schedulers.ForceScheduler(
        name="systemshock-force",
        builderNames=["systemshock-builder"])
]