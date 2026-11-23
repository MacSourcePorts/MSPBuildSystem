# NakedAmnesiaTheDarkDescent

# Project where we build based off of release tags from the project
# (atsb/NakedAmnesiaTheDarkDescent, Amnesia: The Dark Descent). Upstream
# only builds on Windows; the macOS build (CMake, arm64 AngelScript, data
# lookup) is applied by the build script from
# MSPBuildSystem/NakedAmnesiaTheDarkDescent/msp-macos.patch.

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

NakedAmnesiaTheDarkDescent_guard = VersionGuard(
    project_name="NakedAmnesiaTheDarkDescent",
    tag_property="NakedAmnesiaTheDarkDescent_latest_tag",
    force_scheduler_names={"NakedAmnesiaTheDarkDescent-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="nakedamnesiathedarkdescent",
)

NakedAmnesiaTheDarkDescent_publish_schedulers = {"NakedAmnesiaTheDarkDescent-changes", "NakedAmnesiaTheDarkDescent-publish"}

project_list = [ 
    util.Project(name="NakedAmnesiaTheDarkDescent",description="NakedAmnesiaTheDarkDescent source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/atsb/NakedAmnesiaTheDarkDescent',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/NakedAmnesiaTheDarkDescent"),
        project="NakedAmnesiaTheDarkDescent",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

NakedAmnesiaTheDarkDescent_factory = util.BuildFactory()

NakedAmnesiaTheDarkDescent_factory.addStep(steps.Git(
    repourl='https://github.com/atsb/NakedAmnesiaTheDarkDescent',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedAmnesiaTheDarkDescent"),
    name="Git Pull Latest NakedAmnesiaTheDarkDescent Code",
    haltOnFailure=True
))

NakedAmnesiaTheDarkDescent_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedAmnesiaTheDarkDescent"),
    property="NakedAmnesiaTheDarkDescent_latest_tag",
    name="Fetch Latest NakedAmnesiaTheDarkDescent Tag",
    haltOnFailure=True
))

NakedAmnesiaTheDarkDescent_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('NakedAmnesiaTheDarkDescent_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedAmnesiaTheDarkDescent"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=NakedAmnesiaTheDarkDescent_guard.should_build
))

NakedAmnesiaTheDarkDescent_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/NakedAmnesiaTheDarkDescent/macsourceports_universal2.sh"), "notarize", util.Property('NakedAmnesiaTheDarkDescent_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/NakedAmnesiaTheDarkDescent"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=NakedAmnesiaTheDarkDescent_guard.should_build,
    extract_fn=make_dmg_extractor("NakedAmnesiaTheDarkDescent_dmg_path"),
))

NakedAmnesiaTheDarkDescent_factory.addStep(RequireProperty(
    "NakedAmnesiaTheDarkDescent_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=NakedAmnesiaTheDarkDescent_guard.should_build,
    haltOnFailure=True,
))

NakedAmnesiaTheDarkDescent_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "NakedAmnesiaTheDarkDescent",
        "--tag", util.Interpolate("NakedAmnesiaTheDarkDescent_%(prop:NakedAmnesiaTheDarkDescent_latest_tag)s"),
        "--version", util.Property('NakedAmnesiaTheDarkDescent_latest_tag'),
        "--dmg", util.Property('NakedAmnesiaTheDarkDescent_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/NakedAmnesiaTheDarkDescent"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, NakedAmnesiaTheDarkDescent_publish_schedulers),
        NakedAmnesiaTheDarkDescent_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

NakedAmnesiaTheDarkDescent_factory.addStep(RecordBuiltTag(NakedAmnesiaTheDarkDescent_guard, doStepIf=NakedAmnesiaTheDarkDescent_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="NakedAmnesiaTheDarkDescent-builder", workernames=["worker1"], factory=NakedAmnesiaTheDarkDescent_factory, project="NakedAmnesiaTheDarkDescent")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="NakedAmnesiaTheDarkDescent-changes",
        change_filter=util.ChangeFilter(project='NakedAmnesiaTheDarkDescent'),
        treeStableTimer=60,
        builderNames=["NakedAmnesiaTheDarkDescent-builder"]),
    schedulers.ForceScheduler(
        name="NakedAmnesiaTheDarkDescent-force",
        builderNames=["NakedAmnesiaTheDarkDescent-builder"]),
    schedulers.ForceScheduler(
        name="NakedAmnesiaTheDarkDescent-publish",
        builderNames=["NakedAmnesiaTheDarkDescent-builder"])
]