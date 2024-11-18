# iortcw

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="iortcw",description="iortcw source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/iortcw/iortcw',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/iortcw"),
        project="iortcw",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

iortcw_factory = util.BuildFactory()
iortcw_factory.addStep(steps.Git(
    repourl='https://github.com/iortcw/iortcw',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/iortcw"),
    name="Git Pull Latest iortcw Code",
    haltOnFailure=True
))
iortcw_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/iortcw/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/iortcw"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="iortcw-builder", workernames=["worker1"], factory=iortcw_factory, project="iortcw")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="iortcw-changes",
        change_filter=util.ChangeFilter(project='iortcw', branch='master'),
        treeStableTimer=None,
        builderNames=["iortcw-builder"]),
    schedulers.ForceScheduler(
        name="iortcw-force",
        builderNames=["iortcw-builder"])
]