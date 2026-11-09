# OpenXcom

# Project where we build based the latest code because the tags are old and/or they don't do versioned releases.
# Built and published at most once a day, versioned by date (1.0-20261109) --
# see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

OpenXcom_publish_schedulers = {"OpenXcom-daily", "OpenXcom-publish"}

project_list = [
    util.Project(name="OpenXcom",description="OpenXcom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/OpenXcom/OpenXcom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenXcom"),
        project="OpenXcom",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenXcom_factory = util.BuildFactory()

OpenXcom_factory.addStep(steps.Git(
    repourl='https://github.com/OpenXcom/OpenXcom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenXcom"),
    name="Git Pull Latest OpenXcom Code",
    haltOnFailure=True
))

OpenXcom_factory.addStep(version_date_step())

OpenXcom_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenXcom/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenXcom"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("OpenXcom_dmg_path", "OpenXcom_version"),
))

OpenXcom_factory.addStep(RequireProperty(
    "OpenXcom_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

OpenXcom_factory.addStep(RequireProperty(
    "OpenXcom_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

OpenXcom_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenXcom",
        "--tag", util.Interpolate("OpenXcom_%(prop:OpenXcom_version)s"),
        "--version", util.Property('OpenXcom_version'),
        "--dmg", util.Property('OpenXcom_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenXcom"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenXcom_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="OpenXcom-builder", workernames=["worker1"], factory=OpenXcom_factory, project="OpenXcom")
]

scheduler_list = [
    daily_scheduler("OpenXcom", "OpenXcom-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="OpenXcom-force",
        builderNames=["OpenXcom-builder"]),
    schedulers.ForceScheduler(
        name="OpenXcom-publish",
        builderNames=["OpenXcom-builder"])
]
