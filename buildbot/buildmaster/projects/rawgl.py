# rawgl

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="rawgl",description="rawgl source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/rawgl',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/rawgl"),
        project="rawgl",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

rawgl_factory = util.BuildFactory()
rawgl_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/rawgl',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rawgl"),
    name="Git Pull Latest rawgl Code",
    haltOnFailure=True
))
rawgl_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rawgl"),
    property="rawgl_latest_tag",
    name="Fetch Latest rawgl Tag",
    haltOnFailure=True
))
# rawgl_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('rawgl_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rawgl"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True
# ))
rawgl_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/rawgl/macsourceports_universal2.sh"), "notarize", "0.2.1"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/rawgl"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="rawgl-builder", workernames=["worker1"], factory=rawgl_factory, project="rawgl")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="rawgl-releases",
        change_filter=util.ChangeFilter(project='rawgl'),
        treeStableTimer=None,
        builderNames=["rawgl-builder"]),
    schedulers.ForceScheduler(
        name="rawgl-force",
        builderNames=["rawgl-builder"])
]