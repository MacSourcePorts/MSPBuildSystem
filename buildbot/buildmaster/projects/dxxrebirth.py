# dxx-rebirth

    # Project where we build based the latest code because the latest tag is too old

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="dxx-rebirth",description="dxx-rebirth source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/dxx-rebirth/dxx-rebirth',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/dxx-rebirth"),
    #     project="dxx-rebirth",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

dxxrebirth_factory = util.BuildFactory()
dxxrebirth_factory.addStep(steps.Git(
    repourl='https://github.com/dxx-rebirth/dxx-rebirth',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dxx-rebirth"),
    name="Git Pull Latest dxx-rebirth Code",
    haltOnFailure=True
))
dxxrebirth_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dxx-rebirth/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dxx-rebirth"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="dxx-rebirth-builder", workernames=["worker1"], factory=dxxrebirth_factory, project="dxx-rebirth")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="dxx-rebirth-changes",
    #     change_filter=util.ChangeFilter(project='dxx-rebirth', branch='master'),
    #     treeStableTimer=None,
    #     builderNames=["dxx-rebirth-builder"]),
    schedulers.ForceScheduler(
        name="dxx-rebirth-force",
        builderNames=["dxx-rebirth-builder"])
]