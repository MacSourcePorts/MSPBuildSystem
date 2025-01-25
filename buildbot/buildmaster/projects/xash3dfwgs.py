# xash3dfwgs

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="xash3d-fwgs",description="xash3d-fwgs source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/FWGS/xash3d-fwgs',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/xash3d-fwgs"),
        project="xash3d-fwgs",
        branches=True,
        pollInterval=3600  # Poll every hour
    ),
    changes.GitPoller(
        repourl='https://github.com/FWGS/hlsdk-portable',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/xash3d-fwgs/hlsdk-portable"),
        project="xash3d-fwgs",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

xash3dfwgs_factory = util.BuildFactory()
xash3dfwgs_factory.addStep(steps.Git(
    repourl='https://github.com/FWGS/xash3d-fwgs',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xash3d-fwgs"),
    name="Git Pull Latest xash3d-fwgs Code",
    haltOnFailure=True
))
xash3dfwgs_factory.addStep(steps.Git(
    repourl='https://github.com/FWGS/hlsdk-portable',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/hlsdk-portable"),
    name="Git Pull Latest hlsdk-portable Code",
    haltOnFailure=True
))

xash3dfwgs_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/xash3d-fwgs/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/xash3d-fwgs"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="xash3d-fwgs-builder", workernames=["worker1"], factory=xash3dfwgs_factory, project="xash3d-fwgs")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="xash3d-fwgs-releases",
        change_filter=util.ChangeFilter(project='xash3d-fwgs', branch='master'),
        treeStableTimer=None,
        builderNames=["xash3d-fwgs-builder"]),
    schedulers.ForceScheduler(
        name="xash3d-fwgs-force",
        builderNames=["xash3d-fwgs-builder"])
]