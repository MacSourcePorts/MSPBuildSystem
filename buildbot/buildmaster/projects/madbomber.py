# madbomber

# Project where we build based on the latest code of our own repo for Mad Bomber, which
# has no upstream to follow (its last release was 0.2.5).
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

madbomber_publish_schedulers = {"madbomber-daily", "madbomber-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
madbomber_guard = CommitGuard("madbomber", force_scheduler_names={"madbomber-force", "madbomber-publish"})

project_list = [
    util.Project(name="madbomber", description="madbomber source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/madbomber',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/madbomber"),
        project="madbomber",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

madbomber_factory = util.BuildFactory()

madbomber_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/madbomber',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/madbomber"),
    name="Git Pull Latest madbomber Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

madbomber_factory.addStep(version_date_step())
madbomber_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/madbomber"))

madbomber_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/madbomber/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/madbomber"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=madbomber_guard.should_build,
    extract_fn=make_release_extractor("madbomber_dmg_path", "madbomber_version"),
))

madbomber_factory.addStep(RequireProperty(
    "madbomber_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=madbomber_guard.should_build,
))

madbomber_factory.addStep(RequireProperty(
    "madbomber_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=madbomber_guard.should_build,
))

madbomber_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "madbomber",
        "--tag", util.Interpolate("madbomber_%(prop:madbomber_version)s"),
        "--version", util.Property('madbomber_version'),
        "--dmg", util.Property('madbomber_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/madbomber"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, madbomber_publish_schedulers),
        madbomber_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="madbomber-builder", workernames=["worker1"], factory=madbomber_factory, project="madbomber")
]

scheduler_list = [
    daily_scheduler("madbomber", "madbomber-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="madbomber-force",
        builderNames=["madbomber-builder"]),
    schedulers.ForceScheduler(
        name="madbomber-publish",
        builderNames=["madbomber-builder"])
]
