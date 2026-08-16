# aviaozinhoachievements

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="aviaozinhoachievements",description="aviaozinhoachievements source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/aviaozinhoachievements',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/aviaozinhoachievements"),
        project="aviaozinhoachievements",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

aviaozinhoachievements_factory = util.BuildFactory()
aviaozinhoachievements_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/aviaozinhoachievements',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/aviaozinhoachievements"),
    name="Git Pull Latest aviaozinhoachievements Code",
    haltOnFailure=True
))

# Brazlian Drug Dealer 3
aviaozinhoachievements_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements/macsourceports_universal2_bdd3.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements"),
    name="Run aviaozinhoachievements Build Script",
    haltOnFailure=True
))

# Brazlian Drug Dealer 4
aviaozinhoachievements_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements/macsourceports_universal2_bdd4.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements"),
    name="Run BDD4 Build Script",
    haltOnFailure=True
))

# FLESHCANCER
aviaozinhoachievements_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements/macsourceports_universal2_fleshcancer.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements"),
    name="Run FLESHCANCER Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="aviaozinhoachievements-builder", workernames=["worker1"], factory=aviaozinhoachievements_factory, project="aviaozinhoachievements")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="aviaozinhoachievements-releases",
        change_filter=util.ChangeFilter(project='aviaozinhoachievements'),
        treeStableTimer=None,
        builderNames=["aviaozinhoachievements-builder"]),
    schedulers.ForceScheduler(
        name="aviaozinhoachievements-force",
        builderNames=["aviaozinhoachievements-builder"])
]