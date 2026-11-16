# heretic2r

# Project where we build based on the latest code of m0rb/Heretic2R-UNIX (the
# UNIX port of m-x-d/Heretic2R). Built and published at most once a day,
# versioned by its newest release tag plus the date (R6-20261115) -- see
# latest_code.py.
#
# Our macOS changes, formerly in the MacSourcePorts fork, are applied by the
# build script from MSPBuildSystem/Heretic2R-UNIX/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

heretic2r_publish_schedulers = {"heretic2r-daily", "heretic2r-publish"}

project_list = [
    util.Project(name="heretic2r",description="heretic2r source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/m0rb/Heretic2R-UNIX',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/heretic2r"),
        project="heretic2r",
        branches=["unix"],
        pollInterval=3600  # Poll every hour
    )
]

heretic2r_factory = util.BuildFactory()

heretic2r_factory.addStep(steps.Git(
    repourl='https://github.com/m0rb/Heretic2R-UNIX',
    branch='unix',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Heretic2R-UNIX"),
    name="Git Pull Latest heretic2r Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

heretic2r_factory.addStep(version_date_step())

heretic2r_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Heretic2R-UNIX/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Heretic2R-UNIX"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("heretic2r_dmg_path", "heretic2r_version"),
))

heretic2r_factory.addStep(RequireProperty(
    "heretic2r_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

heretic2r_factory.addStep(RequireProperty(
    "heretic2r_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

heretic2r_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Heretic2R-UNIX",
        "--tag", util.Interpolate("heretic2r_%(prop:heretic2r_version)s"),
        "--version", util.Property('heretic2r_version'),
        "--dmg", util.Property('heretic2r_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Heretic2R-UNIX"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, heretic2r_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="heretic2r-builder", workernames=["worker1"], factory=heretic2r_factory, project="heretic2r")
]

scheduler_list = [
    daily_scheduler("heretic2r", "heretic2r-builder", branches=["unix"]),
    schedulers.ForceScheduler(
        name="heretic2r-force",
        builderNames=["heretic2r-builder"]),
    schedulers.ForceScheduler(
        name="heretic2r-publish",
        builderNames=["heretic2r-builder"])
]
