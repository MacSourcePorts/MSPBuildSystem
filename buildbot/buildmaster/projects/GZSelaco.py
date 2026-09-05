# GZSelaco

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="GZSelaco",description="GZSelaco source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/CrowEater/GZSelaco',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/GZSelaco"),
        project="GZSelaco",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

GZSelaco_factory = util.BuildFactory()
GZSelaco_factory.addStep(steps.Git(
    repourl='https://github.com/CrowEater/GZSelaco',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GZSelaco"),
    name="Git Pull Latest GZSelaco Code",
    haltOnFailure=True,
    submodules=True
))
GZSelaco_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GZSelaco"),
    property="GZSelaco_latest_tag",
    name="Fetch Latest GZSelaco Tag",
    haltOnFailure=True
))
GZSelaco_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('GZSelaco_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GZSelaco"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))

GZSelaco_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/GZSelaco/macsourceports_universal2.sh"), "notarize", util.Property('GZSelaco_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/GZSelaco"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="GZSelaco-builder", workernames=["worker1"], factory=GZSelaco_factory, project="GZSelaco")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="GZSelaco-changes",
        change_filter=util.ChangeFilter(project='GZSelaco', branch='main'),
        treeStableTimer=None,
        builderNames=["GZSelaco-builder"]),
    schedulers.ForceScheduler(
        name="GZSelaco-force",
        builderNames=["GZSelaco-builder"])
]