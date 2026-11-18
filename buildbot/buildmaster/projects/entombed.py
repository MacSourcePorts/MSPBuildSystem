# entombed

# Project where we build based on the latest code of our own repo for Entombed!, which
# has no upstream to follow (its last release was 2007.07.04).
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

entombed_publish_schedulers = {"entombed-daily", "entombed-publish"}

project_list = [
    util.Project(name="entombed", description="entombed source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/entombed',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/entombed"),
        project="entombed",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

entombed_factory = util.BuildFactory()

entombed_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/entombed',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/entombed"),
    name="Git Pull Latest entombed Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

entombed_factory.addStep(version_date_step())

entombed_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/entombed/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/entombed"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("entombed_dmg_path", "entombed_version"),
))

entombed_factory.addStep(RequireProperty(
    "entombed_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

entombed_factory.addStep(RequireProperty(
    "entombed_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

entombed_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "entombed",
        "--tag", util.Interpolate("entombed_%(prop:entombed_version)s"),
        "--version", util.Property('entombed_version'),
        "--dmg", util.Property('entombed_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/entombed"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, entombed_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="entombed-builder", workernames=["worker1"], factory=entombed_factory, project="entombed")
]

scheduler_list = [
    daily_scheduler("entombed", "entombed-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="entombed-force",
        builderNames=["entombed-builder"]),
    schedulers.ForceScheduler(
        name="entombed-publish",
        builderNames=["entombed-builder"])
]
