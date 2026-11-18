# uqm

# Project where we build based on the latest code of our own repo for The Ur-Quan Masters,
# which has no upstream to follow here (its last release was 0.8.0).
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

uqm_publish_schedulers = {"uqm-daily", "uqm-publish"}

project_list = [
    util.Project(name="uqm", description="uqm source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/uqm',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/uqm"),
        project="uqm",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

uqm_factory = util.BuildFactory()

uqm_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/uqm',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/uqm"),
    name="Git Pull Latest uqm Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

uqm_factory.addStep(version_date_step())

uqm_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/uqm/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/uqm"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("uqm_dmg_path", "uqm_version"),
))

uqm_factory.addStep(RequireProperty(
    "uqm_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

uqm_factory.addStep(RequireProperty(
    "uqm_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

uqm_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "uqm",
        "--tag", util.Interpolate("uqm_%(prop:uqm_version)s"),
        "--version", util.Property('uqm_version'),
        "--dmg", util.Property('uqm_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/uqm"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, uqm_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="uqm-builder", workernames=["worker1"], factory=uqm_factory, project="uqm")
]

scheduler_list = [
    daily_scheduler("uqm", "uqm-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="uqm-force",
        builderNames=["uqm-builder"]),
    schedulers.ForceScheduler(
        name="uqm-publish",
        builderNames=["uqm-builder"])
]
