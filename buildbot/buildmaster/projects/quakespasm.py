# quakespasm

# Project where we build based off of release tags from sezero/quakespasm. It tags releases (quakespasm-0.97.0)
# without making GitHub releases, so the newest tag is read from the checkout.
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

_quakespasm_release_re = re.compile(r'^quakespasm-\d+(\.\d+)+$')

quakespasm_guard = VersionGuard(
    project_name="quakespasm",
    tag_property="quakespasm_latest_tag",
    tag_filter=lambda tag: bool(_quakespasm_release_re.match(tag)),
    force_scheduler_names={"quakespasm-force", "quakespasm-forcepublish"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="quakespasm",
)

quakespasm_publish_schedulers = {"quakespasm-changes", "quakespasm-publish", "quakespasm-forcepublish"}

project_list = [
    util.Project(name="quakespasm", description="quakespasm source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/sezero/quakespasm',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/quakespasm"),
        project="quakespasm",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

quakespasm_factory = util.BuildFactory()

quakespasm_factory.addStep(steps.Git(
    repourl='https://github.com/sezero/quakespasm',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/quakespasm"),
    name="Git Pull Latest quakespasm Code",
    haltOnFailure=True
))

# the highest version-sorted release tag
quakespasm_factory.addStep(steps.SetPropertyFromCommand(
    command="git tag --list 'quakespasm-*' --sort=-v:refname | grep -E '^quakespasm-[0-9]+([.][0-9]+)+$' | head -1",
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/quakespasm"),
    property="quakespasm_latest_tag",
    name="Find Latest quakespasm Release Tag",
    haltOnFailure=True
))

quakespasm_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('quakespasm_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/quakespasm"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=quakespasm_guard.should_build
))

quakespasm_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/quakespasm/macsourceports_universal2.sh"), "notarize", util.Transform(lambda t: t.replace("quakespasm-", "", 1), util.Property('quakespasm_latest_tag'))],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/quakespasm"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=quakespasm_guard.should_build,
    extract_fn=make_release_extractor("quakespasm_dmg_path", "quakespasm_version"),
))

quakespasm_factory.addStep(RequireProperty(
    "quakespasm_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=quakespasm_guard.should_build,
    haltOnFailure=True,
))

quakespasm_factory.addStep(RequireProperty(
    "quakespasm_version",
    name="Verify Build Reported a Version",
    doStepIf=quakespasm_guard.should_build,
    haltOnFailure=True,
))

quakespasm_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "quakespasm",
        "--tag", util.Interpolate("quakespasm_%(prop:quakespasm_version)s"),
        "--version", util.Property('quakespasm_version'),
        "--dmg", util.Property('quakespasm_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/quakespasm"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, quakespasm_publish_schedulers),
        quakespasm_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

quakespasm_factory.addStep(RecordBuiltTag(quakespasm_guard, doStepIf=quakespasm_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="quakespasm-builder", workernames=["worker1"], factory=quakespasm_factory, project="quakespasm")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="quakespasm-changes",
        change_filter=util.ChangeFilter(project='quakespasm'),
        treeStableTimer=60,
        builderNames=["quakespasm-builder"]),
    schedulers.ForceScheduler(
        name="quakespasm-force",
        builderNames=["quakespasm-builder"]),
    schedulers.ForceScheduler(
        name="quakespasm-publish",
        builderNames=["quakespasm-builder"]),
    # Rebuild and republish even when the site already has this tag
    # (e.g. a packaging fix with no new upstream release)
    schedulers.ForceScheduler(
        name="quakespasm-forcepublish",
        builderNames=["quakespasm-builder"])
]
