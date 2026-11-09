# Quake3e

# Project where we build based the latest code because we can't update the original.
# Built and published at most once a day, versioned by date (1.32e-20261109) --
# see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

Quake3e_publish_schedulers = {"Quake3e-daily", "Quake3e-publish"}

project_list = [
    util.Project(name="Quake3e",description="Quake3e source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/ec-/quake3e',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Quake3e"),
        project="Quake3e",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

Quake3e_factory = util.BuildFactory()

Quake3e_factory.addStep(steps.Git(
    repourl='https://github.com/ec-/quake3e',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Quake3e"),
    name="Git Pull Latest Quake3e Code",
    haltOnFailure=True
))

Quake3e_factory.addStep(version_date_step())

Quake3e_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Quake3e/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Quake3e"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("Quake3e_dmg_path", "Quake3e_version"),
))

Quake3e_factory.addStep(RequireProperty(
    "Quake3e_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

Quake3e_factory.addStep(RequireProperty(
    "Quake3e_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

Quake3e_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Quake3e",
        "--tag", util.Interpolate("Quake3e_%(prop:Quake3e_version)s"),
        "--version", util.Property('Quake3e_version'),
        "--dmg", util.Property('Quake3e_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Quake3e"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Quake3e_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="Quake3e-builder", workernames=["worker1"], factory=Quake3e_factory, project="Quake3e")
]

scheduler_list = [
    daily_scheduler("Quake3e", "Quake3e-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="Quake3e-force",
        builderNames=["Quake3e-builder"]),
    schedulers.ForceScheduler(
        name="Quake3e-publish",
        builderNames=["Quake3e-builder"])
]
