# gardens-of-kadesh

# Project where we build based off of release tags from gardens-of-kadesh on GitLab. It isn't on
# GitHub, so the newest release tag (1.2.2) is read from the checkout.
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

_gardensofkadesh_release_re = re.compile(r'^\d+(\.\d+)+$')

gardensofkadesh_guard = VersionGuard(
    project_name="gardens-of-kadesh",
    tag_property="gardensofkadesh_latest_tag",
    tag_filter=lambda tag: bool(_gardensofkadesh_release_re.match(tag)),
    force_scheduler_names={"gardens-of-kadesh-force", "gardens-of-kadesh-forcepublish"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="gardens-of-kadesh",
)

gardensofkadesh_publish_schedulers = {"gardens-of-kadesh-changes", "gardens-of-kadesh-publish", "gardens-of-kadesh-forcepublish"}

project_list = [
    util.Project(name="gardens-of-kadesh", description="gardens-of-kadesh source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://gitlab.com/gardens-of-kadesh/gardens-of-kadesh',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/gardens-of-kadesh"),
        project="gardens-of-kadesh",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

gardensofkadesh_factory = util.BuildFactory()

gardensofkadesh_factory.addStep(steps.Git(
    repourl='https://gitlab.com/gardens-of-kadesh/gardens-of-kadesh',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/gardens-of-kadesh"),
    name="Git Pull Latest gardens-of-kadesh Code",
    haltOnFailure=True
))

# the highest version-sorted release tag
gardensofkadesh_factory.addStep(steps.SetPropertyFromCommand(
    command="git tag --list '[0-9]*' --sort=-v:refname | grep -E '^[0-9]+([.][0-9]+)+$' | head -1",
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/gardens-of-kadesh"),
    property="gardensofkadesh_latest_tag",
    name="Find Latest gardens-of-kadesh Release Tag",
    haltOnFailure=True
))

gardensofkadesh_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('gardensofkadesh_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/gardens-of-kadesh"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=gardensofkadesh_guard.should_build
))

gardensofkadesh_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/gardens-of-kadesh/macsourceports_universal2.sh"), "notarize", util.Property('gardensofkadesh_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/gardens-of-kadesh"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=gardensofkadesh_guard.should_build,
    extract_fn=make_release_extractor("gardensofkadesh_dmg_path", "gardensofkadesh_version"),
))

gardensofkadesh_factory.addStep(RequireProperty(
    "gardensofkadesh_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=gardensofkadesh_guard.should_build,
    haltOnFailure=True,
))

gardensofkadesh_factory.addStep(RequireProperty(
    "gardensofkadesh_version",
    name="Verify Build Reported a Version",
    doStepIf=gardensofkadesh_guard.should_build,
    haltOnFailure=True,
))

gardensofkadesh_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "gardens-of-kadesh",
        "--tag", util.Interpolate("gardens-of-kadesh_%(prop:gardensofkadesh_version)s"),
        "--version", util.Property('gardensofkadesh_version'),
        "--dmg", util.Property('gardensofkadesh_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/gardens-of-kadesh"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, gardensofkadesh_publish_schedulers),
        gardensofkadesh_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

gardensofkadesh_factory.addStep(RecordBuiltTag(gardensofkadesh_guard, doStepIf=gardensofkadesh_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="gardens-of-kadesh-builder", workernames=["worker1"], factory=gardensofkadesh_factory, project="gardens-of-kadesh")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="gardens-of-kadesh-changes",
        change_filter=util.ChangeFilter(project='gardens-of-kadesh'),
        treeStableTimer=60,
        builderNames=["gardens-of-kadesh-builder"]),
    schedulers.ForceScheduler(
        name="gardens-of-kadesh-force",
        builderNames=["gardens-of-kadesh-builder"]),
    schedulers.ForceScheduler(
        name="gardens-of-kadesh-publish",
        builderNames=["gardens-of-kadesh-builder"]),
    # Rebuild and republish even when the site already has this tag
    # (e.g. a packaging fix with no new upstream release)
    schedulers.ForceScheduler(
        name="gardens-of-kadesh-forcepublish",
        builderNames=["gardens-of-kadesh-builder"])
]
