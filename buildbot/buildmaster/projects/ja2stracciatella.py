# ja2stracciatella

# Project where we build based off of release tags from the project
# This one is arm64 only at this time

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="ja2stracciatella",description="ja2-stracciatella source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/ja2-stracciatella/ja2-stracciatella',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/ja2-stracciatella"),
        project="ja2stracciatella",
        only_tags=True,
        branch=None,
        pollInterval=3600  # Poll every hour
    )
]

ja2stracciatella_factory = util.BuildFactory()
ja2stracciatella_factory.addStep(steps.Git(
    repourl='https://github.com/ja2-stracciatella/ja2-stracciatella',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ja2-stracciatella"),
    name="Git Pull Latest ja2-stracciatella Code",   
    haltOnFailure=True
))
ja2stracciatella_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ja2-stracciatella"),
    property="ja2stracciatella_latest_tag",
    name="Fetch Latest ja2-stracciatella Tag",
    haltOnFailure=True
))
ja2stracciatella_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('ja2stracciatella_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ja2-stracciatella"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
ja2stracciatella_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ja2-stracciatella/macsourceports_arm64.sh"), "notarize", "buildserver", util.Property('ja2stracciatella_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ja2-stracciatella"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="ja2stracciatella-builder", workernames=["worker1"], factory=ja2stracciatella_factory, project="ja2stracciatella")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="ja2stracciatella-releases",
        change_filter=util.ChangeFilter(project='ja2stracciatella'),
        treeStableTimer=60,
        builderNames=["ja2stracciatella-builder"]),
    schedulers.ForceScheduler(
        name="ja2stracciatella-force",
        builderNames=["ja2stracciatella-builder"])
]