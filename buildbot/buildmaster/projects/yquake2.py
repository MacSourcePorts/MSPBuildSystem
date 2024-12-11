# yquake2

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="yquake2",description="yquake2 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/yquake2/yquake2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/yquake2"),
        project="yquake2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    ),
    changes.GitPoller(
        repourl='https://github.com/yquake2/xatrix',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/yquake2/xatrix"),
        project="yquake2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    ),
    changes.GitPoller(
        repourl='https://github.com/yquake2/rogue',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/yquake2/rogue"),
        project="yquake2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    ),
    changes.GitPoller(
        repourl='https://github.com/yquake2/ctf',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/yquake2/ctf"),
        project="yquake2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

yquake2_factory = util.BuildFactory()
yquake2_factory.addStep(steps.Git(
    repourl='https://github.com/yquake2/yquake2',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/yquake2"),
    name="Git Pull Latest yquake2 Code",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.Git(
    repourl='https://github.com/yquake2/xatrix',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xatrix"),
    name="Git Pull Latest xatrix (mp1) Code",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.Git(
    repourl='https://github.com/yquake2/rogue',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rogue"),
    name="Git Pull Latest rogue (mp2) Code",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.Git(
    repourl='https://github.com/yquake2/ctf',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ctf"),
    name="Git Pull Latest ctf Code",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/yquake2"),
    property="yquake2_latest_tag",
    name="Fetch Latest yquake2 Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xatrix"),
    property="xatrix_latest_tag",
    name="Fetch Latest xatrix (mp1) Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rogue"),
    property="rogue_latest_tag",
    name="Fetch Latest rogue (mp2) Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ctf"),
    property="ctf_latest_tag",
    name="Fetch Latest ctf Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('yquake2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/yquake2"),
    name="Checkout Latest yquake2 Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('xatrix_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xatrix"),
    name="Checkout Latest xatrix (mp1) Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('rogue_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rogue"),
    name="Checkout Latest rogue (mp2) Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('ctf_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ctf"),
    name="Checkout Latest ctf Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/yquake2/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('yquake2_latest_tag'), util.Property('xatrix_latest_tag'), util.Property('rogue_latest_tag'), util.Property('ctf_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/yquake2"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="yquake2-builder", workernames=["worker1"], factory=yquake2_factory, project="yquake2")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="yquake2-changes",
        change_filter=util.ChangeFilter(project='yquake2'),
        treeStableTimer=None,
        builderNames=["yquake2-builder"]),
    schedulers.ForceScheduler(
        name="yquake2-force",
        builderNames=["yquake2-builder"])
]