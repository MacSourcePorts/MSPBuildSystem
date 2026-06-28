# heretic2r

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="heretic2r",description="heretic2r source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/Heretic2R-UNIX',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/heretic2r"),
        project="heretic2r",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

heretic2r_factory = util.BuildFactory()
heretic2r_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/Heretic2R-UNIX',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Heretic2r-UNIX"),
    name="Git Pull Latest heretic2r Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

# heretic2r_factory.addStep(steps.SetPropertyFromCommand(
#     command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/heretiHeretic2r-UNIXc2r"),
#     property="heretic2r_latest_tag",
#     name="Fetch Latest heretic2r Tag",
#     haltOnFailure=True
# ))

# heretic2r_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('heretic2r_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Heretic2r-UNIX"),
#     name="Checkout Latest heretic2r Tag",
#     haltOnFailure=True
# ))

heretic2r_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Heretic2r-UNIX/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Heretic2r-UNIX"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="heretic2r-builder", workernames=["worker1"], factory=heretic2r_factory, project="heretic2r")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="heretic2r-releases",
        change_filter=util.ChangeFilter(project='heretic2r'),
        treeStableTimer=None,
        builderNames=["heretic2r-builder"]),
    schedulers.ForceScheduler(
        name="heretic2r-force",
        builderNames=["heretic2r-builder"])
]