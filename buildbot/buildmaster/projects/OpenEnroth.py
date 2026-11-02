# OpenEnroth

# Project where we build based the latest code because we can't update the original.
# Built and published at most once a day, versioned by date (0.1-20261030) --
# see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

OpenEnroth_publish_schedulers = {"OpenEnroth-daily", "OpenEnroth-publish"}

project_list = [ 
    util.Project(name="OpenEnroth",description="OpenEnroth source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/OpenEnroth/OpenEnroth',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenEnroth"),
        project="OpenEnroth",
        branches=True,
        pollAtLaunch=True,
        pollInterval=3600  # Poll every hour
    )
]

OpenEnroth_factory = util.BuildFactory()

OpenEnroth_factory.addStep(steps.Git(
    repourl='https://github.com/OpenEnroth/OpenEnroth',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenEnroth"),
    name="Git Pull Latest OpenEnroth Code",
    haltOnFailure=True
))

OpenEnroth_factory.addStep(version_date_step())

OpenEnroth_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenEnroth/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenEnroth"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("OpenEnroth_dmg_path", "OpenEnroth_version"),
))

OpenEnroth_factory.addStep(RequireProperty(
    "OpenEnroth_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

OpenEnroth_factory.addStep(RequireProperty(
    "OpenEnroth_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

OpenEnroth_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "OpenEnroth",
        "--tag", util.Interpolate("OpenEnroth_%(prop:OpenEnroth_version)s"),
        "--version", util.Property('OpenEnroth_version'),
        "--dmg", util.Property('OpenEnroth_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenEnroth"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, OpenEnroth_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="OpenEnroth-builder", workernames=["worker1"], factory=OpenEnroth_factory, project="OpenEnroth")
]

scheduler_list = [ 
    daily_scheduler("OpenEnroth", "OpenEnroth-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="OpenEnroth-force",
        builderNames=["OpenEnroth-builder"]),
    schedulers.ForceScheduler(
        name="OpenEnroth-publish",
        builderNames=["OpenEnroth-builder"])
]