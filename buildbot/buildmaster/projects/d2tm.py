# Dune II - The Maker (D2TM)

# Project where we build based on the latest code of
# stefanhendriks/Dune-II---The-Maker. Its last tagged release is v0.8.5, but
# development is far past it and upstream only publishes several "bleeding
# edge" builds a day. Built and published at most once a day, versioned 0.8.5
# plus the date (0.8.5-20261121) -- see latest_code.py.
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/d2tm/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

d2tm_publish_schedulers = {"d2tm-daily", "d2tm-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
d2tm_guard = CommitGuard("d2tm", force_scheduler_names={"d2tm-force", "d2tm-publish"})

project_list = [
    util.Project(name="d2tm",description="Dune II - The Maker source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/stefanhendriks/Dune-II---The-Maker',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/d2tm"),
        project="d2tm",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

d2tm_factory = util.BuildFactory()

d2tm_factory.addStep(steps.Git(
    repourl='https://github.com/stefanhendriks/Dune-II---The-Maker',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Dune-II---The-Maker"),
    name="Git Pull Latest D2TM Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

d2tm_factory.addStep(version_date_step())
d2tm_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/Dune-II---The-Maker"))

d2tm_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/d2tm/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/d2tm"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=d2tm_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("d2tm_dmg_path", "d2tm_version"),
))

d2tm_factory.addStep(RequireProperty(
    "d2tm_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=d2tm_guard.should_build,
))

d2tm_factory.addStep(RequireProperty(
    "d2tm_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=d2tm_guard.should_build,
))

d2tm_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "d2tm",
        "--tag", util.Interpolate("d2tm_%(prop:d2tm_version)s"),
        "--version", util.Property('d2tm_version'),
        "--dmg", util.Property('d2tm_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Dune-II---The-Maker"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, d2tm_publish_schedulers),
        d2tm_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="d2tm-builder", workernames=["worker1"], factory=d2tm_factory, project="d2tm")
]

scheduler_list = [
    daily_scheduler("d2tm", "d2tm-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="d2tm-force",
        builderNames=["d2tm-builder"]),
    schedulers.ForceScheduler(
        name="d2tm-publish",
        builderNames=["d2tm-builder"])
]
