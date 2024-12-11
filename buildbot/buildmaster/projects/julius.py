# julius

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="julius",description="julius source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/bvschaik/julius',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/julius"),
        project="julius",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

julius_factory = util.BuildFactory()
julius_factory.addStep(steps.Git(
    repourl='https://github.com/bvschaik/julius',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/julius"),
    name="Git Pull Latest julius Code",   
    haltOnFailure=True
))
julius_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/julius"),
    property="julius_latest_tag",
    name="Fetch Latest julius Tag",
    haltOnFailure=True
))
julius_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('julius_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/julius"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
julius_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/julius/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('julius_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/julius"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="julius-builder", workernames=["worker1"], factory=julius_factory, project="julius")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="julius-releases",
        change_filter=util.ChangeFilter(project='julius'),
        treeStableTimer=None,
        builderNames=["julius-builder"]),
    schedulers.ForceScheduler(
        name="julius-force",
        builderNames=["julius-builder"])
]