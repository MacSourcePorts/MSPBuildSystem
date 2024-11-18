# EDuke32

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="EDuke32",description="EDuke32 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://voidpoint.io/terminx/eduke32.git',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/EDuke32"),
        project="EDuke32",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

EDuke32_factory = util.BuildFactory()
EDuke32_factory.addStep(steps.Git(
    repourl='https://voidpoint.io/terminx/eduke32.git',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/EDuke32"),
    name="Git Pull Latest EDuke32 Code",
    haltOnFailure=True
))
EDuke32_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/EDuke32/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/EDuke32"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="EDuke32-builder", workernames=["worker1"], factory=EDuke32_factory, project="EDuke32")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="EDuke32-changes",
        change_filter=util.ChangeFilter(project='EDuke32', branch='master'),
        treeStableTimer=None,
        builderNames=["EDuke32-builder"]),
    schedulers.ForceScheduler(
        name="EDuke32-force",
        builderNames=["EDuke32-builder"])
]