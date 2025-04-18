# OpenEnroth

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenEnroth",description="OpenEnroth source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/OpenEnroth/OpenEnroth',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenEnroth"),
        project="OpenEnroth",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenEnroth_factory = util.BuildFactory()
OpenEnroth_factory.addStep(steps.Git(
    repourl='https://github.com/OpenEnroth/OpenEnroth',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenEnroth"),
    name="Git Pull Latest OpenEnroth Code",
    haltOnFailure=True
))
OpenEnroth_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenEnroth/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenEnroth"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenEnroth-builder", workernames=["worker1"], factory=OpenEnroth_factory, project="OpenEnroth")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenEnroth-changes",
        change_filter=util.ChangeFilter(project='OpenEnroth', branch='master'),
        treeStableTimer=None,
        builderNames=["OpenEnroth-builder"]),
    schedulers.ForceScheduler(
        name="OpenEnroth-force",
        builderNames=["OpenEnroth-builder"])
]