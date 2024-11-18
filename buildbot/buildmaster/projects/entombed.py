# entombed

# Project where we build based off of our own fork and don't worry with tags, just build off latest

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="entombed",description="entombed source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/entombed',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/entombed"),
    #     project="entombed",
    #     branches=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

entombed_factory = util.BuildFactory()
entombed_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/entombed',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/entombed"),
    name="Git Pull Latest entombed Code",
    haltOnFailure=True
))
entombed_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/entombed/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/entombed"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="entombed-builder", workernames=["worker1"], factory=entombed_factory, project="entombed")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="entombed-changes",
    #     change_filter=util.ChangeFilter(project='entombed', branch='main'),
    #     treeStableTimer=None,
    #     builderNames=["entombed-builder"]),
    schedulers.ForceScheduler(
        name="entombed-force",
        builderNames=["entombed-builder"])
]