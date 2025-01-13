# OpenGothic

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenGothic",description="OpenGothic source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Try/OpenGothic',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenGothic"),
        project="OpenGothic",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenGothic_factory = util.BuildFactory()
OpenGothic_factory.addStep(steps.Git(
    repourl='https://github.com/Try/OpenGothic',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenGothic"),
    name="Git Pull Latest OpenGothic Code",
    haltOnFailure=True
))
OpenGothic_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenGothic"),
    property="OpenGothic_latest_tag",
    name="Fetch Latest OpenGothic Tag",
    haltOnFailure=True
))
OpenGothic_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('OpenGothic_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenGothic"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
OpenGothic_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenGothic/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('OpenGothic_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenGothic"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenGothic-builder", workernames=["worker1"], factory=OpenGothic_factory, project="OpenGothic")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="OpenGothic-changes",
        change_filter=util.ChangeFilter(project='OpenGothic'),
        treeStableTimer=None,
        builderNames=["OpenGothic-builder"]),
    schedulers.ForceScheduler(
        name="OpenGothic-force",
        builderNames=["OpenGothic-builder"])
]