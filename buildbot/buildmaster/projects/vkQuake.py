# vkQuake

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="vkQuake",description="vkQuake source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Novum/vkQuake',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/vkQuake"),
        project="vkQuake",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

vkQuake_factory = util.BuildFactory()
vkQuake_factory.addStep(steps.Git(
    repourl='https://github.com/Novum/vkQuake',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vkQuake"),
    name="Git Pull Latest vkQuake Code",
    haltOnFailure=True
))
vkQuake_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vkQuake"),
    property="vkQuake_latest_tag",
    name="Fetch Latest vkQuake Tag",
    haltOnFailure=True
))
vkQuake_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('vkQuake_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vkQuake"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
vkQuake_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/vkQuake/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('vkQuake_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/vkQuake"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="vkQuake-builder", workernames=["worker1"], factory=vkQuake_factory, project="vkQuake")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="vkQuake-releases",
        change_filter=util.ChangeFilter(project='vkQuake'),
        treeStableTimer=None,
        builderNames=["vkQuake-builder"]),
    schedulers.ForceScheduler(
        name="vkQuake-force",
        builderNames=["vkQuake-builder"])
]