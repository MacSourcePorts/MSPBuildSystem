# SDLPoP (Prince of Persia)

# Project where we build based on the latest code of NagyD/SDLPoP, whose
# last tag (v1.24-RC, 2025) is a release candidate with fixes since. Built
# and published at most once a day, versioned by the latest tag plus the
# date (1.24-RC-20261126) -- see latest_code.py.
#
# Our macOS changes (Application Support folder, bundled data lookup) are
# applied by the build script from MSPBuildSystem/SDLPoP/msp-macos.patch.
# The original DOS game data is in the repo and bundled in the app.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

SDLPoP_publish_schedulers = {"SDLPoP-daily", "SDLPoP-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
SDLPoP_guard = CommitGuard("SDLPoP", force_scheduler_names={"SDLPoP-force", "SDLPoP-publish"})

project_list = [
    util.Project(name="SDLPoP",description="SDLPoP source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/NagyD/SDLPoP',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/SDLPoP"),
        project="SDLPoP",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

SDLPoP_factory = util.BuildFactory()

SDLPoP_factory.addStep(steps.Git(
    repourl='https://github.com/NagyD/SDLPoP',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/SDLPoP"),
    name="Git Pull Latest SDLPoP Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

SDLPoP_factory.addStep(version_date_step())
SDLPoP_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/SDLPoP"))

SDLPoP_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/SDLPoP/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/SDLPoP"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=SDLPoP_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("SDLPoP_dmg_path", "SDLPoP_version"),
))

SDLPoP_factory.addStep(RequireProperty(
    "SDLPoP_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=SDLPoP_guard.should_build,
))

SDLPoP_factory.addStep(RequireProperty(
    "SDLPoP_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=SDLPoP_guard.should_build,
))

SDLPoP_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "SDLPoP",
        "--tag", util.Interpolate("SDLPoP_%(prop:SDLPoP_version)s"),
        "--version", util.Property('SDLPoP_version'),
        "--dmg", util.Property('SDLPoP_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/SDLPoP"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, SDLPoP_publish_schedulers),
        SDLPoP_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="SDLPoP-builder", workernames=["worker1"], factory=SDLPoP_factory, project="SDLPoP")
]

scheduler_list = [
    daily_scheduler("SDLPoP", "SDLPoP-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="SDLPoP-force",
        builderNames=["SDLPoP-builder"]),
    schedulers.ForceScheduler(
        name="SDLPoP-publish",
        builderNames=["SDLPoP-builder"])
]
