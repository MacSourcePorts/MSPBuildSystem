# uhexen2

# Project where we build based the latest code because we can't update the original.
# Built and published at most once a day, versioned by date (1.5.10-20261109) --
# see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

uhexen2_publish_schedulers = {"uhexen2-daily", "uhexen2-publish"}

project_list = [
    util.Project(name="uhexen2",description="uhexen2 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/sezero/uhexen2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/uhexen2"),
        project="uhexen2",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

uhexen2_factory = util.BuildFactory()

uhexen2_factory.addStep(steps.Git(
    repourl='https://github.com/sezero/uhexen2',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/uhexen2"),
    name="Git Pull Latest uhexen2 Code",
    haltOnFailure=True
))

uhexen2_factory.addStep(version_date_step())

uhexen2_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/uhexen2/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/uhexen2"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("uhexen2_dmg_path", "uhexen2_version"),
))

uhexen2_factory.addStep(RequireProperty(
    "uhexen2_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

uhexen2_factory.addStep(RequireProperty(
    "uhexen2_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

uhexen2_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "uhexen2",
        "--tag", util.Interpolate("uhexen2_%(prop:uhexen2_version)s"),
        "--version", util.Property('uhexen2_version'),
        "--dmg", util.Property('uhexen2_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/uhexen2"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, uhexen2_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="uhexen2-builder", workernames=["worker1"], factory=uhexen2_factory, project="uhexen2")
]

scheduler_list = [
    daily_scheduler("uhexen2", "uhexen2-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="uhexen2-force",
        builderNames=["uhexen2-builder"]),
    schedulers.ForceScheduler(
        name="uhexen2-publish",
        builderNames=["uhexen2-builder"])
]
