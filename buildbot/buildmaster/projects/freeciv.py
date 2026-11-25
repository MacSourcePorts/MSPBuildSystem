# freeciv

# Project where we build based off of release tags from the project
# (freeciv/freeciv). Release tags are R<major>_<minor>_<patch> (R3_2_7 is
# 3.2.7); the build script turns the tag into the version. The macOS app
# bundle support is applied by the build script from
# MSPBuildSystem/freeciv/msp-macos.patch.

import os
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

freeciv_guard = VersionGuard(
    project_name="freeciv",
    tag_property="freeciv_latest_tag",
    force_scheduler_names={"freeciv-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="freeciv",
)

freeciv_publish_schedulers = {"freeciv-changes", "freeciv-publish"}

project_list = [ 
    util.Project(name="freeciv",description="Freeciv source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/freeciv/freeciv',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/freeciv"),
        project="freeciv",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

freeciv_factory = util.BuildFactory()

freeciv_factory.addStep(steps.Git(
    repourl='https://github.com/freeciv/freeciv',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/freeciv"),
    name="Git Pull Latest freeciv Code",
    haltOnFailure=True
))

freeciv_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git tag --list 'R*' --sort=-v:refname | grep -E '^R[0-9]+_[0-9]+_[0-9]+$' | head -n 1"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/freeciv"),
    property="freeciv_latest_tag",
    name="Fetch Latest freeciv Tag",
    haltOnFailure=True
))

freeciv_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('freeciv_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/freeciv"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=freeciv_guard.should_build
))

freeciv_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/freeciv/macsourceports_universal2.sh"), "notarize", util.Property('freeciv_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/freeciv"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=freeciv_guard.should_build,
    # the build script prints the version it made from the tag (3.2.7 for
    # R3_2_7), which is what the website shows
    extract_fn=make_release_extractor("freeciv_dmg_path", "freeciv_version"),
))

freeciv_factory.addStep(RequireProperty(
    "freeciv_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=freeciv_guard.should_build,
    haltOnFailure=True,
))

freeciv_factory.addStep(RequireProperty(
    "freeciv_version",
    name="Verify Build Reported a Version",
    doStepIf=freeciv_guard.should_build,
    haltOnFailure=True,
))

freeciv_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "freeciv",
        "--tag", util.Interpolate("freeciv_%(prop:freeciv_version)s"),
        "--version", util.Property('freeciv_version'),
        "--dmg", util.Property('freeciv_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/freeciv"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, freeciv_publish_schedulers),
        freeciv_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

freeciv_factory.addStep(RecordBuiltTag(freeciv_guard, doStepIf=freeciv_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="freeciv-builder", workernames=["worker1"], factory=freeciv_factory, project="freeciv")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="freeciv-changes",
        change_filter=util.ChangeFilter(project='freeciv'),
        treeStableTimer=60,
        builderNames=["freeciv-builder"]),
    schedulers.ForceScheduler(
        name="freeciv-force",
        builderNames=["freeciv-builder"]),
    schedulers.ForceScheduler(
        name="freeciv-publish",
        builderNames=["freeciv-builder"])
]