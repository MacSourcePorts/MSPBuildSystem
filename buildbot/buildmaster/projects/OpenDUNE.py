# OpenDUNE (Dune II)

# Project where we build based on the latest code of OpenDUNE/OpenDUNE, whose
# last tagged release (0.9) dates from 2016. Built and published at most once
# a day, versioned 0.9 plus the date (0.9-20261121) -- see latest_code.py.
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/OpenDUNE/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

OpenDUNE_publish_schedulers = {"OpenDUNE-daily", "OpenDUNE-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
OpenDUNE_guard = CommitGuard("OpenDUNE", force_scheduler_names={"OpenDUNE-force", "OpenDUNE-publish"})

project_list = [
    util.Project(name="OpenDUNE",description="OpenDUNE (Dune II) source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/OpenDUNE/OpenDUNE',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenDUNE"),
        project="OpenDUNE",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

OpenDUNE_factory = util.BuildFactory()

OpenDUNE_factory.addStep(steps.Git(
    repourl='https://github.com/OpenDUNE/OpenDUNE',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenDUNE"),
    name="Git Pull Latest OpenDUNE Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

OpenDUNE_factory.addStep(version_date_step())
OpenDUNE_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/OpenDUNE"))

OpenDUNE_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenDUNE/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenDUNE"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenDUNE_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("OpenDUNE_dmg_path", "OpenDUNE_version"),
))

OpenDUNE_factory.addStep(RequireProperty(
    "OpenDUNE_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=OpenDUNE_guard.should_build,
))

OpenDUNE_factory.addStep(RequireProperty(
    "OpenDUNE_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=OpenDUNE_guard.should_build,
))

OpenDUNE_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenDUNE",
        "--tag", util.Interpolate("OpenDUNE_%(prop:OpenDUNE_version)s"),
        "--version", util.Property('OpenDUNE_version'),
        "--dmg", util.Property('OpenDUNE_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenDUNE"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenDUNE_publish_schedulers),
        OpenDUNE_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="OpenDUNE-builder", workernames=["worker1"], factory=OpenDUNE_factory, project="OpenDUNE")
]

scheduler_list = [
    daily_scheduler("OpenDUNE", "OpenDUNE-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="OpenDUNE-force",
        builderNames=["OpenDUNE-builder"]),
    schedulers.ForceScheduler(
        name="OpenDUNE-publish",
        builderNames=["OpenDUNE-builder"])
]
