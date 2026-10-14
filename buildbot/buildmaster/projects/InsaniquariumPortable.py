# Insaniquarium-Portable

# Project where we build based off of release tags from the project

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

InsaniquariumPortable_guard = VersionGuard(
    project_name="Insaniquarium-Portable",
    tag_property="InsaniquariumPortable_latest_tag",
    force_scheduler_names={"Insaniquarium-Portable-force"},
    meta_url="https://www.macsourceports.com/meta.json",
    meta_stub="insaniquariumportable",
)

InsaniquariumPortable_publish_schedulers = {"Insaniquarium-Portable-changes", "Insaniquarium-Portable-publish"}

project_list = [ 
    util.Project(name="Insaniquarium-Portable",description="Insaniquarium-Portable source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/kyle-sylvestre/PvZ-Portable',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Insaniquarium-Portable"),
    #     project="Insaniquarium-Portable",
    #     only_tags=True,
    #     pollInterval=3600  # Poll every hour
    # ),
    changes.GitPoller(
        repourl='https://github.com/kyle-sylvestre/WinFish',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Insaniquarium-Portable/src/WinFish"),
        project="Insaniquarium-Portable",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

InsaniquariumPortable_factory = util.BuildFactory()

InsaniquariumPortable_factory.addStep(steps.Git(
    repourl='https://github.com/kyle-sylvestre/PvZ-Portable',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    branch='insaniquarium',
    alwaysUseLatest=True,
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Insaniquarium-Portable"),
    name="Git Pull Latest Insaniquarium-Portable Code",
    haltOnFailure=True
))

InsaniquariumPortable_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Insaniquarium-Portable/scripts/create_flat_directory.sh")],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Insaniquarium-Portable"),
    name="Run Flat Directory Script",
    haltOnFailure=True
))

InsaniquariumPortable_factory.addStep(steps.Git(
    repourl='https://github.com/kyle-sylvestre/WinFish',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Insaniquarium-Portable/src/WinFish"),
    name="Git Pull Latest WinFish Code",
    haltOnFailure=True
))

InsaniquariumPortable_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git ls-remote --tags --sort='-version:refname' https://github.com/kyle-sylvestre/WinFish | awk -F'/' '{print $3}' | head -n 1"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Insaniquarium-Portable/src/WinFish"),
    property="InsaniquariumPortable_latest_tag",
    name="Fetch Latest Insaniquarium-Portable Tag",
    haltOnFailure=True
))

InsaniquariumPortable_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('InsaniquariumPortable_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Insaniquarium-Portable/src/WinFish"),
    name="Checkout Latest Tag",
    haltOnFailure=True,
    doStepIf=InsaniquariumPortable_guard.should_build
))

InsaniquariumPortable_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Insaniquarium-Portable/macsourceports_universal2.sh"), "notarize", util.Property('InsaniquariumPortable_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Insaniquarium-Portable"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=InsaniquariumPortable_guard.should_build,
    extract_fn=make_dmg_extractor("InsaniquariumPortable_dmg_path"),
))

InsaniquariumPortable_factory.addStep(RequireProperty(
    "InsaniquariumPortable_dmg_path",
    name="Verify Build Produced a DMG",
    doStepIf=InsaniquariumPortable_guard.should_build,
    haltOnFailure=True,
))

InsaniquariumPortable_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Insaniquarium-Portable",
        "--tag", util.Interpolate("Insaniquarium-Portable_%(prop:InsaniquariumPortable_latest_tag)s"),
        "--version", util.Property('InsaniquariumPortable_latest_tag'),
        "--dmg", util.Property('InsaniquariumPortable_dmg_path')
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Insaniquarium-Portable"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, InsaniquariumPortable_publish_schedulers),
        InsaniquariumPortable_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

InsaniquariumPortable_factory.addStep(RecordBuiltTag(InsaniquariumPortable_guard, doStepIf=InsaniquariumPortable_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="Insaniquarium-Portable-builder", workernames=["worker1"], factory=InsaniquariumPortable_factory, project="Insaniquarium-Portable")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="Insaniquarium-Portable-changes",
        change_filter=util.ChangeFilter(project='Insaniquarium-Portable'),
        treeStableTimer=60,
        builderNames=["Insaniquarium-Portable-builder"]),
    schedulers.ForceScheduler(
        name="Insaniquarium-Portable-force",
        builderNames=["Insaniquarium-Portable-builder"]),
    schedulers.ForceScheduler(
        name="Insaniquarium-Portable-publish",
        builderNames=["Insaniquarium-Portable-builder"])
]