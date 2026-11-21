# KeeperFX

# Project where we build based on the latest code of dkfans/keeperfx: its last
# stable release (v1.4.0) predates the Linux/CMake support the macOS build
# builds on. Built and published at most once a day, versioned like KeeperFX's
# own Alpha builds (1.4.0.<commit count>) plus the date
# (1.4.0.5625-20261120) -- see latest_code.py.
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/keeperfx/msp-macos.patch. The game data comes from
# keeperfx.net's latest release and Alpha patch (see assemble_data.sh).

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

keeperfx_publish_schedulers = {"keeperfx-daily", "keeperfx-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
keeperfx_guard = CommitGuard("keeperfx", force_scheduler_names={"keeperfx-force", "keeperfx-publish"})

project_list = [
    util.Project(name="keeperfx",description="KeeperFX source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/dkfans/keeperfx',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/keeperfx"),
        project="keeperfx",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

keeperfx_factory = util.BuildFactory()

keeperfx_factory.addStep(steps.Git(
    repourl='https://github.com/dkfans/keeperfx',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/keeperfx"),
    name="Git Pull Latest KeeperFX Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

keeperfx_factory.addStep(version_date_step())
keeperfx_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/keeperfx"))

keeperfx_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/keeperfx/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/keeperfx"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=keeperfx_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("keeperfx_dmg_path", "keeperfx_version"),
))

keeperfx_factory.addStep(RequireProperty(
    "keeperfx_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=keeperfx_guard.should_build,
))

keeperfx_factory.addStep(RequireProperty(
    "keeperfx_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=keeperfx_guard.should_build,
))

keeperfx_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "keeperfx",
        "--tag", util.Interpolate("keeperfx_%(prop:keeperfx_version)s"),
        "--version", util.Property('keeperfx_version'),
        "--dmg", util.Property('keeperfx_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/keeperfx"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, keeperfx_publish_schedulers),
        keeperfx_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="keeperfx-builder", workernames=["worker1"], factory=keeperfx_factory, project="keeperfx")
]

scheduler_list = [
    daily_scheduler("keeperfx", "keeperfx-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="keeperfx-force",
        builderNames=["keeperfx-builder"]),
    schedulers.ForceScheduler(
        name="keeperfx-publish",
        builderNames=["keeperfx-builder"])
]
