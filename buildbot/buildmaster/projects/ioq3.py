# ioq3

# Project where we build based the latest code because we can't update the original.
# Built and published at most once a day, versioned by date (1.36-20261104) --
# see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

ioq3_publish_schedulers = {"ioq3-daily", "ioq3-publish"}

project_list = [
    util.Project(name="ioq3",description="ioq3 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/ioquake/ioq3',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/ioq3"),
        project="ioq3",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

ioq3_factory = util.BuildFactory()

ioq3_factory.addStep(steps.Git(
    repourl='https://github.com/ioquake/ioq3',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ioq3"),
    name="Git Pull Latest ioq3 Code",
    haltOnFailure=True
))

ioq3_factory.addStep(version_date_step())

ioq3_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ioq3/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/ioq3"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("ioq3_dmg_path", "ioq3_version"),
))

ioq3_factory.addStep(RequireProperty(
    "ioq3_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

ioq3_factory.addStep(RequireProperty(
    "ioq3_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

ioq3_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "ioq3",
        "--tag", util.Interpolate("ioq3_%(prop:ioq3_version)s"),
        "--version", util.Property('ioq3_version'),
        "--dmg", util.Property('ioq3_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ioq3"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, ioq3_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="ioq3-builder", workernames=["worker1"], factory=ioq3_factory, project="ioq3")
]

scheduler_list = [
    daily_scheduler("ioq3", "ioq3-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="ioq3-force",
        builderNames=["ioq3-builder"]),
    schedulers.ForceScheduler(
        name="ioq3-publish",
        builderNames=["ioq3-builder"])
]
