# RBDOOM-3-BFG

# Project where we build based off of release tags from the GitHub releases of RobertBeckebans/RBDOOM-3-BFG.
# The tag is passed to the build script, which uses it as the version.

import os
import re
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import (
    VersionGuard,
    RecordBuiltTag,
    scheduler_in,
    and_steps,
    is_publish_machine,
    RequireProperty,
)
from projects.latest_code import make_release_extractor

_RBDOOM3BFG_release_re = re.compile(r'^v\d+(\.\d+)+$')

RBDOOM3BFG_guard = VersionGuard(
    project_name="RBDOOM-3-BFG",
    tag_property="RBDOOM3BFG_latest_tag",
    tag_filter=lambda tag: bool(_RBDOOM3BFG_release_re.match(tag)),
    force_scheduler_names={"RBDOOM-3-BFG-force", "RBDOOM-3-BFG-forcepublish"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="rbdoom3bfg",
)

RBDOOM3BFG_publish_schedulers = {"RBDOOM-3-BFG-changes", "RBDOOM-3-BFG-publish", "RBDOOM-3-BFG-forcepublish"}

project_list = [
    util.Project(name="RBDOOM-3-BFG", description="RBDOOM-3-BFG source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/RobertBeckebans/RBDOOM-3-BFG',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/RBDOOM-3-BFG"),
        project="RBDOOM-3-BFG",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

RBDOOM3BFG_factory = util.BuildFactory()

RBDOOM3BFG_factory.addStep(steps.Git(
    repourl='https://github.com/RobertBeckebans/RBDOOM-3-BFG',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/RBDOOM-3-BFG"),
    name="Git Pull Latest RBDOOM-3-BFG Code",
    haltOnFailure=True
))

RBDOOM3BFG_factory.addStep(steps.SetPropertyFromCommand(
    command=["gh", "api", "repos/RobertBeckebans/RBDOOM-3-BFG/releases/latest", "--jq", ".tag_name"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/RBDOOM-3-BFG"),
    property="RBDOOM3BFG_latest_tag",
    name="Fetch Latest RBDOOM-3-BFG Release",
    haltOnFailure=True
))

RBDOOM3BFG_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('RBDOOM3BFG_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/RBDOOM-3-BFG"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=RBDOOM3BFG_guard.should_build
))

RBDOOM3BFG_factory.addStep(steps.ShellCommand(
    command=["git", "submodule", "update", "--init", "--recursive"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/RBDOOM-3-BFG"),
    name="Update Submodules for Tag",
    haltOnFailure=True,
    doStepIf=RBDOOM3BFG_guard.should_build
))

RBDOOM3BFG_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/RBDOOM-3-BFG/macsourceports_universal2.sh"), "notarize", util.Property('RBDOOM3BFG_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/RBDOOM-3-BFG"),
    name="Run Build Script",
    haltOnFailure=True,
    timeout=3600,
    doStepIf=RBDOOM3BFG_guard.should_build,
    extract_fn=make_release_extractor("RBDOOM3BFG_dmg_path", "RBDOOM3BFG_version"),
))

RBDOOM3BFG_factory.addStep(RequireProperty(
    "RBDOOM3BFG_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=RBDOOM3BFG_guard.should_build,
    haltOnFailure=True,
))

RBDOOM3BFG_factory.addStep(RequireProperty(
    "RBDOOM3BFG_version",
    name="Verify Build Reported a Version",
    doStepIf=RBDOOM3BFG_guard.should_build,
    haltOnFailure=True,
))

RBDOOM3BFG_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "RBDOOM-3-BFG",
        "--tag", util.Interpolate("RBDOOM-3-BFG_%(prop:RBDOOM3BFG_version)s"),
        "--version", util.Property('RBDOOM3BFG_version'),
        "--dmg", util.Property('RBDOOM3BFG_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/RBDOOM-3-BFG"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, RBDOOM3BFG_publish_schedulers),
        RBDOOM3BFG_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

RBDOOM3BFG_factory.addStep(RecordBuiltTag(RBDOOM3BFG_guard, doStepIf=RBDOOM3BFG_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="RBDOOM-3-BFG-builder", workernames=["worker1"], factory=RBDOOM3BFG_factory, project="RBDOOM-3-BFG")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="RBDOOM-3-BFG-changes",
        change_filter=util.ChangeFilter(project='RBDOOM-3-BFG'),
        treeStableTimer=60,
        builderNames=["RBDOOM-3-BFG-builder"]),
    schedulers.ForceScheduler(
        name="RBDOOM-3-BFG-force",
        builderNames=["RBDOOM-3-BFG-builder"]),
    schedulers.ForceScheduler(
        name="RBDOOM-3-BFG-publish",
        builderNames=["RBDOOM-3-BFG-builder"]),
    # Rebuild and republish even when the site already has this tag
    # (e.g. a packaging fix with no new upstream release)
    schedulers.ForceScheduler(
        name="RBDOOM-3-BFG-forcepublish",
        builderNames=["RBDOOM-3-BFG-builder"])
]
