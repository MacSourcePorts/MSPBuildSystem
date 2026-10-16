#!/usr/bin/env python3
"""
check_thirdparty.py — keeps third-party (non-MSP) builds in sourceports.json
pointed at the latest upstream GitHub release.

For each port listed in thirdparty.json:

  1. Ask the GitHub API (via `gh`) for the project's recent releases and
     pick the newest one that isn't a draft, isn't a prerelease (unless
     "includePrereleases": true) and whose tag matches "tagRegex" if given.
  2. For each configured buildType, find the one release asset matching
     "assetGlob" (or "assetRegex", when a glob can't tell files apart). Zero or several matches is a problem for that port
     (upstream renamed its files, or hasn't finished uploading them) and
     the port is skipped.
  3. If the asset's download URL differs from the builds[] entry's
     downloadURL, update downloadURL / version / buildDate on that entry
     and bump the port's lastUpdated.

It then commits and pushes sourceports.json the same way
publish_release.py does, using the same publish_config.json.

Like publish_release.py, it only ever UPDATES existing entries — and only
entries WITHOUT "MSPBuild": true, so it can never clobber one of our own
builds. Add a port/buildType by hand once, then list it in thirdparty.json.

thirdparty.json entry format:

    {
        "sourcePortStub": "openmw",
        "repo": "OpenMW/openmw",
        "tagRegex": "^openmw-\\\\d+\\\\.\\\\d+\\\\.\\\\d+$",   (optional)
        "versionRegex": "^v?(.*)$",                (optional; group 1 = version,
                                                    default is the tag as-is)
        "versionTemplate": "\\\\1.\\\\2.\\\\3",            (optional, with versionRegex: build the
                                                    version from several groups, e.g.
                                                    release_26_0_1 -> 26.0.1)
        "includePrereleases": false,               (optional)
        "builds": [
            { "buildType": 3, "assetGlob": "OpenMW-*-macOS-arm64.dmg" },
            { "buildType": 4, "assetGlob": "OpenMW-*-macOS-x86_64.dmg" }
        ]
    }

Exit codes (so Buildbot can map them): 0 = nothing to do or changes
pushed, 1 = fatal error, 2 = at least one port had a problem (others may
still have been updated), 3 = --dry-run / --no-push found updates that
would be made.

Testing modes, least to most real:
  --dry-run   reads the site repo as-is (no pull) and lists what would change.
  --no-push   pulls the site repo like a real run, then prints the exact
              sourceports.json diff and commit message — but writes,
              commits and pushes nothing.

The last line of output is always MSP_THIRDPARTY_REPORT=<json> (mode,
updates, problems), which the Buildbot step turns into a build property
so the notification email can list the changes.
"""

import argparse
import datetime
import difflib
import fnmatch
import json
import re
import subprocess
import sys
import urllib.parse
from pathlib import Path

from publish_release import (
    ensure_gh_ready,
    find_port,
    format_build_date,
    git_commit_and_push,
    iso_now,
    load_config,
    run,
)


# ---------------------------------------------------------------------------
# Manifest (thirdparty.json)


def load_thirdparty_manifest(path: Path) -> list:
    if not path.exists():
        sys.exit(f"Third-party manifest not found: {path}")
    with path.open() as f:
        manifest = json.load(f)
    for i, entry in enumerate(manifest):
        for key in ("sourcePortStub", "repo", "builds"):
            if key not in entry:
                sys.exit(f"{path}: entry {i} is missing '{key}'")
        for j, b in enumerate(entry["builds"]):
            if "buildType" not in b or ("assetGlob" in b) == ("assetRegex" in b):
                sys.exit(f"{path}: entry {i} ({entry['sourcePortStub']}) build {j} needs "
                         f"'buildType' and exactly one of 'assetGlob' / 'assetRegex'")
    return manifest


# ---------------------------------------------------------------------------
# GitHub


def fetch_releases(repo: str) -> list:
    result = subprocess.run(
        ["gh", "api", f"repos/{repo}/releases?per_page=30"],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"gh api failed for {repo}: {result.stderr.strip()}")
    return json.loads(result.stdout)


def pick_release(releases: list, entry: dict):
    tag_re = re.compile(entry["tagRegex"]) if "tagRegex" in entry else None
    allow_pre = entry.get("includePrereleases", False)
    candidates = [
        r for r in releases
        if not r.get("draft")
        and (allow_pre or not r.get("prerelease"))
        and (tag_re is None or tag_re.search(r["tag_name"]))
        and r.get("published_at")
    ]
    return max(candidates, key=lambda r: r["published_at"], default=None)


def version_from_tag(tag: str, entry: dict) -> str:
    if "versionRegex" not in entry:
        return tag
    m = re.search(entry["versionRegex"], tag)
    if not m:
        raise ValueError(f"versionRegex {entry['versionRegex']!r} does not match tag {tag!r}")
    if "versionTemplate" in entry:
        return m.expand(entry["versionTemplate"])
    return m.group(1)


def release_build_date(release: dict) -> str:
    # Use the release's own publish date, in local time, so a release made
    # late in the evening US time doesn't show up as "tomorrow".
    published = datetime.datetime.fromisoformat(release["published_at"].replace("Z", "+00:00"))
    return format_build_date(published.astimezone().date())


# ---------------------------------------------------------------------------
# sourceports.json


def asset_matches(name: str, build: dict) -> bool:
    if "assetRegex" in build:
        return re.search(build["assetRegex"], name) is not None
    return fnmatch.fnmatch(name, build["assetGlob"])


def find_thirdparty_entry(port, build_type: int):
    if port is None:
        return None
    return next(
        (b for b in port.get("builds", [])
         if b.get("buildType") == build_type and b.get("MSPBuild") is not True),
        None,
    )


def check_port(entry: dict, ports: list):
    """Returns (updates, problems). Each update is (build_entry, port, new_values, old_version)."""
    stub = entry["sourcePortStub"]
    port = find_port(ports, stub)
    if port is None:
        return [], [f"{stub}: no port with this stub in sourceports.json"]

    try:
        releases = fetch_releases(entry["repo"])
    except RuntimeError as e:
        return [], [f"{stub}: {e}"]

    release = pick_release(releases, entry)
    if release is None:
        return [], [f"{stub}: no qualifying release found on {entry['repo']}"]

    try:
        version = version_from_tag(release["tag_name"], entry)
    except ValueError as e:
        return [], [f"{stub}: {e}"]

    build_date = release_build_date(release)
    uploaded = [a for a in release.get("assets", []) if a.get("state") == "uploaded"]

    updates, problems = [], []
    for b in entry["builds"]:
        build_type = b["buildType"]
        target = find_thirdparty_entry(port, build_type)
        if target is None:
            problems.append(f"{stub} buildType {build_type}: no non-MSPBuild builds[] entry to update")
            continue
        matches = [a for a in uploaded if asset_matches(a["name"], b)]
        if len(matches) != 1:
            names = [a["name"] for a in matches] or "none"
            problems.append(
                f"{stub} buildType {build_type}: release {release['tag_name']} has "
                f"{len(matches)} assets matching '{b.get('assetGlob') or b['assetRegex']}' ({names})"
            )
            continue
        new_url = matches[0]["browser_download_url"]
        # Compare decoded: the API gives ".../download/releases/1.1.1/..." where
        # the site may have the equivalent ".../download/releases%2F1.1.1/...".
        if urllib.parse.unquote(target.get("downloadURL") or "") == urllib.parse.unquote(new_url):
            continue
        updates.append((target, port, {
            "downloadURL": new_url,
            "version": version,
            "buildDate": build_date,
        }, target.get("version")))

    # Don't half-update a port: if any of its buildTypes had a problem
    # (e.g. arm64 DMG uploaded but Intel not yet), leave the whole port alone.
    if problems:
        return [], problems
    return updates, []


# ---------------------------------------------------------------------------
# Main


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                      formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--manifest", default=Path(__file__).parent / "thirdparty.json",
                         type=Path, help="Path to thirdparty.json (default: next to this script)")
    parser.add_argument("--config", default=Path(__file__).parent / "publish_config.json",
                         type=Path, help="Path to publish_config.json (default: next to this script)")
    parser.add_argument("--only", action="append", metavar="STUB",
                         help="Only check this sourcePortStub. Repeatable.")
    parser.add_argument("--dry-run", action="store_true",
                         help="Print what would change; don't pull, write, commit or push")
    parser.add_argument("--no-push", action="store_true",
                         help="Pull the site repo and print the exact diff and commit message, "
                              "but don't write, commit or push")
    args = parser.parse_args()
    preview = args.dry_run or args.no_push

    cfg = load_config(args.config)
    site_repo = Path(cfg["siteRepoPath"])
    branch = cfg["siteRepoBranch"]
    rel_json_path = cfg["sourceportsJsonPath"]
    json_path = site_repo / rel_json_path

    ensure_gh_ready()

    manifest = load_thirdparty_manifest(args.manifest)
    if args.only:
        manifest = [e for e in manifest if e["sourcePortStub"] in args.only]
        if not manifest:
            sys.exit(f"None of {args.only} are listed in {args.manifest}")

    if not args.dry_run:
        run(["git", "-C", str(site_repo), "fetch", "origin", branch])
        run(["git", "-C", str(site_repo), "checkout", branch])
        run(["git", "-C", str(site_repo), "pull", "--ff-only", "origin", branch])

    if not json_path.exists():
        sys.exit(f"sourceports.json not found at {json_path} — check your config's "
                  f"siteRepoPath/sourceportsJsonPath.")
    with json_path.open(encoding="utf-8") as f:
        ports = json.load(f)

    all_updates, all_problems = [], []
    for entry in manifest:
        updates, problems = check_port(entry, ports)
        all_updates += updates
        all_problems += problems
        if not updates and not problems:
            print(f"{entry['sourcePortStub']}: up to date")

    summary_lines = []
    touched_ports = []
    report_updates = []
    for target, port, new_values, old_version in all_updates:
        report_updates.append({
            "stub": port["sourcePortStub"],
            "buildType": target["buildType"],
            "old": old_version,
            "new": new_values["version"],
            "url": new_values["downloadURL"],
        })
        target.update(new_values)
        if port not in touched_ports:
            touched_ports.append(port)
        summary_lines.append(
            f"{port['sourcePortStub']} (buildType {target['buildType']}): "
            f"{old_version} -> {new_values['version']}\n    {new_values['downloadURL']}"
        )
    now = iso_now()
    for port in touched_ports:
        port["lastUpdated"] = now

    for line in summary_lines:
        prefix = "[no-push] would update " if args.no_push else "[dry-run] would update " if args.dry_run else "Updated "
        print(prefix + line)
    for p in all_problems:
        print(f"PROBLEM: {p}")

    if all_updates:
        new_text = json.dumps(ports, indent=4, ensure_ascii=False) + "\n"
        stubs = ", ".join(p["sourcePortStub"] for p in touched_ports)
        commit_message = f"Update third-party builds ({stubs})"
        if args.no_push:
            old_text = json_path.read_text(encoding="utf-8")
            print(f"\n[no-push] would commit to {site_repo} on {branch}: {commit_message}\n")
            sys.stdout.writelines(difflib.unified_diff(
                old_text.splitlines(keepends=True), new_text.splitlines(keepends=True),
                fromfile=f"a/{rel_json_path}", tofile=f"b/{rel_json_path}"))
            print("\n[no-push] Nothing was written, committed or pushed.")
        elif not args.dry_run:
            json_path.write_text(new_text, encoding="utf-8")
            git_commit_and_push(site_repo, branch, rel_json_path, commit_message, dry_run=False)

    if not all_updates:
        print("No third-party updates.")

    mode = "no-push" if args.no_push else "dry-run" if args.dry_run else "published"
    print("MSP_THIRDPARTY_REPORT=" + json.dumps(
        {"mode": mode, "updates": report_updates, "problems": all_problems}))

    if all_problems:
        sys.exit(2)
    if all_updates and preview:
        sys.exit(3)


if __name__ == "__main__":
    main()
