# dhewm3

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="dhewm3",description="dhewm3 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/dhewm/dhewm3',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/dhewm3"),
        project="dhewm3",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

dhewm3_factory = util.BuildFactory()
dhewm3_factory.addStep(steps.Git(
    repourl='https://github.com/dhewm/dhewm3',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dhewm3"),
    name="Git Pull Latest dhewm3 Code",
    haltOnFailure=True
))
dhewm3_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dhewm3"),
    property="dhewm3_latest_tag",
    name="Fetch Latest dhewm3 Tag",
    haltOnFailure=True
))
dhewm3_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('dhewm3_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dhewm3"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
dhewm3_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dhewm3/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('dhewm3_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dhewm3"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="dhewm3-builder", workernames=["worker1"], factory=dhewm3_factory, project="dhewm3")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="dhewm3-changes",
        change_filter=util.ChangeFilter(project='dhewm3', branch='master'),
        treeStableTimer=None,
        builderNames=["dhewm3-builder"]),
    schedulers.ForceScheduler(
        name="dhewm3-force",
        builderNames=["dhewm3-builder"])
]