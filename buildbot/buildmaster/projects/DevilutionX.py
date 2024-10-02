# DevilutionX

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="DevilutionX",description="DevilutionX source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/diasurgical/devilutionX',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/DevilutionX"),
        project="DevilutionX",
        only_tags=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

DevilutionX_factory = util.BuildFactory()
DevilutionX_factory.addStep(steps.Git(
    repourl='https://github.com/diasurgical/devilutionX',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/DevilutionX"),
    name="Git Pull Latest DevilutionX Code",
    haltOnFailure=True
))
DevilutionX_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/DevilutionX"),
    property="DevilutionX_latest_tag",
    name="Fetch Latest DevilutionX Tag",
    haltOnFailure=True
))
DevilutionX_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('DevilutionX_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/DevilutionX"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
DevilutionX_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/DevilutionX/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('DevilutionX_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/DevilutionX"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="DevilutionX-builder", workernames=["worker1"], factory=DevilutionX_factory, project="DevilutionX")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="DevilutionX-changes",
        change_filter=util.ChangeFilter(project='DevilutionX', branch='master'),
        treeStableTimer=None,
        builderNames=["DevilutionX-builder"]),
    schedulers.ForceScheduler(
        name="DevilutionX-force",
        builderNames=["DevilutionX-builder"])
]