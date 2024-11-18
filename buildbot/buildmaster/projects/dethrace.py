# dethrace

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="dethrace",description="dethrace source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/dethrace-labs/dethrace',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/dethrace"),
        project="dethrace",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

dethrace_factory = util.BuildFactory()
dethrace_factory.addStep(steps.Git(
    repourl='https://github.com/dethrace-labs/dethrace',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dethrace"),
    name="Git Pull Latest dethrace Code",
    haltOnFailure=True
))

dethrace_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dethrace"),
    property="dethrace_latest_tag",
    name="Fetch Latest dethrace Tag",
    haltOnFailure=True
))
dethrace_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('dethrace_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dethrace"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
dethrace_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dethrace/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('dethrace_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dethrace"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="dethrace-builder", workernames=["worker1"], factory=dethrace_factory, project="dethrace")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="dethrace-changes",
        change_filter=util.ChangeFilter(project='dethrace', branch='main'),
        treeStableTimer=None,
        builderNames=["dethrace-builder"]),
    schedulers.ForceScheduler(
        name="dethrace-force",
        builderNames=["dethrace-builder"])
]