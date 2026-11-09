# jk2mv

# Project where we build based the latest code because we can't update the original.
# Built and published at most once a day, versioned by date (1.4.1-20261109) --
# see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

jk2mv_publish_schedulers = {"jk2mv-daily", "jk2mv-publish"}

project_list = [
    util.Project(name="jk2mv",description="jk2mv source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/mvdevs/jk2mv',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/jk2mv"),
        project="jk2mv",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

jk2mv_factory = util.BuildFactory()

jk2mv_factory.addStep(steps.Git(
    repourl='https://github.com/mvdevs/jk2mv',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/jk2mv"),
    name="Git Pull Latest jk2mv Code",
    haltOnFailure=True,
    submodules=True
))

jk2mv_factory.addStep(version_date_step())

jk2mv_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/jk2mv/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/jk2mv"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("jk2mv_dmg_path", "jk2mv_version"),
))

jk2mv_factory.addStep(RequireProperty(
    "jk2mv_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

jk2mv_factory.addStep(RequireProperty(
    "jk2mv_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

jk2mv_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "jk2mv",
        "--tag", util.Interpolate("jk2mv_%(prop:jk2mv_version)s"),
        "--version", util.Property('jk2mv_version'),
        "--dmg", util.Property('jk2mv_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/jk2mv"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, jk2mv_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="jk2mv-builder", workernames=["worker1"], factory=jk2mv_factory, project="jk2mv")
]

scheduler_list = [
    daily_scheduler("jk2mv", "jk2mv-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="jk2mv-force",
        builderNames=["jk2mv-builder"]),
    schedulers.ForceScheduler(
        name="jk2mv-publish",
        builderNames=["jk2mv-builder"])
]
