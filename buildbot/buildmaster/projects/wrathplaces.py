# wrathplaces

# Project where we build based on the latest code of our fork of atsb/wrathplaces, which hasn't changed since 2024. Our
# fork is where the macOS work lives.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

wrathplaces_publish_schedulers = {"wrathplaces-daily", "wrathplaces-publish"}

project_list = [
    util.Project(name="wrathplaces", description="wrathplaces source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/wrathplaces',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/wrathplaces"),
        project="wrathplaces",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

wrathplaces_factory = util.BuildFactory()

wrathplaces_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/wrathplaces',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/wrathplaces"),
    name="Git Pull Latest wrathplaces Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

wrathplaces_factory.addStep(version_date_step())

wrathplaces_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/wrathplaces/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/wrathplaces"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("wrathplaces_dmg_path", "wrathplaces_version"),
))

wrathplaces_factory.addStep(RequireProperty(
    "wrathplaces_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

wrathplaces_factory.addStep(RequireProperty(
    "wrathplaces_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

wrathplaces_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "wrathplaces",
        "--tag", util.Interpolate("wrathplaces_%(prop:wrathplaces_version)s"),
        "--version", util.Property('wrathplaces_version'),
        "--dmg", util.Property('wrathplaces_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/wrathplaces"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, wrathplaces_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="wrathplaces-builder", workernames=["worker1"], factory=wrathplaces_factory, project="wrathplaces")
]

scheduler_list = [
    daily_scheduler("wrathplaces", "wrathplaces-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="wrathplaces-force",
        builderNames=["wrathplaces-builder"]),
    schedulers.ForceScheduler(
        name="wrathplaces-publish",
        builderNames=["wrathplaces-builder"])
]
