# postal

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="postal",description="postal source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/POSTAL-SourceCode',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/POSTAL-SourceCode"),
        project="postal",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

postal_factory = util.BuildFactory()
postal_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/POSTAL-SourceCode',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/POSTAL-SourceCode"),
    name="Git Pull Latest postal Code",
    haltOnFailure=True
))
postal_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/POSTAL-SourceCode/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/POSTAL-SourceCode"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="postal-builder", workernames=["worker1"], factory=postal_factory, project="postal")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="postal-changes",
        change_filter=util.ChangeFilter(project='postal', branch='master'),
        treeStableTimer=None,
        builderNames=["postal-builder"]),
    schedulers.ForceScheduler(
        name="postal-force",
        builderNames=["postal-builder"])
]