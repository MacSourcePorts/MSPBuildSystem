# daikatana

# Project where we build based the latest code

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="daikatana",description="daikatana source port project")
]

# TODO: migrate this to GitAuth before exposing any Buildbot stuff to the web.

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
daikatana_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/daikatana-1.3/macsourceports_universal2.sh"), "notarize", "buildserver"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/daikatana-1.3"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="daikatana-builder", workernames=["worker1"], factory=daikatana_factory, project="daikatana")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="daikatana-changes",
        change_filter=util.ChangeFilter(project='daikatana', branch='master'),
        treeStableTimer=None,
        builderNames=["daikatana-builder"]),
    schedulers.ForceScheduler(
        name="daikatana-force",
        builderNames=["daikatana-builder"])
]