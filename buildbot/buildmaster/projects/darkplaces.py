# darkplaces

# Project where we build based the latest code because we can't update the original.
# Built and published at most once a day, versioned by date -- DarkPlaces has
# no version number of its own, so the version is just the date (20261109).
# See latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

darkplaces_publish_schedulers = {"darkplaces-daily", "darkplaces-publish"}

project_list = [
    util.Project(name="darkplaces",description="darkplaces source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/DarkPlacesEngine/DarkPlaces',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/darkplaces"),
        project="darkplaces",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

darkplaces_factory = util.BuildFactory()

darkplaces_factory.addStep(steps.Git(
    repourl='https://github.com/DarkPlacesEngine/DarkPlaces',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/darkplaces"),
    name="Git Pull Latest darkplaces Code",
    haltOnFailure=True
))

darkplaces_factory.addStep(version_date_step())

darkplaces_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/darkplaces/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/darkplaces"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("darkplaces_dmg_path", "darkplaces_version"),
))

darkplaces_factory.addStep(RequireProperty(
    "darkplaces_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

darkplaces_factory.addStep(RequireProperty(
    "darkplaces_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

darkplaces_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "darkplaces",
        "--tag", util.Interpolate("darkplaces_%(prop:darkplaces_version)s"),
        "--version", util.Property('darkplaces_version'),
        "--dmg", util.Property('darkplaces_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/darkplaces"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, darkplaces_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="darkplaces-builder", workernames=["worker1"], factory=darkplaces_factory, project="darkplaces")
]

scheduler_list = [
    daily_scheduler("darkplaces", "darkplaces-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="darkplaces-force",
        builderNames=["darkplaces-builder"]),
    schedulers.ForceScheduler(
        name="darkplaces-publish",
        builderNames=["darkplaces-builder"])
]
