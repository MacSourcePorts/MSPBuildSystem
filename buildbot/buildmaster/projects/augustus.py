# augustus

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="augustus",description="augustus source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Keriew/augustus',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/augustus"),
        project="augustus",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

augustus_factory = util.BuildFactory()
augustus_factory.addStep(steps.Git(
    repourl='https://github.com/Keriew/augustus',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/augustus"),
    name="Git Pull Latest augustus Code",   
    haltOnFailure=True
))
augustus_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/augustus"),
    property="augustus_latest_tag",
    name="Fetch Latest augustus Tag",
    haltOnFailure=True
))
augustus_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('augustus_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/augustus"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
augustus_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/augustus/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('augustus_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/augustus"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="augustus-builder", workernames=["worker1"], factory=augustus_factory, project="augustus")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="augustus-releases",
        change_filter=util.ChangeFilter(project='augustus'),
        treeStableTimer=None,
        builderNames=["augustus-builder"]),
    schedulers.ForceScheduler(
        name="augustus-force",
        builderNames=["augustus-builder"])
]