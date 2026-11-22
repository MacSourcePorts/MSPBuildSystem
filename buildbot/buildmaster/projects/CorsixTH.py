# CorsixTH

# Project where we build based off of release tags from CorsixTH/CorsixTH --
# and where our build is the project's official Mac build, so it goes on
# upstream's own release instead of an MSPBuildSystem one.
#
# The maintainers tag a version and put its release together as a draft
# before publishing it. When a new tag shows up, this builds it and uploads
# the DMG to that draft (common/upload_upstream_release.py), replacing one
# already there. If the release isn't drafted yet, or is already published,
# nothing is uploaded and the build ends in WARNINGS.
#
# The site isn't touched here: once upstream publishes the release,
# ThirdParty.py's check_thirdparty.py points the site's CorsixTH entry at it
# ("ourBuild": true in common/thirdparty.json). Until then meta.json still has
# the previous version, so a re-run of the same tag builds and uploads again.

import os
import re
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import (
    VersionGuard,
    scheduler_in,
    and_steps,
    is_publish_machine,
    RequireProperty,
)
from projects.latest_code import make_release_extractor

_CorsixTH_release_re = re.compile(r'^v\d+(\.\d+)+$')

CorsixTH_guard = VersionGuard(
    project_name="CorsixTH",
    tag_property="CorsixTH_latest_tag",
    tag_filter=lambda tag: bool(_CorsixTH_release_re.match(tag)),
    force_scheduler_names={"CorsixTH-force", "CorsixTH-forcepublish"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="corsixth",
)

CorsixTH_publish_schedulers = {"CorsixTH-changes", "CorsixTH-publish", "CorsixTH-forcepublish"}

project_list = [
    util.Project(name="CorsixTH", description="CorsixTH source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/CorsixTH/CorsixTH',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/CorsixTH"),
        project="CorsixTH",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

CorsixTH_factory = util.BuildFactory()

CorsixTH_factory.addStep(steps.Git(
    repourl='https://github.com/CorsixTH/CorsixTH',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/CorsixTH"),
    name="Git Pull Latest CorsixTH Code",
    haltOnFailure=True
))

# the highest version-sorted release tag -- a tag, not GitHub's "latest
# release", which is still the previous version while the new one is a draft
CorsixTH_factory.addStep(steps.SetPropertyFromCommand(
    command="git tag --list 'v*' --sort=-v:refname | grep -E '^v[0-9]+([.][0-9]+)+$' | head -1",
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/CorsixTH"),
    property="CorsixTH_latest_tag",
    name="Find Latest CorsixTH Release Tag",
    haltOnFailure=True
))

CorsixTH_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('CorsixTH_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/CorsixTH"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=CorsixTH_guard.should_build
))

CorsixTH_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/CorsixTH/macsourceports_universal2.sh"), "notarize", util.Property('CorsixTH_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/CorsixTH"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=CorsixTH_guard.should_build,
    extract_fn=make_release_extractor("CorsixTH_dmg_path", "CorsixTH_version"),
))

CorsixTH_factory.addStep(RequireProperty(
    "CorsixTH_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=CorsixTH_guard.should_build,
    haltOnFailure=True,
))

# 0 = uploaded; 3 = no draft for the tag yet, or it's already published
CorsixTH_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/upload_upstream_release.py"),
        "--repo", "CorsixTH/CorsixTH",
        "--tag", util.Property('CorsixTH_latest_tag'),
        "--dmg", util.Property('CorsixTH_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/CorsixTH"),
    name="Upload to Upstream Draft Release",
    decodeRC={0: util.SUCCESS, 3: util.WARNINGS},
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, CorsixTH_publish_schedulers),
        CorsixTH_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="CorsixTH-builder", workernames=["worker1"], factory=CorsixTH_factory, project="CorsixTH")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="CorsixTH-changes",
        change_filter=util.ChangeFilter(project='CorsixTH'),
        treeStableTimer=60,
        builderNames=["CorsixTH-builder"]),
    schedulers.ForceScheduler(
        name="CorsixTH-force",
        builderNames=["CorsixTH-builder"]),
    schedulers.ForceScheduler(
        name="CorsixTH-publish",
        builderNames=["CorsixTH-builder"]),
    # Rebuild and upload even when the site already has this tag
    schedulers.ForceScheduler(
        name="CorsixTH-forcepublish",
        builderNames=["CorsixTH-builder"])
]
