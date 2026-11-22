#!/usr/bin/env python3
"""
upload_upstream_release.py — for ports whose official Mac build we make but
post on the upstream project's own GitHub release (e.g. CorsixTH), instead of
a MacSourcePorts/MSPBuildSystem release.

Uploads the DMG(s) to the release for --tag on --repo, replacing an asset of
the same name. The upstream maintainers create the release; this never
creates one, and never touches the site -- once upstream publishes the
release, check_thirdparty.py (with "ourBuild": true in thirdparty.json)
points the site at it.

By default it only uploads to a DRAFT release, the usual state while a
release is being put together. If the release is already published it
leaves it alone (a published release's files are what people have been
downloading) unless --allow-published is given. Seeing and uploading to a
draft needs push access to the repo, through `gh auth`.

Exit codes: 0 uploaded (or would have, with --dry-run); 3 nothing done
because there's no release for the tag yet, or it's published; 1 error.

    python3 upload_upstream_release.py --repo CorsixTH/CorsixTH \
        --tag v0.70.3 --dmg ../MSPBuildSystem/CorsixTH/release-.../CorsixTH-0.70.3.dmg
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

SKIPPED = 3


def find_release(repo: str, tag: str):
    """The release (draft or not) whose tag_name is tag, or None."""
    result = subprocess.run(
        ["gh", "api", "--paginate", f"repos/{repo}/releases",
         "--jq", f'.[] | select(.tag_name == "{tag}") | {{draft, name, assets: [.assets[].name]}}'],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        sys.exit(f"error: couldn't list releases of {repo}: {result.stderr.strip()}")
    found = [json.loads(line) for line in result.stdout.splitlines() if line.strip()]
    if len(found) > 1:
        sys.exit(f"error: {repo} has {len(found)} releases for {tag}; not guessing which")
    return found[0] if found else None


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--repo", required=True, help="upstream GitHub repo, owner/name")
    parser.add_argument("--tag", required=True, help="the release's tag, e.g. v0.70.3")
    parser.add_argument("--dmg", required=True, action="append", help="DMG to upload (repeatable)")
    parser.add_argument("--allow-published", action="store_true",
                        help="also replace files on an already-published release")
    parser.add_argument("--dry-run", action="store_true", help="say what would be uploaded, upload nothing")
    args = parser.parse_args()

    dmgs = [Path(d) for d in args.dmg]
    for d in dmgs:
        if not d.is_file():
            sys.exit(f"error: no such file: {d}")

    release = find_release(args.repo, args.tag)
    if release is None:
        print(f"No release for {args.tag} on {args.repo} yet (not even a draft); nothing uploaded.")
        return SKIPPED
    state = "draft" if release["draft"] else "published"
    print(f"Found {state} release '{release['name']}' for {args.tag} on {args.repo}; "
          f"it has: {', '.join(release['assets']) or 'no files'}")
    if not release["draft"] and not args.allow_published:
        print("It's already published, so its files are left alone (--allow-published to replace them).")
        return SKIPPED

    for d in dmgs:
        verb = "replace" if d.name in release["assets"] else "add"
        print(f"{'[dry-run] would ' if args.dry_run else ''}{verb} {d.name}")
    if args.dry_run:
        return 0

    subprocess.run(["gh", "release", "upload", args.tag, "--repo", args.repo, "--clobber",
                    *[str(d) for d in dmgs]], check=True)
    print(f"Uploaded to https://github.com/{args.repo}/releases (tag {args.tag}, {state})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
