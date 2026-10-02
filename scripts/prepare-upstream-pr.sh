#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WORK=${WORK:-"$ROOT/.upstream-nut"}
BRANCH=${BRANCH:-tripplite-3028-scale}
command -v gh >/dev/null || { echo "GitHub CLI required" >&2; exit 1; }
command -v git >/dev/null || { echo "git required" >&2; exit 1; }
gh auth status
user=$(gh api user --jq .login)
gh repo fork networkupstools/nut --clone=false || true
rm -rf "$WORK"
gh repo clone "$user/nut" "$WORK"
cd "$WORK"
git remote get-url upstream >/dev/null 2>&1 || git remote add upstream https://github.com/networkupstools/nut.git
git fetch upstream master
if git show upstream/master:drivers/tripplite-hid.c | grep -q '0x3028), smart1500lcdt_scale'; then
    echo "Upstream master already contains the 3028 scaling entry; no PR is needed."
    exit 0
fi
git checkout -B "$BRANCH" upstream/master
python3 - <<'PYUP'
from pathlib import Path
p=Path('drivers/tripplite-hid.c')
s=p.read_text()
needle='\t{ USB_DEVICE(TRIPPLITE_VENDORID, 0x3024), smart1500lcdt_scale },\n'
add='\t/* Tripp Lite BR1500LCDT; validated with USB product ID 3028 */\n\t{ USB_DEVICE(TRIPPLITE_VENDORID, 0x3028), smart1500lcdt_scale },\n'
if '0x3028), smart1500lcdt_scale' in s:
    raise SystemExit('3028 scaling entry already exists; no PR needed')
if needle not in s:
    raise SystemExit('Expected 3024 anchor not found; inspect current upstream manually')
p.write_text(s.replace(needle, needle+add, 1))
PYUP
git add drivers/tripplite-hid.c
git commit -s -m "tripplite-hid: scale USB product 3028 like SMART1500LCDT"
git push --force-with-lease -u origin "$BRANCH"
existing=$(gh pr list --repo networkupstools/nut --state open --head "$user:$BRANCH" --json url --jq '.[0].url // empty')
if [ -n "$existing" ]; then
    echo "Upstream PR already open: $existing"
    exit 0
fi
pr_url=$(gh pr create \
    --repo networkupstools/nut \
    --base master \
    --head "$user:$BRANCH" \
    --title 'tripplite-hid: support scaling for USB product 3028' \
    --body-file "$ROOT/upstream/pr-body.md")
echo "Upstream PR opened: $pr_url"
