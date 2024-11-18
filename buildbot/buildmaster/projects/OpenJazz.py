# OpenJazz

# Project where we build based off of release tags from the project

import os
from buildbot.plugins import steps, util, changes, schedulers

project_list = [ 
    util.Project(name="OpenJazz",description="OpenJazz source port project")
]

change_source_list = [
    # changes.GitPoller(
    #     repourl='https://github.com/MacSourcePorts/openjazz',
    #     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/buildbot/workdirs/OpenJazz"),
    #     project="OpenJazz",
    #     only_tags=True,
    #     pollInterval=3600  # Poll every hour
    # )
]

OpenJazz_factory = util.BuildFactory()
OpenJazz_factory.addStep(steps.Git(
    repourl='https://github.com/MacSourcePorts/openjazz',
    mode='full',  # Equivalent to 'git fetch' + 'git reset --hard'
    method='clobber',  # Remove untracked files
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJazz"),
    name="Git Pull Latest OpenJazz Code",
    haltOnFailure=True
))
# OpenJazz_factory.addStep(steps.SetPropertyFromCommand(
#     command=["bash", "-c", "git rev-list --tags --max-count=1 | xargs git describe --tags"],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJazz"),
#     property="OpenJazz_latest_tag",
#     name="Fetch Latest OpenJazz Tag",
#     haltOnFailure=True
# ))
# OpenJazz_factory.addStep(steps.ShellCommand(
#     command=["git", "checkout", util.Property('OpenJazz_latest_tag')],
#     workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/OpenJazz"),
#     name="Checkout Latest Tag",
#     haltOnFailure=True
# ))
OpenJazz_factory.addStep(steps.ShellCommand(
    command=["/bin/bash", os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJazz/macsourceports_universal2.sh"), "notarize", "buildserver", util.Property('OpenJazz_latest_tag')],
    workdir=os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/OpenJazz"),
    name="Run Build Script",
    haltOnFailure=True
))

builder_configs = [
    util.BuilderConfig(name="OpenJazz-builder", workernames=["worker1"], factory=OpenJazz_factory, project="OpenJazz")
]

scheduler_list = [ 
    # schedulers.SingleBranchScheduler(
    #     name="OpenJazz-changes",
    #     change_filter=util.ChangeFilter(project='OpenJazz', branch='dev'),
    #     treeStableTimer=None,
    #     builderNames=["OpenJazz-builder"]),
    schedulers.ForceScheduler(
        name="OpenJazz-force",
        builderNames=["OpenJazz-builder"],
        codebases=[
            util.CodebaseParameter(
            "",
            label="Main repository",
            # will generate a combo box
            branch=util.ChoiceStringParameter(
                name="branch",
                choices=["master", "dev"],
                default="dev"),
            revision=util.FixedParameter(name="revision", default=""),
            repository=util.FixedParameter(name="repository", default=""),
            project=util.FixedParameter(name="project", default=""),
            )
        ]
    )
]