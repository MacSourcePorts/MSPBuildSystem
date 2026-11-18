# aviaozinhoachievements

# Project where we build based on the latest code of our fork of rickomax/aviaozinhoachievements, which has no releases.
# One codebase, three games, each its own app and DMG, published together.
# Built and published at most once a day, and only if the code changed,
# versioned by the build script's APP_VERSION plus the date (e.g.
# 1.0-20261117) -- see latest_code.py.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor

aviaozinhoachievements_publish_schedulers = {"aviaozinhoachievements-daily", "aviaozinhoachievements-publish"}

project_list = [
    util.Project(name="aviaozinhoachievements", description="aviaozinhoachievements source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/MacSourcePorts/aviaozinhoachievements',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/aviaozinhoachievements"),
        project="aviaozinhoachievements",
        branches=["main"],
        pollInterval=3600  # Poll every hour
    )
]

aviaozinhoachievements_factory = util.BuildFactory()

aviaozinhoachievements_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/aviaozinhoachievements',
    branch='main',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/aviaozinhoachievements"),
    name="Git Pull Latest aviaozinhoachievements Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

aviaozinhoachievements_factory.addStep(version_date_step())

aviaozinhoachievements_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements/macsourceports_universal2_bdd3.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements"),
    env=version_date_env(),
    name="Run Build Script for BDD3",
    haltOnFailure=True,
    extract_fn=make_release_extractor("aviaozinhoachievements_bdd3_dmg_path", "aviaozinhoachievements_bdd3_version"),
))

aviaozinhoachievements_factory.addStep(RequireProperty(
    "aviaozinhoachievements_bdd3_dmg_path",
    name="Verify BDD3 Build Produced a DMG",
    haltOnFailure=True,
))

aviaozinhoachievements_factory.addStep(RequireProperty(
    "aviaozinhoachievements_bdd3_version",
    name="Verify BDD3 Build Reported a Version",
    haltOnFailure=True,
))

aviaozinhoachievements_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements/macsourceports_universal2_bddb4.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements"),
    env=version_date_env(),
    name="Run Build Script for BDDB4",
    haltOnFailure=True,
    extract_fn=make_release_extractor("aviaozinhoachievements_bddb4_dmg_path", "aviaozinhoachievements_bddb4_version"),
))

aviaozinhoachievements_factory.addStep(RequireProperty(
    "aviaozinhoachievements_bddb4_dmg_path",
    name="Verify BDDB4 Build Produced a DMG",
    haltOnFailure=True,
))

aviaozinhoachievements_factory.addStep(RequireProperty(
    "aviaozinhoachievements_bddb4_version",
    name="Verify BDDB4 Build Reported a Version",
    haltOnFailure=True,
))

aviaozinhoachievements_factory.addStep(steps.SetPropertyFromCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements/macsourceports_universal2_fleshcancer.sh"), "notarize"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/aviaozinhoachievements"),
    env=version_date_env(),
    name="Run Build Script for FLESHCANCER",
    haltOnFailure=True,
    extract_fn=make_release_extractor("aviaozinhoachievements_fleshcancer_dmg_path", "aviaozinhoachievements_fleshcancer_version"),
))

aviaozinhoachievements_factory.addStep(RequireProperty(
    "aviaozinhoachievements_fleshcancer_dmg_path",
    name="Verify FLESHCANCER Build Produced a DMG",
    haltOnFailure=True,
))

aviaozinhoachievements_factory.addStep(RequireProperty(
    "aviaozinhoachievements_fleshcancer_version",
    name="Verify FLESHCANCER Build Reported a Version",
    haltOnFailure=True,
))

# Publish all of them as one release, once they've all built.
aviaozinhoachievements_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "aviaozinhoachievements",
        "--tag", util.Interpolate("aviaozinhoachievements_%(prop:aviaozinhoachievements_bdd3_version)s"),
        "--version", util.Property('aviaozinhoachievements_bdd3_version'),
        "--dmg", util.Property('aviaozinhoachievements_bdd3_dmg_path'),
        "--dmg", util.Property('aviaozinhoachievements_bddb4_dmg_path'),
        "--dmg", util.Property('aviaozinhoachievements_fleshcancer_dmg_path'),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/aviaozinhoachievements"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, aviaozinhoachievements_publish_schedulers),
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="aviaozinhoachievements-builder", workernames=["worker1"], factory=aviaozinhoachievements_factory, project="aviaozinhoachievements")
]

scheduler_list = [
    daily_scheduler("aviaozinhoachievements", "aviaozinhoachievements-builder", branches=["main"]),
    schedulers.ForceScheduler(
        name="aviaozinhoachievements-force",
        builderNames=["aviaozinhoachievements-builder"]),
    schedulers.ForceScheduler(
        name="aviaozinhoachievements-publish",
        builderNames=["aviaozinhoachievements-builder"])
]
