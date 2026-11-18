# iortcw

# Project where we build based on the latest code of iortcw/iortcw, whose
# last release (1.51c) is from 2019. Built and published at most once a day,
# and only if the code changed, versioned by the Makefile's VERSION plus the
# date (1.51c-20261117) -- see latest_code.py. Single player and multiplayer
# are two apps and two DMGs, published together.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, dmg_args

iortcw_publish_schedulers = {"iortcw-daily", "iortcw-publish"}

project_list = [
    util.Project(name="iortcw", description="iortcw source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/iortcw/iortcw',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/iortcw"),
        project="iortcw",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

iortcw_factory = util.BuildFactory()

iortcw_factory.addStep(steps.Git(
    repourl='https://github.com/iortcw/iortcw',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/iortcw"),
    name="Git Pull Latest iortcw Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

iortcw_factory.addStep(version_date_step())

iortcw_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/iortcw/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/iortcw"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("iortcw_dmg_paths", "iortcw_version", dmg_count=2),
))

iortcw_factory.addStep(RequireProperty(
    "iortcw_dmg_paths",
    name="Verify Build Produced its DMGs",
    haltOnFailure=True,
))

iortcw_factory.addStep(RequireProperty(
    "iortcw_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

iortcw_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "iortcw",
        "--tag", util.Interpolate("iortcw_%(prop:iortcw_version)s"),
        "--version", util.Property('iortcw_version'),
        dmg_args("iortcw_dmg_paths"),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/iortcw"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, iortcw_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="iortcw-builder", workernames=["worker1"], factory=iortcw_factory, project="iortcw")
]

scheduler_list = [
    daily_scheduler("iortcw", "iortcw-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="iortcw-force",
        builderNames=["iortcw-builder"]),
    schedulers.ForceScheduler(
        name="iortcw-publish",
        builderNames=["iortcw-builder"])
]
