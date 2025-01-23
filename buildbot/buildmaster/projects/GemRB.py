# GemRB

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="GemRB",description="GemRB source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/gemrb/gemrb',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/GemRB"),
        project="GemRB",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

GemRB_factory = util.BuildFactory()
GemRB_factory.addStep(steps.Git(
    repourl='https://github.com/gemrb/gemrb',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GemRB"),
    name="Git Pull Latest GemRB Code",
    haltOnFailure=True
))
GemRB_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GemRB"),
    property="GemRB_latest_tag",
    name="Fetch Latest GemRB Tag",
    haltOnFailure=True
))
GemRB_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('GemRB_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GemRB"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
GemRB_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/GemRB/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('GemRB_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/GemRB"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="GemRB-builder", workernames=["worker1"], factory=GemRB_factory, project="GemRB")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="GemRB-releases",
        change_filter=util.ChangeFilter(project='GemRB'),
        treeStableTimer=None,
        builderNames=["GemRB-builder"]),
    schedulers.ForceScheduler(
        name="GemRB-force",
        builderNames=["GemRB-builder"])
]