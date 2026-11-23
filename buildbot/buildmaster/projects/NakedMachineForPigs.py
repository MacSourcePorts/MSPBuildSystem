# NakedMachineForPigs (Amnesia: A Machine for Pigs)

# Project where we build based on the latest code of atsb/NakedMachineForPigs.
# Its last tag (1.1, 2024) still needs Autodesk's closed FBX SDK; master
# dropped that (and fixed the Linux build) in 2025. Built and published at
# most once a day, versioned 1.1 plus the date (1.1-20261123) -- see
# latest_code.py.
#
# Our macOS changes are applied by the build script from
# MSPBuildSystem/NakedMachineForPigs/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

NakedMachineForPigs_publish_schedulers = {"NakedMachineForPigs-daily", "NakedMachineForPigs-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
NakedMachineForPigs_guard = CommitGuard("NakedMachineForPigs", force_scheduler_names={"NakedMachineForPigs-force", "NakedMachineForPigs-publish"})

project_list = [
    util.Project(name="NakedMachineForPigs",description="NakedMachineForPigs (Amnesia: A Machine for Pigs) source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/atsb/NakedMachineForPigs',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/NakedMachineForPigs"),
        project="NakedMachineForPigs",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

NakedMachineForPigs_factory = util.BuildFactory()

NakedMachineForPigs_factory.addStep(steps.Git(
    repourl='https://github.com/atsb/NakedMachineForPigs',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedMachineForPigs"),
    name="Git Pull Latest NakedMachineForPigs Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

NakedMachineForPigs_factory.addStep(version_date_step())
NakedMachineForPigs_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/NakedMachineForPigs"))

NakedMachineForPigs_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/NakedMachineForPigs/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/NakedMachineForPigs"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=NakedMachineForPigs_guard.should_build,
    timeout=3600,
    extract_fn=make_release_extractor("NakedMachineForPigs_dmg_path", "NakedMachineForPigs_version"),
))

NakedMachineForPigs_factory.addStep(RequireProperty(
    "NakedMachineForPigs_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=NakedMachineForPigs_guard.should_build,
))

NakedMachineForPigs_factory.addStep(RequireProperty(
    "NakedMachineForPigs_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=NakedMachineForPigs_guard.should_build,
))

NakedMachineForPigs_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "NakedMachineForPigs",
        "--tag", util.Interpolate("NakedMachineForPigs_%(prop:NakedMachineForPigs_version)s"),
        "--version", util.Property('NakedMachineForPigs_version'),
        "--dmg", util.Property('NakedMachineForPigs_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedMachineForPigs"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, NakedMachineForPigs_publish_schedulers),
        NakedMachineForPigs_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="NakedMachineForPigs-builder", workernames=["worker1"], factory=NakedMachineForPigs_factory, project="NakedMachineForPigs")
]

scheduler_list = [
    daily_scheduler("NakedMachineForPigs", "NakedMachineForPigs-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="NakedMachineForPigs-force",
        builderNames=["NakedMachineForPigs-builder"]),
    schedulers.ForceScheduler(
        name="NakedMachineForPigs-publish",
        builderNames=["NakedMachineForPigs-builder"])
]
