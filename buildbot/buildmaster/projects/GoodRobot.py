# GoodRobot

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="GoodRobot",description="GoodRobot source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/Good-Robot',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/GoodRobot"),
        project="GoodRobot",
        branches=True,
        pollInterval=300  # Poll every 5 minutes
    )
]

GoodRobot_factory = util.BuildFactory()
GoodRobot_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/Good-Robot',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/GoodRobot"),
    name="Git Pull Latest GoodRobot Code",
    haltOnFailure=True
))
GoodRobot_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Good-Robot/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/GoodRobot"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="GoodRobot-builder", workernames=["worker1"], factory=GoodRobot_factory, project="GoodRobot")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="GoodRobot-changes",
        change_filter=util.ChangeFilter(project='GoodRobot', branch='master'),
        treeStableTimer=None,
        builderNames=["GoodRobot-builder"]),
    schedulers.ForceScheduler(
        name="GoodRobot-force",
        builderNames=["GoodRobot-builder"])
]