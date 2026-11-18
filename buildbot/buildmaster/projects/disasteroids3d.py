# disasteroids3d

# Project where we build based on the latest code of our fork of tomkidd/disasteroids3d, which hasn't changed since 2020.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

disasteroids3d_publish_schedulers = {"disasteroids3d-daily", "disasteroids3d-publish"}

project_list = [
    util.Project(name="disasteroids3d", description="disasteroids3d source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/disasteroids3d',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/disasteroids3d"),
        project="disasteroids3d",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

disasteroids3d_factory = util.BuildFactory()

disasteroids3d_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/disasteroids3d',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/disasteroids3d"),
    name="Git Pull Latest disasteroids3d Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

disasteroids3d_factory.addStep(version_date_step())

disasteroids3d_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/disasteroids3d/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/disasteroids3d"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("disasteroids3d_dmg_path", "disasteroids3d_version"),
))

disasteroids3d_factory.addStep(RequireProperty(
    "disasteroids3d_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

disasteroids3d_factory.addStep(RequireProperty(
    "disasteroids3d_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

disasteroids3d_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "disasteroids3d",
        "--tag", util.Interpolate("disasteroids3d_%(prop:disasteroids3d_version)s"),
        "--version", util.Property('disasteroids3d_version'),
        "--dmg", util.Property('disasteroids3d_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/disasteroids3d"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, disasteroids3d_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="disasteroids3d-builder", workernames=["worker1"], factory=disasteroids3d_factory, project="disasteroids3d")
]

scheduler_list = [
    daily_scheduler("disasteroids3d", "disasteroids3d-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="disasteroids3d-force",
        builderNames=["disasteroids3d-builder"]),
    schedulers.ForceScheduler(
        name="disasteroids3d-publish",
        builderNames=["disasteroids3d-builder"])
]
