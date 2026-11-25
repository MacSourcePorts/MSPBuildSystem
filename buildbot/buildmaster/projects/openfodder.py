# openfodder (OpenFodder: Cannon Fodder and Cannon Fodder 2)

# Project where we build based on the latest code of OpenFodder/openfodder,
# whose last release (2.0.0, 2025) predates its move to SDL3. Built and
# published at most once a day, versioned by the latest tag plus the date
# (2.0.0-20261124) -- see latest_code.py.
#
# Our macOS changes (Application Support data folder, bundled data) are
# applied by the build script from MSPBuildSystem/openfodder/msp-macos.patch.
# The game's data repo is the Run submodule, bundled in the app.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

openfodder_publish_schedulers = {"openfodder-daily", "openfodder-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
openfodder_guard = CommitGuard("openfodder", force_scheduler_names={"openfodder-force", "openfodder-publish"})

project_list = [
    util.Project(name="openfodder",description="OpenFodder source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/OpenFodder/openfodder',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/openfodder"),
        project="openfodder",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

openfodder_factory = util.BuildFactory()

openfodder_factory.addStep(steps.Git(
    repourl='https://github.com/OpenFodder/openfodder',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/openfodder"),
    name="Git Pull Latest openfodder Code",
    alwaysUseLatest=True,
    haltOnFailure=True,
    submodules=True
))

openfodder_factory.addStep(version_date_step())
openfodder_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/openfodder"))

openfodder_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/openfodder/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/openfodder"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=openfodder_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("openfodder_dmg_path", "openfodder_version"),
))

openfodder_factory.addStep(RequireProperty(
    "openfodder_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=openfodder_guard.should_build,
))

openfodder_factory.addStep(RequireProperty(
    "openfodder_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=openfodder_guard.should_build,
))

openfodder_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "openfodder",
        "--tag", util.Interpolate("openfodder_%(prop:openfodder_version)s"),
        "--version", util.Property('openfodder_version'),
        "--dmg", util.Property('openfodder_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/openfodder"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, openfodder_publish_schedulers),
        openfodder_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="openfodder-builder", workernames=["worker1"], factory=openfodder_factory, project="openfodder")
]

scheduler_list = [
    daily_scheduler("openfodder", "openfodder-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="openfodder-force",
        builderNames=["openfodder-builder"]),
    schedulers.ForceScheduler(
        name="openfodder-publish",
        builderNames=["openfodder-builder"])
]
