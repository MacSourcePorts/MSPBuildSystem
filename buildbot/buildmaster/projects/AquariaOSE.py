# AquariaOSE (Aquaria)

# Project where we build based on the latest code of AquariaOSE/Aquaria, whose
# only tagged releases are from 2015 (OSE-v1.002). Built and published at
# most once a day, versioned by the date alone (20261123, as with civctp2)
# -- see latest_code.py.
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/AquariaOSE/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

AquariaOSE_publish_schedulers = {"AquariaOSE-daily", "AquariaOSE-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
AquariaOSE_guard = CommitGuard("AquariaOSE", force_scheduler_names={"AquariaOSE-force", "AquariaOSE-publish"})

project_list = [
    util.Project(name="AquariaOSE",description="Aquaria (AquariaOSE) source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/AquariaOSE/Aquaria',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/AquariaOSE"),
        project="AquariaOSE",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

AquariaOSE_factory = util.BuildFactory()

AquariaOSE_factory.addStep(steps.Git(
    repourl='https://github.com/AquariaOSE/Aquaria',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/AquariaOSE"),
    name="Git Pull Latest AquariaOSE Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

AquariaOSE_factory.addStep(version_date_step())
AquariaOSE_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/AquariaOSE"))

AquariaOSE_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/AquariaOSE/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/AquariaOSE"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=AquariaOSE_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("AquariaOSE_dmg_path", "AquariaOSE_version"),
))

AquariaOSE_factory.addStep(RequireProperty(
    "AquariaOSE_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=AquariaOSE_guard.should_build,
))

AquariaOSE_factory.addStep(RequireProperty(
    "AquariaOSE_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=AquariaOSE_guard.should_build,
))

AquariaOSE_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "AquariaOSE",
        "--tag", util.Interpolate("AquariaOSE_%(prop:AquariaOSE_version)s"),
        "--version", util.Property('AquariaOSE_version'),
        "--dmg", util.Property('AquariaOSE_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/AquariaOSE"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, AquariaOSE_publish_schedulers),
        AquariaOSE_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="AquariaOSE-builder", workernames=["worker1"], factory=AquariaOSE_factory, project="AquariaOSE")
]

scheduler_list = [
    daily_scheduler("AquariaOSE", "AquariaOSE-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="AquariaOSE-force",
        builderNames=["AquariaOSE-builder"]),
    schedulers.ForceScheduler(
        name="AquariaOSE-publish",
        builderNames=["AquariaOSE-builder"])
]
