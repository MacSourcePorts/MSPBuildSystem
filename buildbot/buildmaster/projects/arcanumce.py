# arcanumce

# Project where we build based on the latest code of alexbatalov/arcanum-ce, which has no releases.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

arcanumce_publish_schedulers = {"arcanumce-daily", "arcanumce-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
arcanumce_guard = CommitGuard("arcanum-ce", force_scheduler_names={"arcanumce-force", "arcanumce-publish"})

project_list = [
    util.Project(name="arcanumce", description="arcanumce source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/alexbatalov/arcanum-ce',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/arcanumce"),
        project="arcanumce",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

arcanumce_factory = util.BuildFactory()

arcanumce_factory.addStep(steps.Git(
    repourl='https://github.com/alexbatalov/arcanum-ce',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/arcanum-ce"),
    name="Git Pull Latest arcanumce Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

arcanumce_factory.addStep(version_date_step())
arcanumce_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/arcanum-ce"))

arcanumce_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/arcanum-ce/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/arcanum-ce"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=arcanumce_guard.should_build,
    extract_fn=make_release_extractor("arcanumce_dmg_path", "arcanumce_version"),
))

arcanumce_factory.addStep(RequireProperty(
    "arcanumce_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=arcanumce_guard.should_build,
))

arcanumce_factory.addStep(RequireProperty(
    "arcanumce_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=arcanumce_guard.should_build,
))

arcanumce_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "arcanum-ce",
        "--tag", util.Interpolate("arcanumce_%(prop:arcanumce_version)s"),
        "--version", util.Property('arcanumce_version'),
        "--dmg", util.Property('arcanumce_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/arcanum-ce"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, arcanumce_publish_schedulers),
        arcanumce_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="arcanumce-builder", workernames=["worker1"], factory=arcanumce_factory, project="arcanumce")
]

scheduler_list = [
    daily_scheduler("arcanumce", "arcanumce-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="arcanumce-force",
        builderNames=["arcanumce-builder"]),
    schedulers.ForceScheduler(
        name="arcanumce-publish",
        builderNames=["arcanumce-builder"])
]
