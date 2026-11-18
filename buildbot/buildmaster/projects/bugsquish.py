# bugsquish

# Project where we build based on the latest code of our own repo for Bug Squish, which
# has no upstream to follow (its last release was 0.0.6).
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

bugsquish_publish_schedulers = {"bugsquish-daily", "bugsquish-publish"}

project_list = [
    util.Project(name="bugsquish", description="bugsquish source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/bugsquish',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/bugsquish"),
        project="bugsquish",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

bugsquish_factory = util.BuildFactory()

bugsquish_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/bugsquish',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/bugsquish"),
    name="Git Pull Latest bugsquish Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

bugsquish_factory.addStep(version_date_step())

bugsquish_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/bugsquish/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/bugsquish"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("bugsquish_dmg_path", "bugsquish_version"),
))

bugsquish_factory.addStep(RequireProperty(
    "bugsquish_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

bugsquish_factory.addStep(RequireProperty(
    "bugsquish_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

bugsquish_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "bugsquish",
        "--tag", util.Interpolate("bugsquish_%(prop:bugsquish_version)s"),
        "--version", util.Property('bugsquish_version'),
        "--dmg", util.Property('bugsquish_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/bugsquish"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, bugsquish_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="bugsquish-builder", workernames=["worker1"], factory=bugsquish_factory, project="bugsquish")
]

scheduler_list = [
    daily_scheduler("bugsquish", "bugsquish-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="bugsquish-force",
        builderNames=["bugsquish-builder"]),
    schedulers.ForceScheduler(
        name="bugsquish-publish",
        builderNames=["bugsquish-builder"])
]
