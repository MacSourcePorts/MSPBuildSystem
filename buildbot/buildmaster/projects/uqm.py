# uqm (The Ur-Quan Masters)

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="uqm",description="uqm source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/uqm',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/uqm"),
    #     project="uqm",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

uqm_factory = util.BuildFactory()
uqm_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/uqm',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/uqm"),
    name="Git Pull Latest uqm Code",
    haltOnFailure=True
))
uqm_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/uqm/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/uqm"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="uqm-builder", workernames=["worker1"], factory=uqm_factory, project="uqm")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="uqm-changes",
    #     change_filter=util.ChangeFilter(project='uqm', branch='main'),
    #     treeStableTimer=None,
    #     builderNames=["uqm-builder"]),
    schedulers.ForceScheduler(
        name="uqm-force",
        builderNames=["uqm-builder"])
]