# RigelEngine

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="RigelEngine",description="RigelEngine source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/lethal-guitar/RigelEngine',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/RigelEngine"),
        project="RigelEngine",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

RigelEngine_factory = util.BuildFactory()
RigelEngine_factory.addStep(steps.Git(
    repourl='https://github.com/lethal-guitar/RigelEngine',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/RigelEngine"),
    name="Git Pull Latest RigelEngine Code",
    haltOnFailure=True
))
RigelEngine_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/RigelEngine/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/RigelEngine"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="RigelEngine-builder", workernames=["worker1"], factory=RigelEngine_factory, project="RigelEngine")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="RigelEngine-changes",
        change_filter=util.ChangeFilter(project='RigelEngine', branch='master'),
        treeStableTimer=None,
        builderNames=["RigelEngine-builder"]),
    schedulers.ForceScheduler(
        name="RigelEngine-force",
        builderNames=["RigelEngine-builder"])
]