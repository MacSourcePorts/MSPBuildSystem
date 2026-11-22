# Dune Dynasty

# Project where we build based on the latest code of gameflorist/dunedynasty,
# the maintained continuation of the SourceForge project (whose last release
# was 1.5.7 in 2013). Its last release is v1.6.4; built and published at most
# once a day, versioned 1.6.4 plus the date (1.6.4-20261121) -- see
# latest_code.py.
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/dunedynasty/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

dunedynasty_publish_schedulers = {"dunedynasty-daily", "dunedynasty-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
dunedynasty_guard = CommitGuard("dunedynasty", force_scheduler_names={"dunedynasty-force", "dunedynasty-publish"})

project_list = [
    util.Project(name="dunedynasty",description="Dune Dynasty source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/gameflorist/dunedynasty',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/dunedynasty"),
        project="dunedynasty",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

dunedynasty_factory = util.BuildFactory()

dunedynasty_factory.addStep(steps.Git(
    repourl='https://github.com/gameflorist/dunedynasty',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dunedynasty"),
    name="Git Pull Latest Dune Dynasty Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

dunedynasty_factory.addStep(version_date_step())
dunedynasty_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/dunedynasty"))

dunedynasty_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dunedynasty/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dunedynasty"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=dunedynasty_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("dunedynasty_dmg_path", "dunedynasty_version"),
))

dunedynasty_factory.addStep(RequireProperty(
    "dunedynasty_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=dunedynasty_guard.should_build,
))

dunedynasty_factory.addStep(RequireProperty(
    "dunedynasty_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=dunedynasty_guard.should_build,
))

dunedynasty_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "dunedynasty",
        "--tag", util.Interpolate("dunedynasty_%(prop:dunedynasty_version)s"),
        "--version", util.Property('dunedynasty_version'),
        "--dmg", util.Property('dunedynasty_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dunedynasty"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, dunedynasty_publish_schedulers),
        dunedynasty_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="dunedynasty-builder", workernames=["worker1"], factory=dunedynasty_factory, project="dunedynasty")
]

scheduler_list = [
    daily_scheduler("dunedynasty", "dunedynasty-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="dunedynasty-force",
        builderNames=["dunedynasty-builder"]),
    schedulers.ForceScheduler(
        name="dunedynasty-publish",
        builderNames=["dunedynasty-builder"])
]
