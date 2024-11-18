# NakedAVP

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="NakedAVP",description="NakedAVP source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/atsb/NakedAVP',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/NakedAVP"),
        project="NakedAVP",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

NakedAVP_factory = util.BuildFactory()
NakedAVP_factory.addStep(steps.Git(
    repourl='https://github.com/atsb/NakedAVP',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedAVP"),
    name="Git Pull Latest NakedAVP Code",
    haltOnFailure=True
))
NakedAVP_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedAVP"),
    property="NakedAVP_latest_tag",
    name="Fetch Latest NakedAVP Tag",
    haltOnFailure=True
))
NakedAVP_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('NakedAVP_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedAVP"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
NakedAVP_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/NakedAVP/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('NakedAVP_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/NakedAVP"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="NakedAVP-builder", workernames=["worker1"], factory=NakedAVP_factory, project="NakedAVP")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="NakedAVP-changes",
        change_filter=util.ChangeFilter(project='NakedAVP', branch='main'),
        treeStableTimer=None,
        builderNames=["NakedAVP-builder"]),
    schedulers.ForceScheduler(
        name="NakedAVP-force",
        builderNames=["NakedAVP-builder"])
]