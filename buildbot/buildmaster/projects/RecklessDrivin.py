# RecklessDrivin

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="RecklessDrivin",description="RecklessDrivin source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/DarrCoh/reckless-drivin-sdl',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/reckless-drivin-sdl"),
        project="RecklessDrivin",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

RecklessDrivin_factory = util.BuildFactory()
RecklessDrivin_factory.addStep(steps.Git(
    repourl='https://github.com/DarrCoh/reckless-drivin-sdl',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/reckless-drivin-sdl"),
    name="Git Pull Latest RecklessDrivin Code",
    haltOnFailure=True
))
RecklessDrivin_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/reckless-drivin-sdl"),
    property="RecklessDrivin_latest_tag",
    name="Fetch Latest RecklessDrivin Tag",
    haltOnFailure=True
))
RecklessDrivin_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('RecklessDrivin_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/reckless-drivin-sdl"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
RecklessDrivin_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/reckless-drivin-sdl/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('RecklessDrivin_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/reckless-drivin-sdl"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="RecklessDrivin-builder", workernames=["worker1"], factory=RecklessDrivin_factory, project="RecklessDrivin")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="RecklessDrivin-releases",
        change_filter=util.ChangeFilter(project='RecklessDrivin'),
        treeStableTimer=None,
        builderNames=["RecklessDrivin-builder"]),
    schedulers.ForceScheduler(
        name="RecklessDrivin-force",
        builderNames=["RecklessDrivin-builder"])
]