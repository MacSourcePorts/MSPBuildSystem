# texview

# Project where we build based the latest code

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="texview",description="texview utility project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/DanielGibson/texview',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/texview"),
        project="texview",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

texview_factory = util.BuildFactory()
texview_factory.addStep(steps.Git(
    repourl='https://github.com/DanielGibson/texview',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/texview"),
    name="Git Pull Latest texview Code",
    haltOnFailure=True
))
texview_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/texview/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/texview"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="texview-builder", workernames=["worker1"], factory=texview_factory, project="texview")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="texview-changes",
        change_filter=util.ChangeFilter(project='texview', branch='master'),
        treeStableTimer=None,
        builderNames=["texview-builder"]),
    schedulers.ForceScheduler(
        name="texview-force",
        builderNames=["texview-builder"])
]