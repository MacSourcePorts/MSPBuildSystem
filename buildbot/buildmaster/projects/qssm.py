# QSS-M

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="qssm",description="QSS-M source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/timbergeron/QSS-M.git',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/QSS-M"),
        project="qssm",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

qssm_factory = util.BuildFactory()
qssm_factory.addStep(steps.Git(
    repourl='https://github.com/timbergeron/QSS-M.git',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/QSS-M"),
    name="Git Pull Latest QSS-M Code",
    haltOnFailure=True
))
qssm_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/QSS-M"),
    property="qssm_latest_tag",
    name="Fetch Latest QSS-M Tag",
    haltOnFailure=True
))
qssm_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('qssm_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/QSS-M"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
qssm_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/QSS-M/macsourceports_universal2.sh"), "notarize", util.Property('qssm_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/QSS-M"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="qssm-builder", workernames=["worker1"], factory=qssm_factory, project="qssm")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="qssm-changes",
        change_filter=util.ChangeFilter(project='qssm', branch='stable'),
        treeStableTimer=None,
        builderNames=["qssm-builder"]),
    schedulers.ForceScheduler(
        name="qssm-force",
        builderNames=["qssm-builder"])
]