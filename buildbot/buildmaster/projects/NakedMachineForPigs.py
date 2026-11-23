# NakedMachineForPigs

# Project where we build based off of release tags from the project
# (atsb/NakedMachineForPigs, Amnesia: A Machine for Pigs). Our macOS changes
# are applied by the build script from
# MSPBuildSystem/NakedMachineForPigs/msp-macos.patch.

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

NakedMachineForPigs_guard = VersionGuard(
    project_name="NakedMachineForPigs",
    tag_property="NakedMachineForPigs_latest_tag",
    force_scheduler_names={"NakedMachineForPigs-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="nakedmachineforpigs",
)

NakedMachineForPigs_publish_schedulers = {"NakedMachineForPigs-changes", "NakedMachineForPigs-publish"}

project_list = [ 
    util.Project(name="NakedMachineForPigs",description="NakedMachineForPigs source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/atsb/NakedMachineForPigs',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/NakedMachineForPigs"),
        project="NakedMachineForPigs",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

NakedMachineForPigs_factory = util.BuildFactory()

NakedMachineForPigs_factory.addStep(steps.Git(
    repourl='https://github.com/atsb/NakedMachineForPigs',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedMachineForPigs"),
    name="Git Pull Latest NakedMachineForPigs Code",
    haltOnFailure=True
))

NakedMachineForPigs_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedMachineForPigs"),
    property="NakedMachineForPigs_latest_tag",
    name="Fetch Latest NakedMachineForPigs Tag",
    haltOnFailure=True
))

NakedMachineForPigs_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('NakedMachineForPigs_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedMachineForPigs"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=NakedMachineForPigs_guard.should_build
))

NakedMachineForPigs_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/NakedMachineForPigs/macsourceports_universal2.sh"), "notarize", util.Property('NakedMachineForPigs_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/NakedMachineForPigs"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=NakedMachineForPigs_guard.should_build,
    extract_fn=make_dmg_extractor("NakedMachineForPigs_dmg_path"),
))

NakedMachineForPigs_factory.addStep(RequireProperty(
    "NakedMachineForPigs_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=NakedMachineForPigs_guard.should_build,
    haltOnFailure=True,
))

NakedMachineForPigs_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "NakedMachineForPigs",
        "--tag", util.Interpolate("NakedMachineForPigs_%(prop:NakedMachineForPigs_latest_tag)s"),
        "--version", util.Property('NakedMachineForPigs_latest_tag'),
        "--dmg", util.Property('NakedMachineForPigs_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedMachineForPigs"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, NakedMachineForPigs_publish_schedulers),
        NakedMachineForPigs_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

NakedMachineForPigs_factory.addStep(RecordBuiltTag(NakedMachineForPigs_guard, doStepIf=NakedMachineForPigs_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="NakedMachineForPigs-builder", workernames=["worker1"], factory=NakedMachineForPigs_factory, project="NakedMachineForPigs")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="NakedMachineForPigs-changes",
        change_filter=util.ChangeFilter(project='NakedMachineForPigs'),
        treeStableTimer=60,
        builderNames=["NakedMachineForPigs-builder"]),
    schedulers.ForceScheduler(
        name="NakedMachineForPigs-force",
        builderNames=["NakedMachineForPigs-builder"]),
    schedulers.ForceScheduler(
        name="NakedMachineForPigs-publish",
        builderNames=["NakedMachineForPigs-builder"])
]