# uhexen2

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="uhexen2",description="uhexen2 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/sezero/uhexen2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/uhexen2"),
        project="uhexen2",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

uhexen2_factory = util.BuildFactory()
uhexen2_factory.addStep(steps.Git(
    repourl='https://github.com/sezero/uhexen2',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/uhexen2"),
    name="Git Pull Latest uhexen2 Code",
    haltOnFailure=True
))
uhexen2_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/uhexen2/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/uhexen2"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="uhexen2-builder", workernames=["worker1"], factory=uhexen2_factory, project="uhexen2")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="uhexen2-changes",
        change_filter=util.ChangeFilter(project='uhexen2', branch='main'),
        treeStableTimer=None,
        builderNames=["uhexen2-builder"]),
    schedulers.ForceScheduler(
        name="uhexen2-force",
        builderNames=["uhexen2-builder"])
]