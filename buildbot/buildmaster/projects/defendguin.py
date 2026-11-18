# defendguin

# Project where we build based on the latest code of our own repo for Defendguin, which
# has no upstream to follow (its last release was 0.0.13).
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

defendguin_publish_schedulers = {"defendguin-daily", "defendguin-publish"}

project_list = [
    util.Project(name="defendguin", description="defendguin source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/defendguin',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/defendguin"),
        project="defendguin",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

defendguin_factory = util.BuildFactory()

defendguin_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/defendguin',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/defendguin"),
    name="Git Pull Latest defendguin Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

defendguin_factory.addStep(version_date_step())

defendguin_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/defendguin/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/defendguin"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("defendguin_dmg_path", "defendguin_version"),
))

defendguin_factory.addStep(RequireProperty(
    "defendguin_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

defendguin_factory.addStep(RequireProperty(
    "defendguin_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

defendguin_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "defendguin",
        "--tag", util.Interpolate("defendguin_%(prop:defendguin_version)s"),
        "--version", util.Property('defendguin_version'),
        "--dmg", util.Property('defendguin_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/defendguin"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, defendguin_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="defendguin-builder", workernames=["worker1"], factory=defendguin_factory, project="defendguin")
]

scheduler_list = [
    daily_scheduler("defendguin", "defendguin-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="defendguin-force",
        builderNames=["defendguin-builder"]),
    schedulers.ForceScheduler(
        name="defendguin-publish",
        builderNames=["defendguin-builder"])
]
