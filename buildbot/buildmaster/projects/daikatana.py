# daikatana

# Project where we build based the latest code.
# Built and published at most once a day, versioned by date (1.3-20261110) --
# see latest_code.py. Upstream's tags are dated snapshots (12-21-2025_Release-4)
# rather than version numbers, and "1.3" is the project's name.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

daikatana_publish_schedulers = {"daikatana-daily", "daikatana-publish"}

project_list = [
    util.Project(name="daikatana",description="daikatana source port project")
]

secretsPath = os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/buildmaster/secrets")

def load_secret(name):
    with open(f"{secretsPath}/{name}") as f:
        return f.read().strip()

github_token = load_secret("githubToken")
repo_url = load_secret("daikatanaUrl")
repoUrl = f"https://{github_token}@{repo_url}"

change_source_list = [
    changes.GitPoller(
        repourl=repoUrl,
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/daikatana-1.3"),
        project="daikatana",
        branches=True,
        pollInterval=3600  # Poll every hour
    )
]

daikatana_factory = util.BuildFactory()

daikatana_factory.addStep(steps.Git(
    repourl=repoUrl,
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/daikatana-1.3"),
    name="Git Pull Latest daikatana Code",
    haltOnFailure=True
))

daikatana_factory.addStep(version_date_step())

daikatana_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/daikatana-1.3/macsourceports_universal2.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/daikatana-1.3"),
    env=version_date_env(),
    name="Run Build Script",
    haltOnFailure=True,
    extract_fn=make_release_extractor("daikatana_dmg_path", "daikatana_version"),
))

daikatana_factory.addStep(RequireProperty(
    "daikatana_dmg_path",
    name="Verify Build Produced a DMG",
    haltOnFailure=True,
))

daikatana_factory.addStep(RequireProperty(
    "daikatana_version",
    name="Verify Build Reported a Version",
    haltOnFailure=True,
))

daikatana_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "daikatana-1.3",
        "--tag", util.Interpolate("daikatana_%(prop:daikatana_version)s"),
        "--version", util.Property('daikatana_version'),
        "--dmg", util.Property('daikatana_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/daikatana-1.3"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, daikatana_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="daikatana-builder", workernames=["worker1"], factory=daikatana_factory, project="daikatana")
]

scheduler_list = [
    daily_scheduler("daikatana", "daikatana-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="daikatana-force",
        builderNames=["daikatana-builder"]),
    schedulers.ForceScheduler(
        name="daikatana-publish",
        builderNames=["daikatana-builder"])
]
