# Akhenaten

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Akhenaten",description="Akhenaten source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/dalerank/Akhenaten',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Akhenaten"),
        project="Akhenaten",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

Akhenaten_factory = util.BuildFactory()
Akhenaten_factory.addStep(steps.Git(
    repourl='https://github.com/dalerank/Akhenaten',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Akhenaten"),
    name="Git Pull Latest Akhenaten Code",
    haltOnFailure=True
))
Akhenaten_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Akhenaten/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Akhenaten"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Akhenaten-builder", workernames=["worker1"], factory=Akhenaten_factory, project="Akhenaten")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Akhenaten-changes",
        change_filter=util.ChangeFilter(project='Akhenaten', branch='master'),
        treeStableTimer=None,
        builderNames=["Akhenaten-builder"]),
    schedulers.ForceScheduler(
        name="Akhenaten-force",
        builderNames=["Akhenaten-builder"])
]