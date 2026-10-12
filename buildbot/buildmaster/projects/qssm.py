# QSS-M

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import (
    VersionGuard,
    RecordBuiltTag,
    scheduler_in,
    and_steps,
    make_dmg_extractor,
    is_publish_machine,
    RequireProperty,
)

qssm_guard = VersionGuard(
    project_name="qssm",
    tag_property="qssm_latest_tag",
    force_scheduler_names={"qssm-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="qssm",
)

qssm_publish_schedulers = {"qssm-changes", "qssm-publish"}

project_list = [ 
    util.Project(name="qssm",description="QSS-M source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/timbergeron/QSS-M.git',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/QSS-M"),
        project="qssm",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

qssm_factory = util.BuildFactory()

qssm_factory.addStep(steps.Git(
    repourl='https://github.com/timbergeron/QSS-M.git',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/QSS-M"),
    name="Git Pull Latest QSS-M Code",
    haltOnFailure=True
))

qssm_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/QSS-M"),
    property="qssm_latest_tag",
    name="Fetch Latest QSS-M Tag",
    haltOnFailure=True
))

qssm_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('qssm_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/QSS-M"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=qssm_guard.should_build
))

qssm_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/QSS-M/macsourceports_universal2.sh"), "notarize", util.Property('qssm_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/QSS-M"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=qssm_guard.should_build,
    extract_fn=make_dmg_extractor("qssm_dmg_path"),
))

qssm_factory.addStep(RequireProperty(
    "qssm_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=qssm_guard.should_build,
    haltOnFailure=True,
))

qssm_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "QSS-M",
        "--tag", util.Interpolate("QSS-M_%(prop:QSS-M_latest_tag)s"),
        "--version", util.Property('qssm_latest_tag'),
        "--dmg", util.Property('qssm_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/QSS-M"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, qssm_publish_schedulers),
        qssm_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

qssm_factory.addStep(RecordBuiltTag(qssm_guard, doStepIf=qssm_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="qssm-builder", workernames=["worker1"], factory=qssm_factory, project="qssm")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="qssm-changes",
        change_filter=util.ChangeFilter(project='qssm', branch='stable'),
        treeStableTimer=60,
        builderNames=["qssm-builder"]),
    schedulers.ForceScheduler(
        name="qssm-force",
        builderNames=["qssm-builder"]),
    schedulers.ForceScheduler(
        name="qssm-publish",
        builderNames=["qssm-builder"])
]