# Maelstrom

# Project where we build based off of release tags from the GitHub releases of libsdl-org/Maelstrom
# (release-4.0.2). Upstream ships its own macOS DMG, but it isn't signed.
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

_Maelstrom_release_re = re.compile(r'^release-\d+(\.\d+)+$')

Maelstrom_guard = VersionGuard(
    project_name="Maelstrom",
    tag_property="Maelstrom_latest_tag",
    tag_filter=lambda tag: bool(_Maelstrom_release_re.match(tag)),
    force_scheduler_names={"Maelstrom-force", "Maelstrom-forcepublish"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="maelstrom",
)

Maelstrom_publish_schedulers = {"Maelstrom-changes", "Maelstrom-publish", "Maelstrom-forcepublish"}

project_list = [
    util.Project(name="Maelstrom", description="Maelstrom source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/libsdl-org/Maelstrom',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Maelstrom"),
        project="Maelstrom",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

Maelstrom_factory = util.BuildFactory()

Maelstrom_factory.addStep(steps.Git(
    repourl='https://github.com/libsdl-org/Maelstrom',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Maelstrom"),
    name="Git Pull Latest Maelstrom Code",
    haltOnFailure=True
))

Maelstrom_factory.addStep(steps.SetPropertyFromCommand(
    command=["gh", "api", "repos/libsdl-org/Maelstrom/releases/latest", "--jq", ".tag_name"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Maelstrom"),
    property="Maelstrom_latest_tag",
    name="Fetch Latest Maelstrom Release",
    haltOnFailure=True
))

Maelstrom_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('Maelstrom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Maelstrom"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=Maelstrom_guard.should_build
))

Maelstrom_factory.addStep(steps.ShellCommand(
    command=["git", "submodule", "update", "--init", "--recursive"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Maelstrom"),
    name="Update Submodules for Tag",
    haltOnFailure=True,
    doStepIf=Maelstrom_guard.should_build
))

Maelstrom_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Maelstrom/macsourceports_universal2.sh"), "notarize", util.Property('Maelstrom_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Maelstrom"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=Maelstrom_guard.should_build,
    extract_fn=make_release_extractor("Maelstrom_dmg_path", "Maelstrom_version"),
))

Maelstrom_factory.addStep(RequireProperty(
    "Maelstrom_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=Maelstrom_guard.should_build,
    haltOnFailure=True,
))

Maelstrom_factory.addStep(RequireProperty(
    "Maelstrom_version",
    name="Verify Build Reported a Version",
    doStepIf=Maelstrom_guard.should_build,
    haltOnFailure=True,
))

Maelstrom_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Maelstrom",
        "--tag", util.Interpolate("Maelstrom_%(prop:Maelstrom_version)s"),
        "--version", util.Property('Maelstrom_version'),
        "--dmg", util.Property('Maelstrom_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Maelstrom"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, Maelstrom_publish_schedulers),
        Maelstrom_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

Maelstrom_factory.addStep(RecordBuiltTag(Maelstrom_guard, doStepIf=Maelstrom_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="Maelstrom-builder", workernames=["worker1"], factory=Maelstrom_factory, project="Maelstrom")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="Maelstrom-changes",
        change_filter=util.ChangeFilter(project='Maelstrom'),
        treeStableTimer=60,
        builderNames=["Maelstrom-builder"]),
    schedulers.ForceScheduler(
        name="Maelstrom-force",
        builderNames=["Maelstrom-builder"]),
    schedulers.ForceScheduler(
        name="Maelstrom-publish",
        builderNames=["Maelstrom-builder"]),
    # Rebuild and republish even when the site already has this tag
    # (e.g. a packaging fix with no new upstream release)
    schedulers.ForceScheduler(
        name="Maelstrom-forcepublish",
        builderNames=["Maelstrom-builder"])
]
