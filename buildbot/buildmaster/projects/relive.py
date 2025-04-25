# relive

# Project where we build based the latest code because we can't update the original

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="relive",description="relive source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/alive_reversing',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/alive_reversing"),
        project="relive",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

relive_factory = util.BuildFactory()
relive_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/alive_reversing',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/alive_reversing"),
    name="Git Pull Latest relive Code",
    haltOnFailure=True
))
relive_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/alive_reversing/macsourceports_universal2-ae.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/alive_reversing"),
    name="Run Build Script (AE)",
    haltOnFailure=True
))
relive_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/alive_reversing/macsourceports_universal2-ao.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/alive_reversing"),
    name="Run Build Script (AO)",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="relive-builder", workernames=["worker1"], factory=relive_factory, project="relive")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="relive-changes",
        change_filter=util.ChangeFilter(project='relive', branch='main'),
        treeStableTimer=None,
        builderNames=["relive-builder"]),
    schedulers.ForceScheduler(
        name="relive-force",
        builderNames=["relive-builder"])
]