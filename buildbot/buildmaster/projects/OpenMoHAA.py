# OpenMoHAA 

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenMoHAA",description="OpenMoHAA source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/openmoh/openmohaa',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenMoHAA"),
        project="OpenMoHAA",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenMoHAA_factory = util.BuildFactory()
OpenMoHAA_factory.addStep(steps.Git(
    repourl='https://github.com/openmoh/openmohaa',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenMoHAA"),
    name="Git Pull Latest OpenMoHAA Code",
    haltOnFailure=True,
    submodules=True
))
OpenMoHAA_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenMoHAA"),
    property="OpenMoHAA_latest_tag",
    name="Fetch Latest OpenMoHAA Tag",
    haltOnFailure=True
))
OpenMoHAA_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenMoHAA_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenMoHAA"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
OpenMoHAA_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenMoHAA/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('OpenMoHAA_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenMoHAA"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenMoHAA-builder", workernames=["worker1"], factory=OpenMoHAA_factory, project="OpenMoHAA")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenMoHAA-releases",
        change_filter=util.ChangeFilter(project='OpenMoHAA', branch='main'),
        treeStableTimer=None,
        builderNames=["OpenMoHAA-builder"]),
    schedulers.ForceScheduler(
        name="OpenMoHAA-force",
        builderNames=["OpenMoHAA-builder"])
]