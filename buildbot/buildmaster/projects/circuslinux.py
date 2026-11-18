# circuslinux

# Project where we build based on the latest code of our own repo for Circus Linux!, which
# has no upstream to follow (its last release was 1.1.0).
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

circuslinux_publish_schedulers = {"circuslinux-daily", "circuslinux-publish"}

project_list = [
    util.Project(name="circuslinux", description="circuslinux source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/circuslinux',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/circuslinux"),
        project="circuslinux",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

circuslinux_factory = util.BuildFactory()

circuslinux_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/circuslinux',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/circuslinux"),
    name="Git Pull Latest circuslinux Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

circuslinux_factory.addStep(version_date_step())

circuslinux_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/circuslinux/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/circuslinux"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("circuslinux_dmg_path", "circuslinux_version"),
))

circuslinux_factory.addStep(RequireProperty(
    "circuslinux_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

circuslinux_factory.addStep(RequireProperty(
    "circuslinux_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

circuslinux_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "circuslinux",
        "--tag", util.Interpolate("circuslinux_%(prop:circuslinux_version)s"),
        "--version", util.Property('circuslinux_version'),
        "--dmg", util.Property('circuslinux_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/circuslinux"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, circuslinux_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="circuslinux-builder", workernames=["worker1"], factory=circuslinux_factory, project="circuslinux")
]

scheduler_list = [
    daily_scheduler("circuslinux", "circuslinux-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="circuslinux-force",
        builderNames=["circuslinux-builder"]),
    schedulers.ForceScheduler(
        name="circuslinux-publish",
        builderNames=["circuslinux-builder"])
]
