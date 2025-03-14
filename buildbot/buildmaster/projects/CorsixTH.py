# CorsixTH

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="CorsixTH",description="CorsixTH source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/CorsixTH/CorsixTH',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/CorsixTH"),
        project="CorsixTH",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

CorsixTH_factory = util.BuildFactory()
CorsixTH_factory.addStep(steps.Git(
    repourl='https://github.com/CorsixTH/CorsixTH',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/CorsixTH"),
    name="Git Pull Latest CorsixTH Code",
    haltOnFailure=True
))
CorsixTH_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/CorsixTH"),
    property="CorsixTH_latest_tag",
    name="Fetch Latest CorsixTH Tag",
    haltOnFailure=True
))
CorsixTH_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('CorsixTH_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/CorsixTH"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
CorsixTH_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/CorsixTH/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('CorsixTH_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/CorsixTH"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="CorsixTH-builder", workernames=["worker1"], factory=CorsixTH_factory, project="CorsixTH")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="CorsixTH-releases",
        change_filter=util.ChangeFilter(project='CorsixTH'),
        treeStableTimer=None,
        builderNames=["CorsixTH-builder"]),
    schedulers.ForceScheduler(
        name="CorsixTH-force",
        builderNames=["CorsixTH-builder"])
]