# OpenJK

# Project where we build based the latest code because we can't update the original.
# Built and published at most once a day, versioned by date -- OpenJK has no
# version number of its own, so the version is just the date (20261109).
# See latest_code.py.
#
# One build makes three apps, each its own port on the site: OpenJK-SP,
# OpenJK-MP and OpenJO-SP. They're published together as one release.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, dmg_args

OpenJK_publish_schedulers = {"OpenJK-daily", "OpenJK-publish"}

project_list = [
    util.Project(name="OpenJK",description="OpenJK source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/JACoders/OpenJK',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenJK"),
        project="OpenJK",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenJK_factory = util.BuildFactory()

OpenJK_factory.addStep(steps.Git(
    repourl='https://github.com/JACoders/OpenJK',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJK"),
    name="Git Pull Latest OpenJK Code",
    haltOnFailure=True
))

OpenJK_factory.addStep(version_date_step())

OpenJK_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJK/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJK"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("OpenJK_dmg_paths", "OpenJK_version", dmg_count=3),
))

OpenJK_factory.addStep(RequireProperty(
    "OpenJK_dmg_paths",
    name="Verify Build Produced All Three DMGs",
    haltOnFailure=True,
))

OpenJK_factory.addStep(RequireProperty(
    "OpenJK_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

OpenJK_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenJK",
        "--tag", util.Interpolate("OpenJK_%(prop:OpenJK_version)s"),
        "--version", util.Property('OpenJK_version'),
        dmg_args("OpenJK_dmg_paths"),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJK"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenJK_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="OpenJK-builder", workernames=["worker1"], factory=OpenJK_factory, project="OpenJK")
]

scheduler_list = [
    daily_scheduler("OpenJK", "OpenJK-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="OpenJK-force",
        builderNames=["OpenJK-builder"]),
    schedulers.ForceScheduler(
        name="OpenJK-publish",
        builderNames=["OpenJK-builder"])
]
