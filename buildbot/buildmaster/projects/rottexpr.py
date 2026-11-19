# rottexpr

# Project where we build based on the latest code of LTCHIPS/rottexpr. It hasn't
# changed since 2021 (last tag v0.01, which is the current master), so this
# rarely runs: built and published at most once a day, and only if upstream
# changed, versioned 1.0-<date> -- see latest_code.py.
#
# Our change, formerly in the MacSourcePorts fork (game data in
# ~/Library/Application Support/rott/), is applied by the build script from
# MSPBuildSystem/rottexpr/msp-appsupport.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

rottexpr_publish_schedulers = {"rottexpr-daily", "rottexpr-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
rottexpr_guard = CommitGuard("rottexpr", force_scheduler_names={"rottexpr-force", "rottexpr-publish"})

project_list = [
    util.Project(name="rottexpr",description="rottexpr source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/LTCHIPS/rottexpr',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/rottexpr"),
        project="rottexpr",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

rottexpr_factory = util.BuildFactory()

rottexpr_factory.addStep(steps.Git(
    repourl='https://github.com/LTCHIPS/rottexpr',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rottexpr"),
    name="Git Pull Latest rottexpr Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

rottexpr_factory.addStep(version_date_step())
rottexpr_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/rottexpr"))

rottexpr_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/rottexpr/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/rottexpr"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=rottexpr_guard.should_build,
    extract_fn=make_release_extractor("rottexpr_dmg_path", "rottexpr_version"),
))

rottexpr_factory.addStep(RequireProperty(
    "rottexpr_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=rottexpr_guard.should_build,
))

rottexpr_factory.addStep(RequireProperty(
    "rottexpr_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=rottexpr_guard.should_build,
))

rottexpr_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "rottexpr",
        "--tag", util.Interpolate("rottexpr_%(prop:rottexpr_version)s"),
        "--version", util.Property('rottexpr_version'),
        "--dmg", util.Property('rottexpr_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rottexpr"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, rottexpr_publish_schedulers),
        rottexpr_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="rottexpr-builder", workernames=["worker1"], factory=rottexpr_factory, project="rottexpr")
]

scheduler_list = [
    daily_scheduler("rottexpr", "rottexpr-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="rottexpr-force",
        builderNames=["rottexpr-builder"]),
    schedulers.ForceScheduler(
        name="rottexpr-publish",
        builderNames=["rottexpr-builder"])
]
