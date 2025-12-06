# TheForceEngine

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="TheForceEngine",description="TheForceEngine source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/TheForceEngine',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/TheForceEngine"),
        project="TheForceEngine",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

TheForceEngine_factory = util.BuildFactory()
TheForceEngine_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/TheForceEngine',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TheForceEngine"),
    name="Git Pull Latest TheForceEngine Code",
    haltOnFailure=True
))
TheForceEngine_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TheForceEngine"),
    property="TheForceEngine_latest_tag",
    name="Fetch Latest TheForceEngine Tag",
    haltOnFailure=True
))
# TheForceEngine_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('TheForceEngine_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TheForceEngine"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True
# ))
TheForceEngine_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/TheForceEngine/macsourceports_universal2.sh"), "notarize", "buildserver", "1.22.420"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/TheForceEngine"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="TheForceEngine-builder", workernames=["worker1"], factory=TheForceEngine_factory, project="TheForceEngine")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="TheForceEngine-releases",
        change_filter=util.ChangeFilter(project='TheForceEngine'),
        treeStableTimer=None,
        builderNames=["TheForceEngine-builder"]),
    schedulers.ForceScheduler(
        name="TheForceEngine-force",
        builderNames=["TheForceEngine-builder"])
]