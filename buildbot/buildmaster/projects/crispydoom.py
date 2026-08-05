# crispy-doom

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="crispy-doom",description="crispy-doom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/fabiangreffrath/crispy-doom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/crispy-doom"),
        project="crispy-doom",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

crispydoom_factory = util.BuildFactory()
crispydoom_factory.addStep(steps.Git(
    repourl='https://github.com/fabiangreffrath/crispy-doom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/crispy-doom"),
    name="Git Pull Latest crispy-doom Code",
    haltOnFailure=True
))
crispydoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/crispy-doom"),
    property="crispydoom_latest_tag",
    name="Fetch Latest crispy-doom Tag",
    haltOnFailure=True
))
crispydoom_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('crispydoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/crispy-doom"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
crispydoom_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/crispy-doom/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('crispydoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/crispy-doom"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="crispy-doom-builder", workernames=["worker1"], factory=crispydoom_factory, project="crispy-doom")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="crispy-doom-releases",
        change_filter=util.ChangeFilter(project='crispy-doom'),
        treeStableTimer=None,
        builderNames=["crispy-doom-builder"]),
    schedulers.ForceScheduler(
        name="crispy-doom-force",
        builderNames=["crispy-doom-builder"])
]