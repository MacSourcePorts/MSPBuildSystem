# OpenJKDF2

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenJKDF2",description="OpenJKDF2 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/shinyquagsire23/OpenJKDF2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenJKDF2"),
        project="OpenJKDF2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenJKDF2_factory = util.BuildFactory()
OpenJKDF2_factory.addStep(steps.Git(
    repourl='https://github.com/shinyquagsire23/OpenJKDF2',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJKDF2"),
    name="Git Pull Latest OpenJKDF2 Code",
    haltOnFailure=True
))
OpenJKDF2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJKDF2"),
    property="OpenJKDF2_latest_tag",
    name="Fetch Latest OpenJKDF2 Tag",
    haltOnFailure=True
))
OpenJKDF2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenJKDF2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJKDF2"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
OpenJKDF2_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJKDF2/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('OpenJKDF2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJKDF2"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenJKDF2-builder", workernames=["worker1"], factory=OpenJKDF2_factory, project="OpenJKDF2")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenJKDF2-changes",
        change_filter=util.ChangeFilter(project='OpenJKDF2', branch='master'),
        treeStableTimer=None,
        builderNames=["OpenJKDF2-builder"]),
    schedulers.ForceScheduler(
        name="OpenJKDF2-force",
        builderNames=["OpenJKDF2-builder"])
]