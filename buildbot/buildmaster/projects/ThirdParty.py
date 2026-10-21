# Third-party ports

# Doesn't build anything: checks the GitHub releases of the ports listed in
# common/thirdparty.json and points their sourceports.json entries at any
# newer release. Only the publish machine (~/.msp_publish_machine) commits
# and pushes; everywhere else it runs --no-push, which pulls the site repo
# and shows the exact diff it would commit (as WARNINGS) without changing it.

import json
import os
import re
from twisted.internet import defer
from buildbot.plugins import steps, util, schedulers
from buildbot.process import logobserver
from projects.version_guard import is_publish_machine

project_list = [
    util.Project(name="ThirdParty", description="Third-party release tracker (no builds)")
]

change_source_list = []

ThirdParty_script = os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common/check_thirdparty.py")
ThirdParty_workdir = os.path.expanduser("~/Documents/GitHub/MacSourcePorts/MSPBuildSystem/common")
# 0 = nothing new / pushed, 2 = a port had a problem, 3 = preview found updates
ThirdParty_decodeRC = {0: util.SUCCESS, 2: util.WARNINGS, 3: util.WARNINGS}



class ThirdPartyCheck(steps.ShellCommand):
    """ShellCommand that also reads the script's final
    MSP_THIRDPARTY_REPORT=<json> line into the 'thirdparty_report'
    property (which the email template in master.cfg lists out), and
    sets 'resolved_tag' to a one-line summary for the email subject."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.observer = logobserver.BufferLogObserver(wantStdout=True, wantStderr=False)
        self.addLogObserver('stdio', self.observer)

    @defer.inlineCallbacks
    def run(self):
        results = yield super().run()
        match = re.search(r'^MSP_THIRDPARTY_REPORT=(.*)$', self.observer.getStdout(), re.MULTILINE)
        if match:
            report = json.loads(match.group(1))
            self.setProperty('thirdparty_report', report, 'ThirdPartyCheck')
            parts = []
            if report['updates']:
                verb = "updated" if report['mode'] == "published" else "to update"
                parts.append(f"{len(report['updates'])} {verb}")
            released = [x for x in report.get('social', []) if x['action'] == 'released']
            if released:
                verb = "posted" if report['mode'] == "published" else "to post"
                parts.append(f"{len(released)} held post(s) {verb}")
            if report['problems']:
                parts.append(f"{len(report['problems'])} problem(s)")
            self.setProperty('resolved_tag', ", ".join(parts) or "nothing new", 'ThirdPartyCheck')
        return results


ThirdParty_factory = util.BuildFactory()

ThirdParty_factory.addStep(ThirdPartyCheck(
    command=["python3", ThirdParty_script, "--no-push"],
    workdir=ThirdParty_workdir,
    name="Check Third-Party Releases (no push)",
    decodeRC=ThirdParty_decodeRC,
    haltOnFailure=True,
    doStepIf=lambda step: not is_publish_machine(),
    hideStepIf=lambda results, step: results == util.SKIPPED,
))

ThirdParty_factory.addStep(ThirdPartyCheck(
    command=["python3", ThirdParty_script],
    workdir=ThirdParty_workdir,
    name="Check and Publish Third-Party Releases",
    decodeRC=ThirdParty_decodeRC,
    haltOnFailure=True,
    doStepIf=lambda step: is_publish_machine(),
    hideStepIf=lambda results, step: results == util.SKIPPED,
))

builder_configs = [
    util.BuilderConfig(name="ThirdParty-builder", workernames=["worker1"], factory=ThirdParty_factory, project="ThirdParty")
]

scheduler_list = [
    schedulers.Nightly(
        name="ThirdParty-daily",
        builderNames=["ThirdParty-builder"],
        hour=6, minute=0),
    schedulers.ForceScheduler(
        name="ThirdParty-force",
        builderNames=["ThirdParty-builder"])
]
