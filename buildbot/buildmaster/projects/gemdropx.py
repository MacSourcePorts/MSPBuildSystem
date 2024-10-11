# gemdropx

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="gemdropx",description="gemdropx source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/gemdropx',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/gemdropx"),
        project="gemdropx",
        branches=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

gemdropx_factory = util.BuildFactory()
gemdropx_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/gemdropx',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/gemdropx"),
    name="Git Pull Latest gemdropx Code",
    haltOnFailure=True
))
gemdropx_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/gemdropx/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/gemdropx"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="gemdropx-builder", workernames=["worker1"], factory=gemdropx_factory, project="gemdropx")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="gemdropx-changes",
        change_filter=util.ChangeFilter(project='gemdropx', branch='master'),
        treeStableTimer=None,
        builderNames=["gemdropx-builder"]),
    schedulers.ForceScheduler(
        name="gemdropx-force",
        builderNames=["gemdropx-builder"])
]