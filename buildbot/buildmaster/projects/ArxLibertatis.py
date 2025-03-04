# ArxLibertatis

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="ArxLibertatis",description="ArxLibertatis source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/arx/ArxLibertatis',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/ArxLibertatis"),
        project="ArxLibertatis",
        only_tags=True,
        branch=None,
        pollInterval=3600  # Poll every hour
    )
]

ArxLibertatis_factory = util.BuildFactory()
ArxLibertatis_factory.addStep(steps.Git(
    repourl='https://github.com/arx/ArxLibertatis',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ArxLibertatis"),
    name="Git Pull Latest ArxLibertatis Code",   
    haltOnFailure=True
))
ArxLibertatis_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ArxLibertatis"),
    property="ArxLibertatis_latest_tag",
    name="Fetch Latest ArxLibertatis Tag",
    haltOnFailure=True
))
ArxLibertatis_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('ArxLibertatis_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ArxLibertatis"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
ArxLibertatis_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ArxLibertatis/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('ArxLibertatis_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ArxLibertatis"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="ArxLibertatis-builder", workernames=["worker1"], factory=ArxLibertatis_factory, project="ArxLibertatis")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="ArxLibertatis-releases",
        change_filter=util.ChangeFilter(project='ArxLibertatis'),
        treeStableTimer=60,
        builderNames=["ArxLibertatis-builder"]),
    schedulers.ForceScheduler(
        name="ArxLibertatis-force",
        builderNames=["ArxLibertatis-builder"])
]