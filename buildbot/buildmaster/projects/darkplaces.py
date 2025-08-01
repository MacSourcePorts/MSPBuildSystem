# darkplaces

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="darkplaces",description="darkplaces source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/DarkPlacesEngine/DarkPlaces',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/darkplaces"),
        project="darkplaces",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

darkplaces_factory = util.BuildFactory()
darkplaces_factory.addStep(steps.Git(
    repourl='https://github.com/DarkPlacesEngine/DarkPlaces',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/darkplaces"),
    name="Git Pull Latest darkplaces Code",
    haltOnFailure=True
))
darkplaces_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/darkplaces/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/darkplaces"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="darkplaces-builder", workernames=["worker1"], factory=darkplaces_factory, project="darkplaces")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="darkplaces-changes",
        change_filter=util.ChangeFilter(project='darkplaces', branch='master'),
        treeStableTimer=None,
        builderNames=["darkplaces-builder"]),
    schedulers.ForceScheduler(
        name="darkplaces-force",
        builderNames=["darkplaces-builder"])
]