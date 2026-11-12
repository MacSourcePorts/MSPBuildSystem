# 1oom

# Project where we build based off of release tags from the project, straight
# from upstream 1oom-fork/1oom with a small patch applied at build time
# (1oom/msp-macos.patch) instead of from a MacSourcePorts fork.
#
# Upstream has two lines of releases: numbered ones (v1.11.9) and "vanilla"
# release candidates (vanilla-RC5), and its branches get rewritten often. We
# build whatever GitHub lists as the latest release, as long as it's a
# numbered one -- an RC marked latest is skipped.

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

_moo1_release_re = re.compile(r'^v\d+(\.\d+)+$')

moo1_guard = VersionGuard(
    project_name="1oom",
    tag_property="moo1_latest_tag",
    tag_filter=lambda tag: bool(_moo1_release_re.match(tag)),
    force_scheduler_names={"moo1-force", "moo1-forcepublish"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="1oom",
)

moo1_publish_schedulers = {"moo1-changes", "moo1-publish", "moo1-forcepublish"}

project_list = [
    util.Project(name="moo1",description="1oom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/1oom-fork/1oom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/1oom"),
        project="moo1",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

moo1_factory = util.BuildFactory()

moo1_factory.addStep(steps.Git(
    repourl='https://github.com/1oom-fork/1oom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/1oom"),
    name="Git Pull Latest 1oom Code",
    haltOnFailure=True
))

moo1_factory.addStep(steps.SetPropertyFromCommand(
    command=["gh", "api", "repos/1oom-fork/1oom/releases/latest", "--jq", ".tag_name"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/1oom"),
    property="moo1_latest_tag",
    name="Fetch Latest 1oom Release",
    haltOnFailure=True
))

moo1_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('moo1_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/1oom"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=moo1_guard.should_build
))

moo1_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/1oom/macsourceports_universal2.sh"), "notarize", util.Property('moo1_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/1oom"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=moo1_guard.should_build,
    extract_fn=make_release_extractor("moo1_dmg_path", "moo1_version"),
))

moo1_factory.addStep(RequireProperty(
    "moo1_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=moo1_guard.should_build,
    haltOnFailure=True,
))

moo1_factory.addStep(RequireProperty(
    "moo1_version",
    name="Verify Build Reported a Version",
    doStepIf=moo1_guard.should_build,
    haltOnFailure=True,
))

moo1_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "1oom",
        "--tag", util.Interpolate("1oom_%(prop:moo1_version)s"),
        "--version", util.Property('moo1_version'),
        "--dmg", util.Property('moo1_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/1oom"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, moo1_publish_schedulers),
        moo1_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

moo1_factory.addStep(RecordBuiltTag(moo1_guard, doStepIf=moo1_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="moo1-builder", workernames=["worker1"], factory=moo1_factory, project="moo1")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="moo1-changes",
        change_filter=util.ChangeFilter(project='moo1'),
        treeStableTimer=60,
        builderNames=["moo1-builder"]),
    schedulers.ForceScheduler(
        name="moo1-force",
        builderNames=["moo1-builder"]),
    schedulers.ForceScheduler(
        name="moo1-publish",
        builderNames=["moo1-builder"]),
    # Rebuild and republish even when the site already has this tag
    # (e.g. a packaging fix with no new upstream release)
    schedulers.ForceScheduler(
        name="moo1-forcepublish",
        builderNames=["moo1-builder"])
]
