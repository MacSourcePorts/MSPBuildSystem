# Maelstrom

# Project where we build based on the latest code of our own repo for Maelstrom, which
# has no upstream to follow (its last release was 3.07).
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

Maelstrom_publish_schedulers = {"Maelstrom-daily", "Maelstrom-publish"}

project_list = [
    util.Project(name="Maelstrom", description="Maelstrom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/Maelstrom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Maelstrom"),
        project="Maelstrom",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

Maelstrom_factory = util.BuildFactory()

Maelstrom_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/Maelstrom',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Maelstrom"),
    name="Git Pull Latest Maelstrom Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

Maelstrom_factory.addStep(version_date_step())

Maelstrom_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Maelstrom/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Maelstrom"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("Maelstrom_dmg_path", "Maelstrom_version"),
))

Maelstrom_factory.addStep(RequireProperty(
    "Maelstrom_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

Maelstrom_factory.addStep(RequireProperty(
    "Maelstrom_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

Maelstrom_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Maelstrom",
        "--tag", util.Interpolate("Maelstrom_%(prop:Maelstrom_version)s"),
        "--version", util.Property('Maelstrom_version'),
        "--dmg", util.Property('Maelstrom_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Maelstrom"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Maelstrom_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="Maelstrom-builder", workernames=["worker1"], factory=Maelstrom_factory, project="Maelstrom")
]

scheduler_list = [
    daily_scheduler("Maelstrom", "Maelstrom-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="Maelstrom-force",
        builderNames=["Maelstrom-builder"]),
    schedulers.ForceScheduler(
        name="Maelstrom-publish",
        builderNames=["Maelstrom-builder"])
]
