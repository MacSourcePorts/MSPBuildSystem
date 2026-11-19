# postal

# Project where we build based on the latest code of our fork of RWS-Studios/POSTAL-SourceCode, which has no releases.
# Our fork is where the macOS work lives.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

postal_publish_schedulers = {"postal-daily", "postal-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
postal_guard = CommitGuard("POSTAL-SourceCode", force_scheduler_names={"postal-force", "postal-publish"})

project_list = [
    util.Project(name="postal", description="postal source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/POSTAL-SourceCode',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/postal"),
        project="postal",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

postal_factory = util.BuildFactory()

postal_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/POSTAL-SourceCode',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/POSTAL-SourceCode"),
    name="Git Pull Latest postal Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

postal_factory.addStep(version_date_step())
postal_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/POSTAL-SourceCode"))

postal_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/POSTAL-SourceCode/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/POSTAL-SourceCode"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=postal_guard.should_build,
    extract_fn=make_release_extractor("postal_dmg_path", "postal_version"),
))

postal_factory.addStep(RequireProperty(
    "postal_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=postal_guard.should_build,
))

postal_factory.addStep(RequireProperty(
    "postal_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=postal_guard.should_build,
))

postal_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "POSTAL-SourceCode",
        "--tag", util.Interpolate("postal_%(prop:postal_version)s"),
        "--version", util.Property('postal_version'),
        "--dmg", util.Property('postal_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/POSTAL-SourceCode"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, postal_publish_schedulers),
        postal_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="postal-builder", workernames=["worker1"], factory=postal_factory, project="postal")
]

scheduler_list = [
    daily_scheduler("postal", "postal-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="postal-force",
        builderNames=["postal-builder"]),
    schedulers.ForceScheduler(
        name="postal-publish",
        builderNames=["postal-builder"])
]
