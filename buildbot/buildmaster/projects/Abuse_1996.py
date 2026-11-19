# Abuse_1996

# Project where we build based on the latest code of our fork of antrad/Abuse_1996, which hasn't changed since 2016. Our
# fork is where the macOS work lives.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

Abuse_1996_publish_schedulers = {"Abuse_1996-daily", "Abuse_1996-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
Abuse_1996_guard = CommitGuard("Abuse_1996", force_scheduler_names={"Abuse_1996-force", "Abuse_1996-publish"})

project_list = [
    util.Project(name="Abuse_1996", description="Abuse_1996 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/Abuse_1996',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Abuse_1996"),
        project="Abuse_1996",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

Abuse_1996_factory = util.BuildFactory()

Abuse_1996_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/Abuse_1996',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Abuse_1996"),
    name="Git Pull Latest Abuse_1996 Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

Abuse_1996_factory.addStep(version_date_step())
Abuse_1996_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/Abuse_1996"))

Abuse_1996_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Abuse_1996/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Abuse_1996"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=Abuse_1996_guard.should_build,
    extract_fn=make_release_extractor("Abuse_1996_dmg_path", "Abuse_1996_version"),
))

Abuse_1996_factory.addStep(RequireProperty(
    "Abuse_1996_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=Abuse_1996_guard.should_build,
))

Abuse_1996_factory.addStep(RequireProperty(
    "Abuse_1996_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=Abuse_1996_guard.should_build,
))

Abuse_1996_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Abuse_1996",
        "--tag", util.Interpolate("Abuse_1996_%(prop:Abuse_1996_version)s"),
        "--version", util.Property('Abuse_1996_version'),
        "--dmg", util.Property('Abuse_1996_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Abuse_1996"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Abuse_1996_publish_schedulers),
        Abuse_1996_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="Abuse_1996-builder", workernames=["worker1"], factory=Abuse_1996_factory, project="Abuse_1996")
]

scheduler_list = [
    daily_scheduler("Abuse_1996", "Abuse_1996-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="Abuse_1996-force",
        builderNames=["Abuse_1996-builder"]),
    schedulers.ForceScheduler(
        name="Abuse_1996-publish",
        builderNames=["Abuse_1996-builder"])
]
