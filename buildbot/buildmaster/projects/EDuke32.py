# EDuke32

# Project where we build based on the latest code of EDuke32 (voidpoint.io/terminx/eduke32), which doesn't make
# releases -- it's always been a rolling build of master.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

EDuke32_publish_schedulers = {"EDuke32-daily", "EDuke32-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
EDuke32_guard = CommitGuard("EDuke32", force_scheduler_names={"EDuke32-force", "EDuke32-publish"})

project_list = [
    util.Project(name="EDuke32", description="EDuke32 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://voidpoint.io/terminx/eduke32.git',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/EDuke32"),
        project="EDuke32",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

EDuke32_factory = util.BuildFactory()

EDuke32_factory.addStep(steps.Git(
    repourl='https://voidpoint.io/terminx/eduke32.git',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/EDuke32"),
    name="Git Pull Latest EDuke32 Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

EDuke32_factory.addStep(version_date_step())
EDuke32_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/EDuke32"))

EDuke32_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/EDuke32/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/EDuke32"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=EDuke32_guard.should_build,
    extract_fn=make_release_extractor("EDuke32_dmg_path", "EDuke32_version"),
))

EDuke32_factory.addStep(RequireProperty(
    "EDuke32_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=EDuke32_guard.should_build,
))

EDuke32_factory.addStep(RequireProperty(
    "EDuke32_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=EDuke32_guard.should_build,
))

EDuke32_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "EDuke32",
        "--tag", util.Interpolate("EDuke32_%(prop:EDuke32_version)s"),
        "--version", util.Property('EDuke32_version'),
        "--dmg", util.Property('EDuke32_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/EDuke32"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, EDuke32_publish_schedulers),
        EDuke32_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="EDuke32-builder", workernames=["worker1"], factory=EDuke32_factory, project="EDuke32")
]

scheduler_list = [
    daily_scheduler("EDuke32", "EDuke32-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="EDuke32-force",
        builderNames=["EDuke32-builder"]),
    schedulers.ForceScheduler(
        name="EDuke32-publish",
        builderNames=["EDuke32-builder"])
]
