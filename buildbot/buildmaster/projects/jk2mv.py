# jk2mv

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="jk2mv",description="jk2mv source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/mvdevs/jk2mv',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/jk2mv"),
        project="jk2mv",
        branches=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

jk2mv_factory = util.BuildFactory()
jk2mv_factory.addStep(steps.Git(
    repourl='https://github.com/mvdevs/jk2mv',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/jk2mv"),
    name="Git Pull Latest jk2mv Code",
    haltOnFailure=True,
    submodules=True
))
jk2mv_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/jk2mv/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/jk2mv"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="jk2mv-builder", workernames=["worker1"], factory=jk2mv_factory, project="jk2mv")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="jk2mv-changes",
        change_filter=util.ChangeFilter(project='jk2mv', branch='master'),
        treeStableTimer=None,
        builderNames=["jk2mv-builder"]),
    schedulers.ForceScheduler(
        name="jk2mv-force",
        builderNames=["jk2mv-builder"])
]