# Zuma-Portable

# Project where we build based off of the latest code

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="Zuma-Portable",description="Zuma-Portable source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/kyle-sylvestre/PvZ-Portable',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Zuma-Portable"),
        project="Zuma-Portable",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    ),
    changes.GitPoller(
        repourl='https://github.com/kyle-sylvestre/CircleShootApp',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Zuma-Portable/src/CircleShoot"),
        project="Zuma-Portable",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

ZumaPortable_factory = util.BuildFactory()
ZumaPortable_factory.addStep(steps.Git(
    repourl='https://github.com/kyle-sylvestre/PvZ-Portable',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    branch='zuma',
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Zuma-Portable"),
    name="Git Pull Latest Zuma-Portable Code",
    haltOnFailure=True
))
ZumaPortable_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Zuma-Portable/scripts/create_flat_directory.sh")],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Zuma-Portable"),
    name="Run Flat Directory Script",
    haltOnFailure=True
))
ZumaPortable_factory.addStep(steps.Git(
    repourl='https://github.com/kyle-sylvestre/CircleShootApp',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Zuma-Portable/src/CircleShoot"),
    name="Git Pull Latest CircleShoot Code",
    haltOnFailure=True
))
ZumaPortable_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Zuma-Portable/src/CircleShoot"),
    property="ZumaPortable_latest_tag",
    name="Fetch Latest Zuma-Portable Tag",
    haltOnFailure=True
))
ZumaPortable_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('ZumaPortable_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Zuma-Portable/src/CircleShoot"),
    name="Checkout Latest Tag",
    haltOnFailure=True
))
ZumaPortable_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Zuma-Portable/macsourceports_universal2.sh"), "notarize", util.Property('ZumaPortable_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Zuma-Portable"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="Zuma-Portable-builder", workernames=["worker1"], factory=ZumaPortable_factory, project="Zuma-Portable")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Zuma-Portable-releases",
        change_filter=util.ChangeFilter(project='Zuma-Portable', branch='zuma'),
        treeStableTimer=None,
        builderNames=["Zuma-Portable-builder"]),
    schedulers.ForceScheduler(
        name="Zuma-Portable-force",
        builderNames=["Zuma-Portable-builder"])
]