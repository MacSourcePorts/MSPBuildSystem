# RigelEngine

# Project where we build based on the latest code of lethal-guitar/RigelEngine. Its last release
# (v0.9.1, 2022) no longer compiles with current libc++, and master is still
# actively developed.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

RigelEngine_publish_schedulers = {"RigelEngine-daily", "RigelEngine-publish"}

project_list = [
    util.Project(name="RigelEngine", description="RigelEngine source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/lethal-guitar/RigelEngine',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/RigelEngine"),
        project="RigelEngine",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

RigelEngine_factory = util.BuildFactory()

RigelEngine_factory.addStep(steps.Git(
    repourl='https://github.com/lethal-guitar/RigelEngine',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/RigelEngine"),
    name="Git Pull Latest RigelEngine Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

RigelEngine_factory.addStep(version_date_step())

RigelEngine_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/RigelEngine/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/RigelEngine"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("RigelEngine_dmg_path", "RigelEngine_version"),
))

RigelEngine_factory.addStep(RequireProperty(
    "RigelEngine_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

RigelEngine_factory.addStep(RequireProperty(
    "RigelEngine_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

RigelEngine_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "RigelEngine",
        "--tag", util.Interpolate("RigelEngine_%(prop:RigelEngine_version)s"),
        "--version", util.Property('RigelEngine_version'),
        "--dmg", util.Property('RigelEngine_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/RigelEngine"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, RigelEngine_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="RigelEngine-builder", workernames=["worker1"], factory=RigelEngine_factory, project="RigelEngine")
]

scheduler_list = [
    daily_scheduler("RigelEngine", "RigelEngine-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="RigelEngine-force",
        builderNames=["RigelEngine-builder"]),
    schedulers.ForceScheduler(
        name="RigelEngine-publish",
        builderNames=["RigelEngine-builder"])
]
