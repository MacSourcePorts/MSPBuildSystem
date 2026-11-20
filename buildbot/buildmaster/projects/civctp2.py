# civctp2 (Call to Power II)

# Project where we build based on the latest code of civctp2/civctp2, whose
# only releases are occasional dated "Apolyton Edition" packages. Built and
# published at most once a day, versioned by the date alone (20261119, as
# with DarkPlaces) -- see latest_code.py.
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/civctp2/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

civctp2_publish_schedulers = {"civctp2-daily", "civctp2-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
civctp2_guard = CommitGuard("civctp2", force_scheduler_names={"civctp2-force", "civctp2-publish"})

project_list = [
    util.Project(name="civctp2",description="Call to Power II source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/civctp2/civctp2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/civctp2"),
        project="civctp2",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

civctp2_factory = util.BuildFactory()

civctp2_factory.addStep(steps.Git(
    repourl='https://github.com/civctp2/civctp2',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/civctp2"),
    name="Git Pull Latest civctp2 Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

civctp2_factory.addStep(version_date_step())
civctp2_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/civctp2"))

civctp2_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/civctp2/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/civctp2"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=civctp2_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("civctp2_dmg_path", "civctp2_version"),
))

civctp2_factory.addStep(RequireProperty(
    "civctp2_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=civctp2_guard.should_build,
))

civctp2_factory.addStep(RequireProperty(
    "civctp2_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=civctp2_guard.should_build,
))

civctp2_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "civctp2",
        "--tag", util.Interpolate("civctp2_%(prop:civctp2_version)s"),
        "--version", util.Property('civctp2_version'),
        "--dmg", util.Property('civctp2_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/civctp2"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, civctp2_publish_schedulers),
        civctp2_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="civctp2-builder", workernames=["worker1"], factory=civctp2_factory, project="civctp2")
]

scheduler_list = [
    daily_scheduler("civctp2", "civctp2-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="civctp2-force",
        builderNames=["civctp2-builder"]),
    schedulers.ForceScheduler(
        name="civctp2-publish",
        builderNames=["civctp2-builder"])
]
