# BDD3

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="BDD3",description="BDD3 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/aviaozinhoachievements',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/aviaozinhoachievements"),
        project="BDD3",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

BDD3_factory = util.BuildFactory()
BDD3_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/aviaozinhoachievements',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/aviaozinhoachievements"),
    name="Git Pull Latest BDD3 Code",
    haltOnFailure=True
))

# Brazlian Drug Dealer 3
BDD3_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements/macsourceports_universal2_bdd3.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements"),
    name="Run BDD3 Build Script",
    haltOnFailure=True
))

# Brazlian Drug Dealer 4
BDD3_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements/macsourceports_universal2_bdd4.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements"),
    name="Run BDD4 Build Script",
    haltOnFailure=True
))

# FLESHCANCER
BDD3_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements/macsourceports_universal2_fleshcancer.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements"),
    name="Run FLESHCANCER Build Script",
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