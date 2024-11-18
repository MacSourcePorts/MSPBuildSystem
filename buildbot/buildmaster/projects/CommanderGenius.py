# CommanderGenius

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="CommanderGenius",description="CommanderGenius source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://gitlab.com/Dringgstein/Commander-Genius',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Commander-Genius"),
        project="CommanderGenius",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

CommanderGenius_factory = util.BuildFactory()
CommanderGenius_factory.addStep(steps.Git(
    repourl='https://gitlab.com/Dringgstein/Commander-Genius',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Commander-Genius"),
    name="Git Pull Latest CommanderGenius Code",
    haltOnFailure=True
))
CommanderGenius_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Commander-Genius"),
    property="CommanderGenius_latest_tag",
    name="Fetch Latest CommanderGenius Tag",
    haltOnFailure=True
))
CommanderGenius_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('CommanderGenius_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Commander-Genius"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
CommanderGenius_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Commander-Genius/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('CommanderGenius_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Commander-Genius"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="CommanderGenius-builder", workernames=["worker1"], factory=CommanderGenius_factory, project="CommanderGenius")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="CommanderGenius-changes",
        change_filter=util.ChangeFilter(project='CommanderGenius', branch='master'),
        treeStableTimer=None,
        builderNames=["CommanderGenius-builder"]),
    schedulers.ForceScheduler(
        name="CommanderGenius-force",
        builderNames=["CommanderGenius-builder"])
]