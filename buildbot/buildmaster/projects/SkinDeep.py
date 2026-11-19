# SkinDeep

# Project where we build based the latest code because there are no releases:
# the game's source (blendogames/SkinDeep) was published once, and the macOS
# port lives on the macos branch of our fork of m0rb's Linux fork. Built and
# published at most once a day, versioned by the game's own version plus the
# date (1.0.4-20261115) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

SkinDeep_publish_schedulers = {"SkinDeep-daily", "SkinDeep-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
SkinDeep_guard = CommitGuard("SkinDeep", force_scheduler_names={"SkinDeep-force", "SkinDeep-publish"})

project_list = [
    util.Project(name="SkinDeep", description="Skin Deep source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/SkinDeep',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/SkinDeep"),
        project="SkinDeep",
        branches=["macos"],
        pollInterval=3600  # Poll every hour
    )
]

SkinDeep_factory = util.BuildFactory()

SkinDeep_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/SkinDeep',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    branch='macos',
    alwaysUseLatest=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/SkinDeep"),
    name="Git Pull Latest SkinDeep Code",
    haltOnFailure=True
))

SkinDeep_factory.addStep(version_date_step())
SkinDeep_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/SkinDeep"))

SkinDeep_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/SkinDeep/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/SkinDeep"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=SkinDeep_guard.should_build,
    extract_fn=make_release_extractor("SkinDeep_dmg_path", "SkinDeep_version"),
))

SkinDeep_factory.addStep(RequireProperty(
    "SkinDeep_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
    doStepIf=SkinDeep_guard.should_build,
))

SkinDeep_factory.addStep(RequireProperty(
    "SkinDeep_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=SkinDeep_guard.should_build,
))

SkinDeep_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "SkinDeep",
        "--tag", util.Interpolate("SkinDeep_%(prop:SkinDeep_version)s"),
        "--version", util.Property('SkinDeep_version'),
        "--dmg", util.Property('SkinDeep_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/SkinDeep"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, SkinDeep_publish_schedulers),
        SkinDeep_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="SkinDeep-builder", workernames=["worker1"], factory=SkinDeep_factory, project="SkinDeep")
]

scheduler_list = [
    daily_scheduler("SkinDeep", "SkinDeep-builder", branches=["macos"]),
    schedulers.ForceScheduler(
        name="SkinDeep-force",
        builderNames=["SkinDeep-builder"]),
    schedulers.ForceScheduler(
        name="SkinDeep-publish",
        builderNames=["SkinDeep-builder"])
]
