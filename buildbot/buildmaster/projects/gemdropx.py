# gemdropx

# Project where we build based on the latest code of our own repo for Gem Drop X, which
# has no upstream to follow (its last release was 0.9).
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

gemdropx_publish_schedulers = {"gemdropx-daily", "gemdropx-publish"}

project_list = [
    util.Project(name="gemdropx", description="gemdropx source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/gemdropx',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/gemdropx"),
        project="gemdropx",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

gemdropx_factory = util.BuildFactory()

gemdropx_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/gemdropx',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/gemdropx"),
    name="Git Pull Latest gemdropx Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

gemdropx_factory.addStep(version_date_step())

gemdropx_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/gemdropx/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/gemdropx"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("gemdropx_dmg_path", "gemdropx_version"),
))

gemdropx_factory.addStep(RequireProperty(
    "gemdropx_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

gemdropx_factory.addStep(RequireProperty(
    "gemdropx_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

gemdropx_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "gemdropx",
        "--tag", util.Interpolate("gemdropx_%(prop:gemdropx_version)s"),
        "--version", util.Property('gemdropx_version'),
        "--dmg", util.Property('gemdropx_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/gemdropx"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, gemdropx_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="gemdropx-builder", workernames=["worker1"], factory=gemdropx_factory, project="gemdropx")
]

scheduler_list = [
    daily_scheduler("gemdropx", "gemdropx-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="gemdropx-force",
        builderNames=["gemdropx-builder"]),
    schedulers.ForceScheduler(
        name="gemdropx-publish",
        builderNames=["gemdropx-builder"])
]
