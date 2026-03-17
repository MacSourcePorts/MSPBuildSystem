# PvZ-Portable

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="PvZ-Portable",description="PvZ-Portable source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/PvZ-Portable',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/PvZ-Portable"),
        project="PvZ-Portable",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

PvZPortable_factory = util.BuildFactory()
PvZPortable_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/PvZ-Portable',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/PvZ-Portable"),
    name="Git Pull Latest PvZ-Portable Code",
    haltOnFailure=True
))
PvZPortable_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/PvZ-Portable"),
    property="PvZPortable_latest_tag",
    name="Fetch Latest PvZ-Portable Tag",
    haltOnFailure=True
))
# PvZPortable_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('PvZPortable_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/PvZ-Portable"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True
# ))
PvZPortable_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/PvZ-Portable/macsourceports_universal2.sh"), "notarize", "buildserver", "0.1.16"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/PvZ-Portable"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="PvZ-Portable-builder", workernames=["worker1"], factory=PvZPortable_factory, project="PvZ-Portable")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="PvZ-Portable-releases",
        change_filter=util.ChangeFilter(project='PvZ-Portable'),
        treeStableTimer=None,
        builderNames=["PvZ-Portable-builder"]),
    schedulers.ForceScheduler(
        name="PvZ-Portable-force",
        builderNames=["PvZ-Portable-builder"])
]