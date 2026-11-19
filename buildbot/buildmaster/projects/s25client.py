# s25client

# Project where we build based on the latest code of Return-To-The-Roots/s25client. Its last
# release (v0.9.5, 2022) no longer builds against current Boost, and master is
# still actively developed.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

s25client_publish_schedulers = {"s25client-daily", "s25client-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
s25client_guard = CommitGuard("s25client", force_scheduler_names={"s25client-force", "s25client-publish"})

project_list = [
    util.Project(name="s25client", description="s25client source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/Return-To-The-Roots/s25client',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/s25client"),
        project="s25client",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

s25client_factory = util.BuildFactory()

s25client_factory.addStep(steps.Git(
    repourl='https://github.com/Return-To-The-Roots/s25client',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/s25client"),
    name="Git Pull Latest s25client Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

s25client_factory.addStep(version_date_step())
s25client_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/s25client"))

s25client_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/s25client/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/s25client"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=s25client_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("s25client_dmg_path", "s25client_version"),
))

s25client_factory.addStep(RequireProperty(
    "s25client_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=s25client_guard.should_build,
))

s25client_factory.addStep(RequireProperty(
    "s25client_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=s25client_guard.should_build,
))

s25client_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "s25client",
        "--tag", util.Interpolate("s25client_%(prop:s25client_version)s"),
        "--version", util.Property('s25client_version'),
        "--dmg", util.Property('s25client_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/s25client"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, s25client_publish_schedulers),
        s25client_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="s25client-builder", workernames=["worker1"], factory=s25client_factory, project="s25client")
]

scheduler_list = [
    daily_scheduler("s25client", "s25client-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="s25client-force",
        builderNames=["s25client-builder"]),
    schedulers.ForceScheduler(
        name="s25client-publish",
        builderNames=["s25client-builder"])
]
