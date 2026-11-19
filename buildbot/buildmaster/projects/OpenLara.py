# OpenLara

# Project where we build based on the latest code of XProger/OpenLara, which has
# no version numbers (its tags are dates, the last from 2019). Built and
# published at most once a day, versioned by the date (20261116) -- see
# latest_code.py.
#
# Our change, formerly in the MacSourcePorts fork (game data in Application
# Support), is applied by the build script from
# MSPBuildSystem/OpenLara/msp-appsupport.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

OpenLara_publish_schedulers = {"OpenLara-daily", "OpenLara-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
OpenLara_guard = CommitGuard("OpenLara", force_scheduler_names={"OpenLara-force", "OpenLara-publish"})

project_list = [
    util.Project(name="OpenLara",description="OpenLara source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/XProger/OpenLara',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenLara"),
        project="OpenLara",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

OpenLara_factory = util.BuildFactory()

OpenLara_factory.addStep(steps.Git(
    repourl='https://github.com/XProger/OpenLara',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenLara"),
    name="Git Pull Latest OpenLara Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

OpenLara_factory.addStep(version_date_step())
OpenLara_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/OpenLara"))

OpenLara_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenLara/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenLara"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenLara_guard.should_build,
    extract_fn=make_release_extractor("OpenLara_dmg_path", "OpenLara_version"),
))

OpenLara_factory.addStep(RequireProperty(
    "OpenLara_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=OpenLara_guard.should_build,
))

OpenLara_factory.addStep(RequireProperty(
    "OpenLara_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=OpenLara_guard.should_build,
))

OpenLara_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenLara",
        "--tag", util.Interpolate("OpenLara_%(prop:OpenLara_version)s"),
        "--version", util.Property('OpenLara_version'),
        "--dmg", util.Property('OpenLara_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenLara"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenLara_publish_schedulers),
        OpenLara_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="OpenLara-builder", workernames=["worker1"], factory=OpenLara_factory, project="OpenLara")
]

scheduler_list = [
    daily_scheduler("OpenLara", "OpenLara-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="OpenLara-force",
        builderNames=["OpenLara-builder"]),
    schedulers.ForceScheduler(
        name="OpenLara-publish",
        builderNames=["OpenLara-builder"])
]
