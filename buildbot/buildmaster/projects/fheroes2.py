# fheroes2

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="fheroes2",description="fheroes2 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/ihhub/fheroes2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/fheroes2"),
        project="fheroes2",
        only_tags=True,
        branch=None,
        pollInterval=3600  # Poll every hour
    )
]

fheroes2_factory = util.BuildFactory()
fheroes2_factory.addStep(steps.Git(
    repourl='https://github.com/ihhub/fheroes2',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/fheroes2"),
    name="Git Pull Latest fheroes2 Code",   
    haltOnFailure=True
))
fheroes2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/fheroes2"),
    property="fheroes2_latest_tag",
    name="Fetch Latest fheroes2 Tag",
    haltOnFailure=True
))
fheroes2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('fheroes2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/fheroes2"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
fheroes2_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/fheroes2/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('fheroes2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/fheroes2"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="fheroes2-builder", workernames=["worker1"], factory=fheroes2_factory, project="fheroes2")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="fheroes2-releases",
        change_filter=util.ChangeFilter(project='fheroes2'),
        treeStableTimer=60,
        builderNames=["fheroes2-builder"]),
    schedulers.ForceScheduler(
        name="fheroes2-force",
        builderNames=["fheroes2-builder"])
]