#!/usr/bin/env python3
"""
publish_release.py — automates the "last mile" of an MSP build:

  1. Create (or reuse) a GitHub release under MacSourcePorts/MSPBuildSystem
     and upload the DMG(s) produced by a build.
  2. Work out the resulting download URL(s). These are fully predictable
     from (repo, tag, filename) — no API lookup is required.
  3. Match each DMG against that project's publish.json manifest to find
     which sourceports.json port entry (and buildType) it belongs to.
  4. Update sourceports.json in your (private) website repo: for each
     matched port, find the builds[] entry where buildType matches AND
     MSPBuild is true, and update downloadURL / version / buildDate.
     Bump the port's top-level lastUpdated.
  5. Commit and push the website repo. Your existing GitHub Action takes
     it from there.

This script only ever UPDATES an existing builds[] entry. It never
creates a new port and never inserts a new buildType entry — if no
matching entry (buildType + "MSPBuild": true) already exists for a
port, the whole run fails before touching GitHub or git. Add a port or
a new buildType by hand once; this script is only for the repeat
updates after that.

It also never touches a builds[] entry that does not have
"MSPBuild": true — those are third-party links (DevilutionX's PPC
build, iortcw's old Universal 1 build, etc.) and are none of its business.

Run with --dry-run first on anything new. It skips the GitHub release
and the git push/commit, and instead prints exactly what it would have
done.

See README.md in this folder for setup and full usage examples.
"""

import argparse
import datetime
import fnmatch
import json
import shutil
import subprocess
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Config


def load_config(config_path: Path) -> dict:
    if not config_path.exists():
        sys.exit(
            f"Config file not found: {config_path}\n"
            f"Copy publish_config.json.example to publish_config.json "
            f"(next to this script, or wherever you point --config) and "
            f"fill in your paths."
        )
    with config_path.open() as f:
        cfg = json.load(f)
    required = ["mspBuildSystemRoot", "siteRepoPath", "siteRepoBranch", "sourceportsJsonPath"]
    missing = [k for k in required if k not in cfg]
    if missing:
        sys.exit(f"Config file {config_path} is missing keys: {', '.join(missing)}")
    return cfg


# ---------------------------------------------------------------------------
# Manifest (per-project publish.json)


def load_manifest(msp_root: Path, project: str) -> list:
    manifest_path = msp_root / project / "publish.json"
    if not manifest_path.exists():
        sys.exit(
            f"No manifest found at {manifest_path}\n"
            f"Every project needs a publish.json describing which DMG "
            f"filename pattern maps to which sourcePortStub/buildType. "
            f"See the examples in this folder."
        )
    with manifest_path.open() as f:
        manifest = json.load(f)
    for i, entry in enumerate(manifest):
        for key in ("filenameGlob", "sourcePortStub", "buildType"):
            if key not in entry:
                sys.exit(f"{manifest_path}: entry {i} is missing '{key}'")
    return manifest


def match_dmg_to_manifest(dmg_path: Path, manifest: list) -> dict:
    matches = [e for e in manifest if fnmatch.fnmatch(dmg_path.name, e["filenameGlob"])]
    if not matches:
        sys.exit(
            f"'{dmg_path.name}' matches no filenameGlob in this project's publish.json. "
            f"Add an entry for it (or fix the glob) before publishing."
        )
    if len(matches) > 1:
        sys.exit(
            f"'{dmg_path.name}' matches more than one entry in publish.json "
            f"({[m['sourcePortStub'] for m in matches]}) — globs must be unambiguous."
        )
    return matches[0]


# ---------------------------------------------------------------------------
# GitHub release


def run(cmd, **kwargs):
    print(f"$ {' '.join(str(c) for c in cmd)}")
    return subprocess.run(cmd, check=True, **kwargs)


def ensure_gh_ready():
    if shutil.which("gh") is None:
        sys.exit(
            "GitHub CLI ('gh') not found on PATH. Install it (e.g. `brew install gh`) "
            "and run `gh auth login` once before using this script."
        )
    try:
        subprocess.run(["gh", "auth", "status"], check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        sys.exit(f"'gh auth status' failed — run `gh auth login` first.\n{e.stderr}")


def release_exists(repo: str, tag: str) -> bool:
    result = subprocess.run(
        ["gh", "release", "view", tag, "--repo", repo],
        capture_output=True, text=True,
    )
    return result.returncode == 0


def create_or_update_release(repo: str, tag: str, title: str, notes: str,
                              dmg_paths: list, dry_run: bool):
    if dry_run:
        print(f"[dry-run] would create/update release {tag} on {repo} with:")
        for p in dmg_paths:
            print(f"          {p}")
        return

    if release_exists(repo, tag):
        print(f"Release {tag} already exists on {repo}; uploading assets with --clobber.")
        run(["gh", "release", "upload", tag, *[str(p) for p in dmg_paths],
             "--repo", repo, "--clobber"])
    else:
        run(["gh", "release", "create", tag, *[str(p) for p in dmg_paths],
             "--repo", repo, "--title", title, "--notes", notes])


def download_url(repo: str, tag: str, filename: str) -> str:
    return f"https://github.com/{repo}/releases/download/{tag}/{filename}"


# ---------------------------------------------------------------------------
# sourceports.json editing


def format_build_date(d: datetime.date) -> str:
    # Matches the existing file's style: "September 9, 2026" (no zero-padded day)
    return f"{d.strftime('%B')} {d.day}, {d.year}"


def iso_now() -> str:
    return datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="milliseconds").replace(
        "+00:00", "Z"
    )


def find_port(ports: list, stub: str):
    return next((p for p in ports if p.get("sourcePortStub") == stub), None)


def find_msp_build_entry(port, build_type: int):
    if port is None:
        return None
    builds = port.get("builds", [])
    return next(
        (b for b in builds if b.get("buildType") == build_type and b.get("MSPBuild") is True),
        None,
    )


def validate_targets_exist(ports: list, updates: list):
    """Fail loudly, before touching GitHub or git, if any update has no
    existing (sourcePortStub, buildType, MSPBuild=true) entry to land on.
    This script never creates ports or buildType entries — those are
    added by hand, once."""
    problems = []
    for stub, build_type, *_ in updates:
        port = find_port(ports, stub)
        if port is None:
            problems.append(f"sourcePortStub='{stub}': no port with this stub exists in sourceports.json")
        elif find_msp_build_entry(port, build_type) is None:
            problems.append(
                f"sourcePortStub='{stub}', buildType={build_type}: port exists but has no "
                f"builds[] entry with this buildType and \"MSPBuild\": true"
            )
    if problems:
        lines = "\n".join(f"  - {p}" for p in problems)
        sys.exit(
            "Refusing to publish: this script only updates builds[] entries that "
            "already exist — it never creates a new port or a new buildType entry.\n"
            f"{lines}\n"
            "Add the entry by hand in sourceports.json once, then re-run."
        )


def apply_update(ports: list, stub: str, build_type: int, new_url: str,
                  version: str, build_date: str) -> str:
    """Mutates the matched builds[] entry in place. Assumes
    validate_targets_exist has already confirmed it exists. Returns the
    entry's previous version string, for reporting."""
    port = find_port(ports, stub)
    entry = find_msp_build_entry(port, build_type)
    old_version = entry.get("version")
    entry["downloadURL"] = new_url
    entry["version"] = version
    entry["buildDate"] = build_date
    port["lastUpdated"] = iso_now()
    return old_version


# ---------------------------------------------------------------------------
# Site repo git operations


def git_commit_and_push(site_repo: Path, branch: str, rel_json_path: str,
                         commit_message: str, dry_run: bool):
    """Assumes the caller already fetched/checked-out/pulled `branch` before
    editing the file (main() does this up front, before validation)."""
    if dry_run:
        print(f"[dry-run] would commit '{rel_json_path}' in {site_repo} on {branch} "
              f"with message:\n  {commit_message}")
        return

    status = subprocess.run(
        ["git", "-C", str(site_repo), "status", "--porcelain", "--", rel_json_path],
        capture_output=True, text=True, check=True,
    )
    if not status.stdout.strip():
        print("No changes to commit (JSON already matched — nothing to push).")
        return

    run(["git", "-C", str(site_repo), "add", rel_json_path])
    run(["git", "-C", str(site_repo), "commit", "-m", commit_message])
    run(["git", "-C", str(site_repo), "push", "origin", branch])


# ---------------------------------------------------------------------------
# Main


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                      formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--project", required=True,
                         help="Project folder name in MSPBuildSystem, e.g. UZDoom")
    parser.add_argument("--tag", required=True,
                         help="Exact release tag to use, e.g. UZDoom_5.0.1 "
                              "(the build step decides this — some projects need a date suffix)")
    parser.add_argument("--version", required=True,
                         help="Version string to write into sourceports.json, e.g. 5.0.1")
    parser.add_argument("--dmg", required=True, action="append",
                         help="Path to a DMG to publish. Repeat --dmg for multiple files.")
    parser.add_argument("--repo", default="MacSourcePorts/MSPBuildSystem",
                         help="GitHub repo to create the release on (default: %(default)s)")
    parser.add_argument("--title", default=None,
                         help="Release title (default: '<project> <version>')")
    parser.add_argument("--notes", default="",
                         help="Release notes body (default: empty)")
    parser.add_argument("--config", default=Path(__file__).parent / "publish_config.json",
                         type=Path, help="Path to publish_config.json (default: next to this script)")
    parser.add_argument("--dry-run", action="store_true",
                         help="Print what would happen; touch neither GitHub nor git")
    args = parser.parse_args()

    cfg = load_config(args.config)
    msp_root = Path(cfg["mspBuildSystemRoot"])
    site_repo = Path(cfg["siteRepoPath"])
    branch = cfg["siteRepoBranch"]
    rel_json_path = cfg["sourceportsJsonPath"]
    json_path = site_repo / rel_json_path

    dmg_paths = [Path(p) for p in args.dmg]
    for p in dmg_paths:
        if not p.exists():
            sys.exit(f"DMG not found: {p}")

    if not args.dry_run:
        ensure_gh_ready()

    manifest = load_manifest(msp_root, args.project)

    build_date_str = format_build_date(datetime.date.today())
    updates = []
    for dmg_path in dmg_paths:
        entry = match_dmg_to_manifest(dmg_path, manifest)
        url = download_url(args.repo, args.tag, dmg_path.name)
        updates.append((entry["sourcePortStub"], entry["buildType"], url,
                         args.version, build_date_str))
        print(f"{dmg_path.name} -> sourcePortStub='{entry['sourcePortStub']}' "
              f"buildType={entry['buildType']}\n  {url}")

    # Get the freshest copy of sourceports.json before validating against it.
    if not args.dry_run:
        run(["git", "-C", str(site_repo), "fetch", "origin", branch])
        run(["git", "-C", str(site_repo), "checkout", branch])
        run(["git", "-C", str(site_repo), "pull", "--ff-only", "origin", branch])

    if not json_path.exists():
        if args.dry_run:
            print(f"[dry-run] sourceports.json not found at {json_path} (check your "
                  f"config's siteRepoPath/sourceportsJsonPath) — showing planned "
                  f"updates only, computed from the manifest. Existence of a "
                  f"matching builds[] entry could NOT be verified without the file:")
            for stub, build_type, url, version, build_date in updates:
                print(f"  {stub} (buildType {build_type}) -> version {version}, {url}")
            print("\n[dry-run] Nothing was actually changed.")
            return
        sys.exit(f"sourceports.json not found at {json_path} — check your config's "
                  f"siteRepoPath/sourceportsJsonPath.")

    with json_path.open(encoding="utf-8") as f:
        ports = json.load(f)

    # Fail here — before creating anything on GitHub — if any target doesn't
    # already exist. First-time ports/buildTypes are added by hand.
    validate_targets_exist(ports, updates)

    title = args.title or f"{args.project} {args.version}"
    create_or_update_release(args.repo, args.tag, title, args.notes, dmg_paths, args.dry_run)

    summary_lines = []
    for stub, build_type, url, version, build_date in updates:
        old_version = apply_update(ports, stub, build_type, url, version, build_date)
        summary_lines.append(f"{stub} (buildType {build_type}): {old_version} -> {version}")

    new_text = json.dumps(ports, indent=4, ensure_ascii=False) + "\n"

    if args.dry_run:
        print("[dry-run] sourceports.json would be updated as follows:")
        for line in summary_lines:
            print(f"  {line}")
        print("\n[dry-run] Nothing was actually changed.")
        return

    json_path.write_text(new_text, encoding="utf-8")

    stubs = ", ".join(u[0] for u in updates)
    commit_message = f"Publish {args.project} {args.version} ({stubs})"

    git_commit_and_push(site_repo, branch, rel_json_path, commit_message, args.dry_run)

    print("\nDone.")


if __name__ == "__main__":
    main()
