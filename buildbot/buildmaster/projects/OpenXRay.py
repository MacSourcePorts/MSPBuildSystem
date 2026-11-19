# OpenXRay

# Project where we build based on the latest code of OpenXRay/xray-16, whose
# only releases are old RCs and a rolling "latest-nightly" tag. Built and
# published at most once a day, versioned by the build script's APP_VERSION
# plus the date (1.6-20261117) -- see latest_code.py.
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/xray-16/msp-*.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

OpenXRay_publish_schedulers = {"OpenXRay-daily", "OpenXRay-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
OpenXRay_guard = CommitGuard("xray-16", force_scheduler_names={"OpenXRay-force", "OpenXRay-publish"})

project_list = [
    util.Project(name="OpenXRay",description="OpenXRay source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/OpenXRay/xray-16',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenXRay"),
        project="OpenXRay",
        branches=["dev"],
        pollInterval=3600  # Poll every hour
    )
]

OpenXRay_factory = util.BuildFactory()

OpenXRay_factory.addStep(steps.Git(
    repourl='https://github.com/OpenXRay/xray-16',
    branch='dev',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xray-16"),
    name="Git Pull Latest OpenXRay Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

OpenXRay_factory.addStep(version_date_step())
OpenXRay_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/xray-16"))

OpenXRay_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/xray-16/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/xray-16"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=OpenXRay_guard.should_build,
    timeout=3600,  # two full builds, one per architecture
    extract_fn=make_release_extractor("OpenXRay_dmg_path", "OpenXRay_version"),
))

OpenXRay_factory.addStep(RequireProperty(
    "OpenXRay_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=OpenXRay_guard.should_build,
))

OpenXRay_factory.addStep(RequireProperty(
    "OpenXRay_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=OpenXRay_guard.should_build,
))

OpenXRay_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "xray-16",
        "--tag", util.Interpolate("OpenXRay_%(prop:OpenXRay_version)s"),
        "--version", util.Property('OpenXRay_version'),
        "--dmg", util.Property('OpenXRay_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xray-16"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenXRay_publish_schedulers),
        OpenXRay_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="OpenXRay-builder", workernames=["worker1"], factory=OpenXRay_factory, project="OpenXRay")
]

scheduler_list = [
    daily_scheduler("OpenXRay", "OpenXRay-builder", branches=["dev"]),
    schedulers.ForceScheduler(
        name="OpenXRay-force",
        builderNames=["OpenXRay-builder"]),
    schedulers.ForceScheduler(
        name="OpenXRay-publish",
        builderNames=["OpenXRay-builder"])
]
