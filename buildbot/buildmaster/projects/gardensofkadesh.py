# gardens-of-kadesh

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="gardens-of-kadesh",description="gardens-of-kadesh source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://gitlab.com/gardens-of-kadesh/gardens-of-kadesh',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/gardens-of-kadesh"),
        project="gardens-of-kadesh",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

gardensofkadesh_factory = util.BuildFactory()
gardensofkadesh_factory.addStep(steps.Git(
    repourl='https://gitlab.com/gardens-of-kadesh/gardens-of-kadesh',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/gardens-of-kadesh"),
    name="Git Pull Latest gardens-of-kadesh Code",
    haltOnFailure=True
))
gardensofkadesh_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/gardens-of-kadesh/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/gardens-of-kadesh"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="gardens-of-kadesh-builder", workernames=["worker1"], factory=gardensofkadesh_factory, project="gardens-of-kadesh")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="gardens-of-kadesh-changes",
        change_filter=util.ChangeFilter(project='gardens-of-kadesh', branch='main'),
        treeStableTimer=None,
        builderNames=["gardens-of-kadesh-builder"]),
    schedulers.ForceScheduler(
        name="gardens-of-kadesh-force",
        builderNames=["gardens-of-kadesh-builder"])
]