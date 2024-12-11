# msptest

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="msptest",description="msptest source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/msptest',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/msptest"),
        project="msptest",
        only_tags=True,
        pollInterval=60  # Poll every minute
    )
]

msptest_factory = util.BuildFactory()
msptest_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/msptest',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/msptest"),
    name="Git Pull Latest msptest Code",
    haltOnFailure=True
))
msptest_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/msptest"),
    property="msptest_latest_tag",
    name="Fetch Latest msptest Tag",
    haltOnFailure=True
))
msptest_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('msptest_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/msptest"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
msptest_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/msptest/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('msptest_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/msptest"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="msptest-builder", workernames=["worker1"], factory=msptest_factory, project="msptest")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="msptest-releases",
        change_filter=util.ChangeFilter(project='msptest'),
        treeStableTimer=None,
        builderNames=["msptest-builder"]),
    schedulers.ForceScheduler(
        name="msptest-force",
        builderNames=["msptest-builder"])
]