# BDD3

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="BDD3",description="BDD3 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/aviaozinhoachievements-mac',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/aviaozinhoachievements-mac"),
        project="BDD3",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

BDD3_factory = util.BuildFactory()
BDD3_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/aviaozinhoachievements-mac',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/aviaozinhoachievements-mac"),
    name="Git Pull Latest BDD3 Code",
    haltOnFailure=True
))
BDD3_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/aviaozinhoachievements-mac"),
    property="BDD3_latest_tag",
    name="Fetch Latest BDD3 Tag",
    haltOnFailure=True
))
# BDD3_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('BDD3_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/aviaozinhoachievements-mac"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True
# ))
BDD3_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements-mac/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements-mac"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="BDD3-builder", workernames=["worker1"], factory=BDD3_factory, project="BDD3")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="BDD3-releases",
        change_filter=util.ChangeFilter(project='BDD3'),
        treeStableTimer=None,
        builderNames=["BDD3-builder"]),
    schedulers.ForceScheduler(
        name="BDD3-force",
        builderNames=["BDD3-builder"])
]