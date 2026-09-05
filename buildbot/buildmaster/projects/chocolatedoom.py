# chocolate-doom

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="chocolate-doom",description="chocolate-doom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/chocolate-doom/chocolate-doom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/chocolate-doom"),
        project="chocolate-doom",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

chocolatedoom_factory = util.BuildFactory()
chocolatedoom_factory.addStep(steps.Git(
    repourl='https://github.com/chocolate-doom/chocolate-doom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-doom"),
    name="Git Pull Latest chocolate-doom Code",
    haltOnFailure=True
))
chocolatedoom_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-doom"),
    property="chocolatedoom_latest_tag",
    name="Fetch Latest chocolate-doom Tag",
    haltOnFailure=True
))
chocolatedoom_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('chocolatedoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/chocolate-doom"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
chocolatedoom_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/chocolate-doom/macsourceports_universal2.sh"), "notarize", util.Property('chocolatedoom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/chocolate-doom"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="chocolate-doom-builder", workernames=["worker1"], factory=chocolatedoom_factory, project="chocolate-doom")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="chocolate-doom-releases",
        change_filter=util.ChangeFilter(project='chocolate-doom'),
        treeStableTimer=None,
        builderNames=["chocolate-doom-builder"]),
    schedulers.ForceScheduler(
        name="chocolate-doom-force",
        builderNames=["chocolate-doom-builder"])
]