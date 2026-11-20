# Descent3

# Project where we build based on the latest code of DescentDevelopers/Descent3,
# which hasn't tagged a release since v1.5.0 (2024). Built and published at
# most once a day, versioned by the version in its CMakeLists.txt plus the
# date (1.6.0-20261120) -- see latest_code.py.
#
# Our macOS changes (Ogg Theora movies for the Steam data, etc.) are applied
# by the build script from MSPBuildSystem/Descent3/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

Descent3_publish_schedulers = {"Descent3-daily", "Descent3-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
Descent3_guard = CommitGuard("Descent3", force_scheduler_names={"Descent3-force", "Descent3-publish"})

project_list = [
    util.Project(name="Descent3",description="Descent 3 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/DescentDevelopers/Descent3',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Descent3"),
        project="Descent3",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

Descent3_factory = util.BuildFactory()

Descent3_factory.addStep(steps.Git(
    repourl='https://github.com/DescentDevelopers/Descent3',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Descent3"),
    name="Git Pull Latest Descent3 Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

Descent3_factory.addStep(version_date_step())
Descent3_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/Descent3"))

Descent3_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Descent3/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Descent3"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=Descent3_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("Descent3_dmg_path", "Descent3_version"),
))

Descent3_factory.addStep(RequireProperty(
    "Descent3_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=Descent3_guard.should_build,
))

Descent3_factory.addStep(RequireProperty(
    "Descent3_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=Descent3_guard.should_build,
))

Descent3_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Descent3",
        "--tag", util.Interpolate("Descent3_%(prop:Descent3_version)s"),
        "--version", util.Property('Descent3_version'),
        "--dmg", util.Property('Descent3_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Descent3"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Descent3_publish_schedulers),
        Descent3_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="Descent3-builder", workernames=["worker1"], factory=Descent3_factory, project="Descent3")
]

scheduler_list = [
    daily_scheduler("Descent3", "Descent3-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="Descent3-force",
        builderNames=["Descent3-builder"]),
    schedulers.ForceScheduler(
        name="Descent3-publish",
        builderNames=["Descent3-builder"])
]
