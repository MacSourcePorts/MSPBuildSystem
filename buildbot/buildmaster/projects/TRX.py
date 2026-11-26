# TRX (Tomb Raider I-III Community Edition)

# Project where we build based off of release tags from the project. TRX tags
# its releases trx-<version> (e.g. trx-1.12), and also has a moving "latest"
# tag on its newest code, which is skipped.
#
# One build makes three apps and DMGs, TR1X, TR2X and TR3X, all published.
# Our macOS changes (game data in Application Support, GOG TR1 disc image
# extraction) are applied by the build script from
# MSPBuildSystem/TRX/msp-macos.patch.

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

TRX_guard = VersionGuard(
    project_name="TRX",
    tag_property="TRX_latest_tag",
    force_scheduler_names={"TRX-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="tr1x",
)

TRX_publish_schedulers = {"TRX-changes", "TRX-publish"}

TRX_GAMES = ("TR1X", "TR2X", "TR3X")


def TRX_dmg_extractor(rc, stdout, stderr):
    # package_dmg.sh prints an MSP_RELEASE_DMG line per app; take each
    paths = re.findall(r'^MSP_RELEASE_DMG=(.*)$', stdout, re.MULTILINE)
    props = {}
    for game in TRX_GAMES:
        match = next((p.strip() for p in paths if os.path.basename(p.strip()).startswith(game + "-")), None)
        props[f"TRX_{game}_dmg_path"] = match
    return props


project_list = [
    util.Project(name="TRX",description="TRX source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/LostArtefacts/TRX',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/TRX"),
        project="TRX",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

TRX_factory = util.BuildFactory()

TRX_factory.addStep(steps.Git(
    repourl='https://github.com/LostArtefacts/TRX',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TRX"),
    name="Git Pull Latest TRX Code",
    haltOnFailure=True,
))

# the newest trx-<version> tag (not "latest", which follows the newest code)
TRX_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git tag -l 'trx-*' --sort=-v:refname | head -n 1"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TRX"),
    property="TRX_latest_tag",
    name="Fetch Latest TRX Tag",
    haltOnFailure=True
))

TRX_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('TRX_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TRX"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=TRX_guard.should_build
))

TRX_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/TRX/macsourceports_universal2.sh"), "notarize", util.Property('TRX_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/TRX"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=TRX_guard.should_build,
    timeout=3600,
    extract_fn=TRX_dmg_extractor,
))

for game in TRX_GAMES:
    TRX_factory.addStep(RequireProperty(
        f"TRX_{game}_dmg_path",
        name=f"Verify Build Produced the {game} DMG",
        doStepIf=TRX_guard.should_build,
        haltOnFailure=True,
    ))

TRX_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "TRX",
        "--tag", util.Interpolate("TRX_%(prop:TRX_latest_tag)s"),
        "--version", util.Transform(lambda tag: tag[len("trx-"):] if tag.startswith("trx-") else tag, util.Property('TRX_latest_tag')),
        "--dmg", util.Property('TRX_TR1X_dmg_path'),
        "--dmg", util.Property('TRX_TR2X_dmg_path'),
        "--dmg", util.Property('TRX_TR3X_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/TRX"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, TRX_publish_schedulers),
        TRX_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

TRX_factory.addStep(RecordBuiltTag(TRX_guard, doStepIf=TRX_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="TRX-builder", workernames=["worker1"], factory=TRX_factory, project="TRX")
]

scheduler_list = [
    schedulers.SingleBranchScheduler(
        name="TRX-changes",
        change_filter=util.ChangeFilter(project='TRX'),
        treeStableTimer=60,
        builderNames=["TRX-builder"]),
    schedulers.ForceScheduler(
        name="TRX-force",
        builderNames=["TRX-builder"]),
    schedulers.ForceScheduler(
        name="TRX-publish",
        builderNames=["TRX-builder"])
]
