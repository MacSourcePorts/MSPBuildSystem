# xash3dfwgs

# Project where we build based the latest code because we can't update the original.
# Built and published at most once a day, versioned by date (0.20-20261030) --
# see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

xash3dfwgs_publish_schedulers = {"xash3d-fwgs-daily", "xash3d-fwgs-publish"}

project_list = [ 
    util.Project(name="xash3d-fwgs",description="xash3d-fwgs source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/FWGS/xash3d-fwgs',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/xash3d-fwgs"),
        project="xash3d-fwgs",
        branches=True,
        pollInterval=3600  # Poll every hour
    ),
    changes.GitPoller(
        repourl='https://github.com/FWGS/hlsdk-portable',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/xash3d-fwgs/hlsdk-portable"),
        project="xash3d-fwgs",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

xash3dfwgs_factory = util.BuildFactory()

xash3dfwgs_factory.addStep(steps.Git(
    repourl='https://github.com/FWGS/xash3d-fwgs',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xash3d-fwgs"),
    name="Git Pull Latest xash3d-fwgs Code",
    haltOnFailure=True
))

xash3dfwgs_factory.addStep(steps.Git(
    repourl='https://github.com/FWGS/hlsdk-portable',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/hlsdk-portable"),
    name="Git Pull Latest hlsdk-portable Code",
    haltOnFailure=True
))

xash3dfwgs_factory.addStep(version_date_step())

xash3dfwgs_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/xash3d-fwgs/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/xash3d-fwgs"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("xash3dfwgs_dmg_path", "xash3dfwgs_version"),
))

xash3dfwgs_factory.addStep(RequireProperty(
    "xash3dfwgs_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

xash3dfwgs_factory.addStep(RequireProperty(
    "xash3dfwgs_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

xash3dfwgs_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "xash3d-fwgs",
        "--tag", util.Interpolate("xash3d-fwgs_%(prop:xash3dfwgs_version)s"),
        "--version", util.Property('xash3dfwgs_version'),
        "--dmg", util.Property('xash3dfwgs_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xash3d-fwgs"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, xash3dfwgs_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="xash3d-fwgs-builder", workernames=["worker1"], factory=xash3dfwgs_factory, project="xash3d-fwgs")
]

scheduler_list = [ 
    # hlsdk-portable's opfor/bshift branches are built into the app too
    daily_scheduler("xash3d-fwgs", "xash3d-fwgs-builder", branches=["master", "opfor", "bshift"]),
    schedulers.ForceScheduler(
        name="xash3d-fwgs-force",
        builderNames=["xash3d-fwgs-builder"]),
    schedulers.ForceScheduler(
        name="xash3d-fwgs-publish",
        builderNames=["xash3d-fwgs-builder"])
]