# wrathplaces

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="wrathplaces",description="wrathplaces source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/wrathplaces',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/wrathplaces"),
        project="wrathplaces",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

wrathplaces_factory = util.BuildFactory()
wrathplaces_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/wrathplaces',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/wrathplaces"),
    name="Git Pull Latest wrathplaces Code",
    haltOnFailure=True
))
wrathplaces_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/wrathplaces/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/wrathplaces"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="wrathplaces-builder", workernames=["worker1"], factory=wrathplaces_factory, project="wrathplaces")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="wrathplaces-changes",
        change_filter=util.ChangeFilter(project='wrathplaces', branch='master'),
        treeStableTimer=None,
        builderNames=["wrathplaces-builder"]),
    schedulers.ForceScheduler(
        name="wrathplaces-force",
        builderNames=["wrathplaces-builder"])
]