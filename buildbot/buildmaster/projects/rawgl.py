# rawgl

# Project where we build based on the latest code of our fork of cyxx/rawgl, which has no releases. Our fork is where the
# macOS work lives.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

rawgl_publish_schedulers = {"rawgl-daily", "rawgl-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
rawgl_guard = CommitGuard("rawgl", force_scheduler_names={"rawgl-force", "rawgl-publish"})

project_list = [
    util.Project(name="rawgl", description="rawgl source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/rawgl',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/rawgl"),
        project="rawgl",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

rawgl_factory = util.BuildFactory()

rawgl_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/rawgl',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rawgl"),
    name="Git Pull Latest rawgl Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

rawgl_factory.addStep(version_date_step())
rawgl_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/rawgl"))

rawgl_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/rawgl/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/rawgl"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=rawgl_guard.should_build,
    extract_fn=make_release_extractor("rawgl_dmg_path", "rawgl_version"),
))

rawgl_factory.addStep(RequireProperty(
    "rawgl_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=rawgl_guard.should_build,
))

rawgl_factory.addStep(RequireProperty(
    "rawgl_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=rawgl_guard.should_build,
))

rawgl_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "rawgl",
        "--tag", util.Interpolate("rawgl_%(prop:rawgl_version)s"),
        "--version", util.Property('rawgl_version'),
        "--dmg", util.Property('rawgl_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rawgl"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, rawgl_publish_schedulers),
        rawgl_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="rawgl-builder", workernames=["worker1"], factory=rawgl_factory, project="rawgl")
]

scheduler_list = [
    daily_scheduler("rawgl", "rawgl-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="rawgl-force",
        builderNames=["rawgl-builder"]),
    schedulers.ForceScheduler(
        name="rawgl-publish",
        builderNames=["rawgl-builder"])
]
