# GoodRobot

# Project where we build based on the latest code of our fork of arvindrajayadav/Good-Robot, which hasn't changed since 2020
# and never had releases. Our fork is where the macOS work lives.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

GoodRobot_publish_schedulers = {"GoodRobot-daily", "GoodRobot-publish"}

project_list = [
    util.Project(name="GoodRobot", description="GoodRobot source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/Good-Robot',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/GoodRobot"),
        project="GoodRobot",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

GoodRobot_factory = util.BuildFactory()

GoodRobot_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/Good-Robot',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Good-Robot"),
    name="Git Pull Latest GoodRobot Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

GoodRobot_factory.addStep(version_date_step())

GoodRobot_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Good-Robot/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Good-Robot"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("GoodRobot_dmg_path", "GoodRobot_version"),
))

GoodRobot_factory.addStep(RequireProperty(
    "GoodRobot_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

GoodRobot_factory.addStep(RequireProperty(
    "GoodRobot_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

GoodRobot_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Good-Robot",
        "--tag", util.Interpolate("GoodRobot_%(prop:GoodRobot_version)s"),
        "--version", util.Property('GoodRobot_version'),
        "--dmg", util.Property('GoodRobot_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Good-Robot"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, GoodRobot_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="GoodRobot-builder", workernames=["worker1"], factory=GoodRobot_factory, project="GoodRobot")
]

scheduler_list = [
    daily_scheduler("GoodRobot", "GoodRobot-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="GoodRobot-force",
        builderNames=["GoodRobot-builder"]),
    schedulers.ForceScheduler(
        name="GoodRobot-publish",
        builderNames=["GoodRobot-builder"])
]
