# arcanum-ce

# Project where we build based off of the latest code

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="arcanumce",description="arcanumce source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/alexbatalov/arcanum-ce',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/arcanumce"),
        project="arcanumce",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

arcanumce_factory = util.BuildFactory()
arcanumce_factory.addStep(steps.Git(
    repourl='https://github.com/alexbatalov/arcanum-ce',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/arcanumce"),
    name="Git Pull Latest arcanumce Code",
    haltOnFailure=True
))

arcanumce_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/arcanum-ce/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/arcanum-ce"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="arcanumce-builder", workernames=["worker1"], factory=arcanumce_factory, project="arcanumce")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="arcanumce-releases",
        change_filter=util.ChangeFilter(project='arcanumce'),
        treeStableTimer=None,
        builderNames=["arcanumce-builder"]),
    schedulers.ForceScheduler(
        name="arcanumce-force",
        builderNames=["arcanumce-builder"])
]