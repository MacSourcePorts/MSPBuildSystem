# Serious-Engine

# Project where we build based on the latest code of ptitSeb/Serious-Engine,
# which has no releases. Built and published at most once a day, versioned by
# each build script's APP_VERSION plus the date (ssfe-1.1-20261117) -- see
# latest_code.py.
#
# Two build scripts make two apps, each its own port on the site: The First
# Encounter (ssam-tfe) and The Second Encounter (ssam-tse). They're published
# together as one release.
#
# Our macOS changes, formerly in the MacSourcePorts fork, are applied by the
# build scripts from MSPBuildSystem/Serious-Engine/msp-macos.patch.

import os
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import scheduler_in, and_steps, is_publish_machine, RequireProperty
from projects.latest_code import daily_scheduler, version_date_step, version_date_env, make_release_extractor, CommitGuard, last_commit_date_step

SeriousEngine_publish_schedulers = {"Serious-Engine-daily", "Serious-Engine-publish"}

# skip the nightly build when the site already has one made since the
# last commit -- see CommitGuard in latest_code.py
SeriousEngine_guard = CommitGuard("Serious-Engine", force_scheduler_names={"Serious-Engine-force", "Serious-Engine-publish"})

project_list = [
    util.Project(name="Serious-Engine",description="Serious-Engine source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/ptitSeb/Serious-Engine',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/Serious-Engine"),
        project="Serious-Engine",
        branches=["master"],
        pollInterval=3600  # Poll every hour
    )
]

SeriousEngine_factory = util.BuildFactory()

SeriousEngine_factory.addStep(steps.Git(
    repourl='https://github.com/ptitSeb/Serious-Engine',
    branch='master',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Serious-Engine"),
    name="Git Pull Latest Serious-Engine Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))

SeriousEngine_factory.addStep(version_date_step())
SeriousEngine_factory.addStep(last_commit_date_step("~/Documents/GitHub/MacSourcePorts/Serious-Engine"))

# (script, step name, property prefix)
SeriousEngine_games = [
    ("ssfe", "First Encounter", "SeriousEngine_tfe"),
    ("ssse", "Second Encounter", "SeriousEngine_tse"),
]

for script, title, prop in SeriousEngine_games:
    SeriousEngine_factory.addStep(steps.SetPropertyFromCommand(
        command=["/bin/bash", os.path.expanduser(f"~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Serious-Engine/macsourceports_universal2-{script}.sh"), "notarize"],
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/Serious-Engine"),
        env=version_date_env(),
        name=f"Run Build Script for {title}",
        haltOnFailure=True,
        doStepIf=SeriousEngine_guard.should_build,
        extract_fn=make_release_extractor(f"{prop}_dmg_path", f"{prop}_version"),
    ))

    SeriousEngine_factory.addStep(RequireProperty(
        f"{prop}_dmg_path",
        name=f"Verify {title} Build Produced a DMG",
        haltOnFailure=True,
        doStepIf=SeriousEngine_guard.should_build,
    ))

    SeriousEngine_factory.addStep(RequireProperty(
        f"{prop}_version",
        name=f"Verify {title} Build Reported a Version",
        haltOnFailure=True,
        doStepIf=SeriousEngine_guard.should_build,
    ))

# The scripts' versions carry a game prefix (ssfe-1.1-20261117) so their
# release folders don't collide; the site's version is just 1.1-20261117.
@util.renderer
def SeriousEngine_site_version(props):
    return props.getProperty("SeriousEngine_tfe_version").split("-", 1)[1]

# Publish both games as one release, once both have built.
SeriousEngine_factory.addStep(steps.ShellCommand(
    command=[
        "python3",
        os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/publish_release.py"),
        "--project", "Serious-Engine",
        "--tag", util.Interpolate("Serious-Engine_%(kw:version)s", version=SeriousEngine_site_version),
        "--version", SeriousEngine_site_version,
        "--dmg", util.Property("SeriousEngine_tfe_dmg_path"),
        "--dmg", util.Property("SeriousEngine_tse_dmg_path"),
    ],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/Serious-Engine"),
    name="Publish Release",
    haltOnFailure=True,
    doStepIf=and_steps(
        lambda step: scheduler_in(step, SeriousEngine_publish_schedulers),
        SeriousEngine_guard.should_build,
        lambda step: is_publish_machine(),
    )
))

builder_configs = [
    util.BuilderConfig(name="Serious-Engine-builder", workernames=["worker1"], factory=SeriousEngine_factory, project="Serious-Engine")
]

scheduler_list = [
    daily_scheduler("Serious-Engine", "Serious-Engine-builder", branches=["master"]),
    schedulers.ForceScheduler(
        name="Serious-Engine-force",
        builderNames=["Serious-Engine-builder"]),
    schedulers.ForceScheduler(
        name="Serious-Engine-publish",
        builderNames=["Serious-Engine-builder"])
]
