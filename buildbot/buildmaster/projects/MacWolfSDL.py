# MacWolfSDL

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="MacWolfSDL",description="MacWolfSDL source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/LateGator/MacWolfSDL',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/MacWolfSDL"),
        project="MacWolfSDL",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

MacWolfSDL_factory = util.BuildFactory()
MacWolfSDL_factory.addStep(steps.Git(
    repourl='https://github.com/LateGator/MacWolfSDL',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MacWolfSDL"),
    name="Git Pull Latest MacWolfSDL Code",
    haltOnFailure=True
))
MacWolfSDL_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MacWolfSDL"),
    property="MacWolfSDL_latest_tag",
    name="Fetch Latest MacWolfSDL Tag",
    haltOnFailure=True
))
MacWolfSDL_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('MacWolfSDL_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MacWolfSDL"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
MacWolfSDL_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/MacWolfSDL/macsourceports_universal2.sh"), "notarize", util.Property('MacWolfSDL_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/MacWolfSDL"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="MacWolfSDL-builder", workernames=["worker1"], factory=MacWolfSDL_factory, project="MacWolfSDL")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="MacWolfSDL-releases",
        change_filter=util.ChangeFilter(project='MacWolfSDL'),
        treeStableTimer=None,
        builderNames=["MacWolfSDL-builder"]),
    schedulers.ForceScheduler(
        name="MacWolfSDL-force",
        builderNames=["MacWolfSDL-builder"])
]