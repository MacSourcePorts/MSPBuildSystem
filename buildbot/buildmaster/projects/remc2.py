# remc2 / Magic Carpet HD (Magic Carpet 2, and Magic Carpet / Hidden Worlds)

# Project where we build based on the latest code of turican0/remc2's
# development branch. Its releases are tagged <version>-<label> (e.g.
# 0.9.18.0-alpha-looking-glass), but the Magic Carpet / Hidden Worlds support
# (remc1) and the launcher's Play button for each game came after the newest
# one, 0.9.18.0. Built and published at most once a day, versioned the
# build script's version plus the date (0.9.18.0-20261126) -- see
# latest_code.py. Once a release tag has remc1 this can go back to building
# tags (projects/OpenApoc.py; skip the old 0.90 ... 0.99 tags, which sort
# above 0.9.x).
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/remc2/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

remc2_publish_schedulers = {"remc2-daily", "remc2-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
remc2_guard = CommitGuard("remc2", force_scheduler_names={"remc2-force", "remc2-publish"})

project_list = [
    util.Project(name="remc2",description="remc2 (Magic Carpet HD) source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/turican0/remc2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/remc2"),
        project="remc2",
        branches=["development"],
        pollInterval=3600  # Poll every hour
    )
]

remc2_factory = util.BuildFactory()

remc2_factory.addStep(steps.Git(
    repourl='https://github.com/turican0/remc2',
    branch='development',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/remc2"),
    name="Git Pull Latest remc2 Code",
    alwaysUseLatest=True,
    haltOnFailure=True,
    submodules=True
))

remc2_factory.addStep(version_date_step())
remc2_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/remc2"))

remc2_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/remc2/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/remc2"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=remc2_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("remc2_dmg_path", "remc2_version"),
))

remc2_factory.addStep(RequireProperty(
    "remc2_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=remc2_guard.should_build,
))

remc2_factory.addStep(RequireProperty(
    "remc2_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=remc2_guard.should_build,
))

remc2_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "remc2",
        "--tag", util.Interpolate("remc2_%(prop:remc2_version)s"),
        "--version", util.Property('remc2_version'),
        "--dmg", util.Property('remc2_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/remc2"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, remc2_publish_schedulers),
        remc2_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="remc2-builder", workernames=["worker1"], factory=remc2_factory, project="remc2")
]

scheduler_list = [
    daily_scheduler("remc2", "remc2-builder", branches=["development"]),
    schedulers.ForceScheduler(
        name="remc2-force",
        builderNames=["remc2-builder"]),
    schedulers.ForceScheduler(
        name="remc2-publish",
        builderNames=["remc2-builder"])
]
