# chocolate-quake

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="chocolate-quake",description="chocolate-quake source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Henrique194/chocolate-quake',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/chocolate-quake"),
        project="chocolate-quake",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

chocolatequake_factory = util.BuildFactory()
chocolatequake_factory.addStep(steps.Git(
    repourl='https://github.com/Henrique194/chocolate-quake',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-quake"),
    name="Git Pull Latest chocolate-quake Code",
    haltOnFailure=True
))
chocolatequake_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-quake"),
    property="chocolatequake_latest_tag",
    name="Fetch Latest chocolate-quake Tag",
    haltOnFailure=True
))
# chocolatequake_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('chocolatequake_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-quake"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True
# ))
chocolatequake_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/chocolate-quake/macsourceports_universal2.sh"), "notarize", util.Property('chocolatequake_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/chocolate-quake"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="chocolate-quake-builder", workernames=["worker1"], factory=chocolatequake_factory, project="chocolate-quake")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="chocolate-quake-releases",
        change_filter=util.ChangeFilter(project='chocolate-quake'),
        treeStableTimer=None,
        builderNames=["chocolate-quake-builder"]),
    schedulers.ForceScheduler(
        name="chocolate-quake-force",
        builderNames=["chocolate-quake-builder"])
]