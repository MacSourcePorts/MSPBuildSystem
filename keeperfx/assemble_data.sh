#!/bin/bash
# Assembles KeeperFX's game data (everything but the original Dungeon Keeper
# files, which the player supplies) into $1, the way the KeeperFX launcher
# sets up an install on Windows: the latest complete release, the removals
# listed since, then the latest Alpha patch on top. The Alpha patches are
# built per commit by KeeperFX's CI, with the graphics and text files that
# take their own toolchain to make, and match the latest code we build.
#
# The downloads are cached in $2 (the complete release is ~375 MB).
#
# Usage: assemble_data.sh <destination> <cache dir>

set -e

DEST="$1"
CACHE="$2"
API="https://keeperfx.net/api/v1/release"

mkdir -p "$CACHE"
rm -rf "$DEST"
mkdir -p "$DEST"

# url of the latest release of a kind (stable or alpha)
latest_url() {
	curl -sSf "$API/$1/latest" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("release") or d.get("alpha_build"))["download_url"])'
}

fetch() {
	local url="$1" file="$CACHE/$(basename "$1")"
	if [ ! -s "$file" ]; then
		echo "Downloading $url" >&2
		curl -sSfL -o "$file.part" "$url"
		mv "$file.part" "$file"
	fi
	echo "$file"
}

COMPLETE=$(fetch "$(latest_url stable)")
ALPHA=$(fetch "$(latest_url alpha)")
echo "Complete release: $(basename "$COMPLETE")"
echo "Alpha patch:      $(basename "$ALPHA")"

# bsdtar reads 7z
tar -xf "$COMPLETE" -C "$DEST"

# The Alpha patch's list of files that later versions dropped: apply the
# sections newer than the newest one the complete release already knew about
ALPHA_LIST=$(mktemp)
tar -xOf "$ALPHA" launcher-auto-file-removal.txt > "$ALPHA_LIST"
python3 - "$DEST" "$ALPHA_LIST" <<'EOF'
import os, re, sys
dest, alpha_list = sys.argv[1], sys.argv[2]

def sections(path):
    out, cur = [], None
    for line in open(path, encoding="utf-8", errors="replace"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = re.fullmatch(r"\[([\d.]+)\]", line)
        if m:
            cur = (tuple(int(x) for x in m.group(1).split(".")), [])
            out.append(cur)
        elif cur:
            cur[1].append(line)
    return out

known = [v for v, _ in sections(os.path.join(dest, "launcher-auto-file-removal.txt"))]
newest_known = max(known) if known else (0,)
removed = 0
for version, files in sections(alpha_list):
    if version <= newest_known:
        continue
    for f in files:
        p = os.path.join(dest, f.lstrip("/"))
        if os.path.isfile(p):
            os.remove(p)
            removed += 1
print(f"Removed {removed} files dropped since {'.'.join(map(str, newest_known))}")
EOF
rm -f "$ALPHA_LIST"

tar -xf "$ALPHA" -C "$DEST"

# The patch ships its config as _keeperfx.cfg so it doesn't overwrite the
# player's; ours is only the default (it's copied for the player to edit)
if [ -f "$DEST/_keeperfx.cfg" ]; then
	mv -f "$DEST/_keeperfx.cfg" "$DEST/keeperfx.cfg"
fi

# Windows programs and the launcher's files
cd "$DEST"
find . -maxdepth 1 -type f \( -iname "*.exe" -o -iname "*.dll" -o -iname "*.map" \
	-o -iname "launch.sh" -o -iname "launchermn.jpg" -o -iname "launcher-auto-file-removal.txt" \) -delete
find . -name "placefiller.txt" -delete

echo "Game data assembled in $DEST ($(du -sh . | cut -f1))"
