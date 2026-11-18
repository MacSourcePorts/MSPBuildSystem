# vectoroids

# Project where we build based on the latest code of our own repo for Vectoroids, which
# has no upstream to follow (its last release was 1.1.0).
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

vectoroids_publish_schedulers = {"vectoroids-daily", "vectoroids-publish"}

project_list = [
    util.Project(name="vectoroids", description="vectoroids source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/vectoroids',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/vectoroids"),
        project="vectoroids",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

vectoroids_factory = util.BuildFactory()

vectoroids_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/vectoroids',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vectoroids"),
    name="Git Pull Latest vectoroids Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

vectoroids_factory.addStep(version_date_step())

vectoroids_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/vectoroids/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/vectoroids"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("vectoroids_dmg_path", "vectoroids_version"),
))

vectoroids_factory.addStep(RequireProperty(
    "vectoroids_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

vectoroids_factory.addStep(RequireProperty(
    "vectoroids_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

vectoroids_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "vectoroids",
        "--tag", util.Interpolate("vectoroids_%(prop:vectoroids_version)s"),
        "--version", util.Property('vectoroids_version'),
        "--dmg", util.Property('vectoroids_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/vectoroids"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, vectoroids_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="vectoroids-builder", workernames=["worker1"], factory=vectoroids_factory, project="vectoroids")
]

scheduler_list = [
    daily_scheduler("vectoroids", "vectoroids-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="vectoroids-force",
        builderNames=["vectoroids-builder"]),
    schedulers.ForceScheduler(
        name="vectoroids-publish",
        builderNames=["vectoroids-builder"])
]
