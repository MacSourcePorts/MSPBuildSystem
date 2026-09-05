# 1oom

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="moo1",description="1oom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/1oom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/1oom"),
        project="moo1",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

moo1_factory = util.BuildFactory()
moo1_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/1oom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/1oom"),
    name="Git Pull Latest 1oom Code",
    branch="master-vanilla-beta",
    haltOnFailure=True
))
moo1_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/1oom"),
    property="moo1_latest_tag",
    name="Fetch Latest 1oom Tag",
    haltOnFailure=True
))
moo1_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", "master-vanilla-beta"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/1oom"),
    name="Checkout master-vanilla-beta",
    haltOnFailure=True
))
moo1_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/1oom/macsourceports_universal2.sh"), "notarize", "1.11.7"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/1oom"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="moo1-builder", workernames=["worker1"], factory=moo1_factory, project="moo1")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="moo1-releases",
        change_filter=util.ChangeFilter(project='moo1', branch='master-vanilla-beta'),
        treeStableTimer=None,
        builderNames=["moo1-builder"]),
    schedulers.ForceScheduler(
        name="moo1-force",
        builderNames=["moo1-builder"])
]