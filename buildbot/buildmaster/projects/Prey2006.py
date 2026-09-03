# Prey2006

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Prey2006",description="Prey2006 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/Prey2006',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Prey2006"),
        project="Prey2006",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

Prey2006_factory = util.BuildFactory()
Prey2006_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/Prey2006',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Prey2006"),
    name="Git Pull Latest Prey2006 Code",
    haltOnFailure=True
))
# Prey2006_factory.addStep(steps.SetPropertyFromCommand(
#     command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Prey2006"),
#     property="Prey2006_latest_tag",
#     name="Fetch Latest Prey2006 Tag",
#     haltOnFailure=True
# ))
# Prey2006_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('Prey2006_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Prey2006"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True
# ))
Prey2006_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Prey2006/macsourceports_universal2.sh"), "notarize", "buildserver", "1.5.4"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Prey2006"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Prey2006-builder", workernames=["worker1"], factory=Prey2006_factory, project="Prey2006")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Prey2006-releases",
        change_filter=util.ChangeFilter(project='Prey2006'),
        treeStableTimer=None,
        builderNames=["Prey2006-builder"]),
    schedulers.ForceScheduler(
        name="Prey2006-force",
        builderNames=["Prey2006-builder"])
]