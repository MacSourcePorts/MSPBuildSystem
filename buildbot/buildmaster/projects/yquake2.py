# yquake2

# Project where we build based off of release tags from the project

import os
import re
from buildbot.plugins import steps, util, changes, schedulers
from projects.version_guard import VersionGuard, RecordBuiltTag

# Only treat clean "QUAKE2_<major>_<minor>" tags as real releases -- this
# excludes QUAKE2_8_00_RC1, QUAKE2_WIN32_TEST1/TEST3, and anything else
# that isn't a genuine numbered release.
_yquake2_release_re = re.compile(r'^QUAKE2_\d+_\d+$')

yquake2_guard = VersionGuard(
    project_name="yquake2",
    tag_property="yquake2_latest_tag",
    tag_filter=lambda tag: bool(_yquake2_release_re.match(tag)),
    force_scheduler_names={"yquake2-force"},
)


project_list = [ 
    util.Project(name="yquake2",description="yquake2 source port project")
]

change_source_list = [
    changes.GitPoller(
        repourl='https://github.com/yquake2/yquake2',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/yquake2"),
        project="yquake2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    ),
    changes.GitPoller(
        repourl='https://github.com/yquake2/xatrix',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/xatrix"),
        project="yquake2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    ),
    changes.GitPoller(
        repourl='https://github.com/yquake2/rogue',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/rogue"),
        project="yquake2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    ),
    changes.GitPoller(
        repourl='https://github.com/yquake2/ctf',
        workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/ctf"),
        project="yquake2",
        only_tags=True,
        pollInterval=3600  # Poll every hour
    )
]

yquake2_factory = util.BuildFactory()
yquake2_factory.addStep(steps.Git(
    repourl='https://github.com/yquake2/yquake2',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/yquake2"),
    name="Git Pull Latest yquake2 Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))
yquake2_factory.addStep(steps.Git(
    repourl='https://github.com/yquake2/xatrix',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xatrix"),
    name="Git Pull Latest xatrix (mp1) Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))
yquake2_factory.addStep(steps.Git(
    repourl='https://github.com/yquake2/rogue',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rogue"),
    name="Git Pull Latest rogue (mp2) Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))
yquake2_factory.addStep(steps.Git(
    repourl='https://github.com/yquake2/ctf',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ctf"),
    name="Git Pull Latest ctf Code",
    alwaysUseLatest=True,
    haltOnFailure=True
))
yquake2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/yquake2"),
    property="yquake2_latest_tag",
    name="Fetch Latest yquake2 Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xatrix"),
    property="xatrix_latest_tag",
    name="Fetch Latest xatrix (mp1) Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rogue"),
    property="rogue_latest_tag",
    name="Fetch Latest rogue (mp2) Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.SetPropertyFromCommand(
    command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ctf"),
    property="ctf_latest_tag",
    name="Fetch Latest ctf Tag",
    haltOnFailure=True
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('yquake2_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/yquake2"),
    name="Checkout Latest yquake2 Tag",
    haltOnFailure=True,
    doStepIf=yquake2_guard.should_build,
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('xatrix_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/xatrix"),
    name="Checkout Latest xatrix (mp1) Tag",
    haltOnFailure=True,
    doStepIf=yquake2_guard.should_build,
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('rogue_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/rogue"),
    name="Checkout Latest rogue (mp2) Tag",
    haltOnFailure=True,
    doStepIf=yquake2_guard.should_build,
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["git", "checkout", util.Property('ctf_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/ctf"),
    name="Checkout Latest ctf Tag",
    haltOnFailure=True,
    doStepIf=yquake2_guard.should_build,
))
yquake2_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/yquake2/macsourceports_universal2.sh"), "notarize", util.Property('yquake2_latest_tag'), util.Property('xatrix_latest_tag'), util.Property('rogue_latest_tag'), util.Property('ctf_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/yquake2"),
    name="Run Build Script",
    haltOnFailure=True,
    doStepIf=yquake2_guard.should_build,
))

# NEW: only reached if the build actually ran and succeeded
yquake2_factory.addStep(RecordBuiltTag(yquake2_guard, doStepIf=yquake2_guard.should_build))

builder_configs = [
    util.BuilderConfig(name="yquake2-builder", workernames=["worker1"], factory=yquake2_factory, project="yquake2")
]

scheduler_list = [ 
    schedulers.SingleBranchScheduler(
        name="yquake2-releases",
        change_filter=util.ChangeFilter(project='yquake2'),
        treeStableTimer=60,
        builderNames=["yquake2-builder"]),
    schedulers.ForceScheduler(
        name="yquake2-force",
        builderNames=["yquake2-builder"]),
    schedulers.ForceScheduler(
        name="yquake2-force-test-guard",
        builderNames=["yquake2-builder"])
]