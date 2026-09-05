# Perimeter

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Perimeter",description="Perimeter source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/KD-lab-Open-Source/Perimeter',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Perimeter"),
        project="Perimeter",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

Perimeter_factory = util.BuildFactory()
Perimeter_factory.addStep(steps.Git(
    repourl='https://github.com/KD-lab-Open-Source/Perimeter',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Perimeter"),
    name="Git Pull Latest Perimeter Code",
    haltOnFailure=True
))
Perimeter_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Perimeter"),
    property="Perimeter_latest_tag",
    name="Fetch Latest Perimeter Tag",
    haltOnFailure=True
))
Perimeter_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('Perimeter_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Perimeter"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
Perimeter_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Perimeter/macsourceports_universal2.sh"), "notarize", util.Property('Perimeter_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Perimeter"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Perimeter-builder", workernames=["worker1"], factory=Perimeter_factory, project="Perimeter")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Perimeter-changes",
        change_filter=util.ChangeFilter(project='Perimeter', branch='main'),
        treeStableTimer=None,
        builderNames=["Perimeter-builder"]),
    schedulers.ForceScheduler(
        name="Perimeter-force",
        builderNames=["Perimeter-builder"])
]