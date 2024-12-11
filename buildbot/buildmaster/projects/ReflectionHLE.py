# ReflectionHLE

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="ReflectionHLE",description="ReflectionHLE source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/ReflectionHLE/ReflectionHLE',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/ReflectionHLE"),
        project="ReflectionHLE",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

ReflectionHLE_factory = util.BuildFactory()
ReflectionHLE_factory.addStep(steps.Git(
    repourl='https://github.com/ReflectionHLE/ReflectionHLE',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ReflectionHLE"),
    name="Git Pull Latest ReflectionHLE Code",
    haltOnFailure=True
))
ReflectionHLE_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ReflectionHLE"),
    property="ReflectionHLE_latest_tag",
    name="Fetch Latest ReflectionHLE Tag",
    haltOnFailure=True
))
ReflectionHLE_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('ReflectionHLE_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ReflectionHLE"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
ReflectionHLE_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ReflectionHLE/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('ReflectionHLE_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ReflectionHLE"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="ReflectionHLE-builder", workernames=["worker1"], factory=ReflectionHLE_factory, project="ReflectionHLE")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="ReflectionHLE-releases",
        change_filter=util.ChangeFilter(project='ReflectionHLE'),
        treeStableTimer=None,
        builderNames=["ReflectionHLE-builder"]),
    schedulers.ForceScheduler(
        name="ReflectionHLE-force",
        builderNames=["ReflectionHLE-builder"])
]