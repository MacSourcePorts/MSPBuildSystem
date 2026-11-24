# Aquaria

# Project where we build based on the latest code of AquariaOSE/Aquaria, whose
# only tagged releases are from 2015 (OSE-v1.002). Built and published at
# most once a day, versioned by the date alone (20261123, as with civctp2)
# -- see latest_code.py.
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/Aquaria/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

Aquaria_publish_schedulers = {"Aquaria-daily", "Aquaria-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
Aquaria_guard = CommitGuard("Aquaria", force_scheduler_names={"Aquaria-force", "Aquaria-publish"})

project_list = [
    util.Project(name="Aquaria",description="Aquaria source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/AquariaOSE/Aquaria',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Aquaria"),
        project="Aquaria",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

Aquaria_factory = util.BuildFactory()

Aquaria_factory.addStep(steps.Git(
    repourl='https://github.com/AquariaOSE/Aquaria',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Aquaria"),
    name="Git Pull Latest Aquaria Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

Aquaria_factory.addStep(version_date_step())
Aquaria_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/Aquaria"))

Aquaria_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Aquaria/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Aquaria"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=Aquaria_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("Aquaria_dmg_path", "Aquaria_version"),
))

Aquaria_factory.addStep(RequireProperty(
    "Aquaria_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=Aquaria_guard.should_build,
))

Aquaria_factory.addStep(RequireProperty(
    "Aquaria_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=Aquaria_guard.should_build,
))

Aquaria_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Aquaria",
        "--tag", util.Interpolate("Aquaria_%(prop:Aquaria_version)s"),
        "--version", util.Property('Aquaria_version'),
        "--dmg", util.Property('Aquaria_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Aquaria"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Aquaria_publish_schedulers),
        Aquaria_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="Aquaria-builder", workernames=["worker1"], factory=Aquaria_factory, project="Aquaria")
]

scheduler_list = [
    daily_scheduler("Aquaria", "Aquaria-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="Aquaria-force",
        builderNames=["Aquaria-builder"]),
    schedulers.ForceScheduler(
        name="Aquaria-publish",
        builderNames=["Aquaria-builder"])
]
