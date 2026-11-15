# systemshock (Shockolate)

# Project where we build based the latest code because upstream stopped making
# releases (last release v0.7.7, last tag v0.8.2). Built and published at most
# once a day, versioned by the last tag plus the date (0.8.2-20261114) -- see
# latest_code.py.
#
# Formerly built from the MacSourcePorts/systemshock fork; everything in it
# has been merged upstream.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

systemshock_publish_schedulers = {"systemshock-daily", "systemshock-publish"}

project_list = [
    util.Project(name="systemshock",description="systemshock source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/interrupt/systemshock',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/systemshock"),
        project="systemshock",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

systemshock_factory = util.BuildFactory()

systemshock_factory.addStep(steps.Git(
    repourl='https://github.com/interrupt/systemshock',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/systemshock"),
    name="Git Pull Latest systemshock Code",
    haltOnFailure=True
))

systemshock_factory.addStep(version_date_step())

systemshock_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/systemshock/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/systemshock"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("systemshock_dmg_path", "systemshock_version"),
))

systemshock_factory.addStep(RequireProperty(
    "systemshock_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

systemshock_factory.addStep(RequireProperty(
    "systemshock_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

systemshock_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "systemshock",
        "--tag", util.Interpolate("systemshock_%(prop:systemshock_version)s"),
        "--version", util.Property('systemshock_version'),
        "--dmg", util.Property('systemshock_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/systemshock"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, systemshock_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="systemshock-builder", workernames=["worker1"], factory=systemshock_factory, project="systemshock")
]

scheduler_list = [
    daily_scheduler("systemshock", "systemshock-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="systemshock-force",
        builderNames=["systemshock-builder"]),
    schedulers.ForceScheduler(
        name="systemshock-publish",
        builderNames=["systemshock-builder"])
]
