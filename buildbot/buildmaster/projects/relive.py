# relive

# Project where we build based off of release tags from the project
# (github-v1.1.0 and so on), straight from upstream AliveTeam/alive_reversing
# with a small patch applied at build time (alive_reversing/msp-appsupport.patch)
# instead of from a MacSourcePorts fork.
#
# One build makes two apps, each its own port on the site: R.E.L.I.V.E. for
# Abe's Oddysee (relive-ao) and for Abe's Exoddus (relive-ae). They're
# published together as one release.

import os
import re
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import (
    VersionGuard,
    RecordBuiltTag,
    scheduler_in,
    and_steps,
    extract_version_tuple,
    is_publish_machine,
    RequireProperty,
)
from projects.latest_code import make_release_extractor, dmg_args

# Upstream also has old appveyor_* and v0.0.1-beta tags; only these are releases
_relive_release_re = re.compile(r'^github-v\d+\.\d+\.\d+$')


def relive_latest_tag(rc, stdout, stderr):
    """extract_fn for `git tag --list`: the highest github-vX.Y.Z tag."""
    tags = [t.strip() for t in stdout.splitlines() if _relive_release_re.match(t.strip())]
    return {"relive_latest_tag": max(tags, key=extract_version_tuple) if tags else None}


relive_guard = VersionGuard(
    project_name="alive_reversing",
    tag_property="relive_latest_tag",
    tag_filter=lambda tag: bool(_relive_release_re.match(tag)),
    force_scheduler_names={"relive-force", "relive-forcepublish"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="reliveae",
)

relive_publish_schedulers = {"relive-changes", "relive-publish", "relive-forcepublish"}

project_list = [
    util.Project(name="relive",description="relive source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/AliveTeam/alive_reversing',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/alive_reversing"),
        project="relive",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

relive_factory = util.BuildFactory()

relive_factory.addStep(steps.Git(
    repourl='https://github.com/AliveTeam/alive_reversing',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    submodules=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/alive_reversing"),
    name="Git Pull Latest relive Code",
    haltOnFailure=True
))

relive_factory.addStep(steps.SetPropertyFromCommand(
    command=["git", "tag", "--list"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/alive_reversing"),
    extract_fn=relive_latest_tag,
    name="Fetch Latest relive Release Tag",
    haltOnFailure=True
))

relive_factory.addStep(RequireProperty(
    "relive_latest_tag",
    name="Verify a Release Tag Was Found",
    haltOnFailure=True,
))

relive_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('relive_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/alive_reversing"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=relive_guard.should_build
))

# the tag's submodule pins, not master's
relive_factory.addStep(steps.ShellCommand(
    command=["git", "submodule", "update", "--init", "--recursive"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/alive_reversing"),
    name="Update Submodules for Tag",
    haltOnFailure=True,
    doStepIf=relive_guard.should_build
))

relive_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/alive_reversing/macsourceports_universal2.sh"), "notarize", util.Property('relive_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/alive_reversing"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=relive_guard.should_build,
    extract_fn=make_release_extractor("relive_dmg_paths", "relive_version", dmg_count=2),
))

relive_factory.addStep(RequireProperty(
    "relive_dmg_paths",
    name="Verify Build Produced Both DMGs",
    doStepIf=relive_guard.should_build,
    haltOnFailure=True,
))

relive_factory.addStep(RequireProperty(
    "relive_version",
    name="Verify Build Reported a Version",
    doStepIf=relive_guard.should_build,
    haltOnFailure=True,
))

relive_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "alive_reversing",
        "--tag", util.Interpolate("relive_%(prop:relive_version)s"),
        "--version", util.Property('relive_version'),
        dmg_args("relive_dmg_paths"),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/alive_reversing"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, relive_publish_schedulers),
        relive_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

relive_factory.addStep(RecordBuiltTag(relive_guard, doStepIf=relive_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="relive-builder", workernames=["worker1"], factory=relive_factory, project="relive")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="relive-changes",
        change_filter=util.ChangeFilter(project='relive'),
        treeStableTimer=60,
        builderNames=["relive-builder"]),
    schedulers.ForceScheduler(
        name="relive-force",
        builderNames=["relive-builder"]),
    schedulers.ForceScheduler(
        name="relive-publish",
        builderNames=["relive-builder"]),
    # Rebuild and republish even when the site already has this tag
    # (e.g. a packaging fix with no new upstream release)
    schedulers.ForceScheduler(
        name="relive-forcepublish",
        builderNames=["relive-builder"])
]
