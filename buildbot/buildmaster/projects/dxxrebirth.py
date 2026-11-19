# dxx-rebirth

# Project where we build based on the latest code because the latest tag is
# too old. Built and published at most once a day, versioned by the build
# script's APP_VERSION plus the date (0.6.0-20261116) -- see latest_code.py.
#
# One build makes two apps, each its own port on the site: D1X-Rebirth and
# D2X-Rebirth. They're published together as one release.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, dmg_args, CommitGuard, last_commit_date_step

dxxrebirth_publish_schedulers = {"dxx-rebirth-daily", "dxx-rebirth-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
dxxrebirth_guard = CommitGuard("dxx-rebirth", force_scheduler_names={"dxx-rebirth-force", "dxx-rebirth-publish"})

project_list = [
    util.Project(name="dxx-rebirth",description="dxx-rebirth source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/dxx-rebirth/dxx-rebirth',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/dxx-rebirth"),
        project="dxx-rebirth",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

dxxrebirth_factory = util.BuildFactory()

dxxrebirth_factory.addStep(steps.Git(
    repourl='https://github.com/dxx-rebirth/dxx-rebirth',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dxx-rebirth"),
    name="Git Pull Latest dxx-rebirth Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

dxxrebirth_factory.addStep(version_date_step())
dxxrebirth_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/dxx-rebirth"))

dxxrebirth_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dxx-rebirth/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/dxx-rebirth"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=dxxrebirth_guard.should_build,
    extract_fn=make_release_extractor("dxxrebirth_dmg_paths", "dxxrebirth_version", dmg_count=2),
))

dxxrebirth_factory.addStep(RequireProperty(
    "dxxrebirth_dmg_paths",
    name="Verify Build Produced Both DMGs",
    haltOnFailure=True,
    doStepIf=dxxrebirth_guard.should_build,
))

dxxrebirth_factory.addStep(RequireProperty(
    "dxxrebirth_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
    doStepIf=dxxrebirth_guard.should_build,
))

dxxrebirth_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "dxx-rebirth",
        "--tag", util.Interpolate("dxxrebirth_%(prop:dxxrebirth_version)s"),
        "--version", util.Property('dxxrebirth_version'),
        dmg_args("dxxrebirth_dmg_paths"),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/dxx-rebirth"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, dxxrebirth_publish_schedulers),
        dxxrebirth_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="dxx-rebirth-builder", workernames=["worker1"], factory=dxxrebirth_factory, project="dxx-rebirth")
]

scheduler_list = [
    daily_scheduler("dxx-rebirth", "dxx-rebirth-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="dxx-rebirth-force",
        builderNames=["dxx-rebirth-builder"]),
    schedulers.ForceScheduler(
        name="dxx-rebirth-publish",
        builderNames=["dxx-rebirth-builder"])
]
