#!/usr/bin/env bash
set -euo pipefail
REPO_NAME=${1:-synology-nut-tripplite-3028}; VISIBILITY=${VISIBILITY:-public}
command -v gh >/dev/null || { echo "GitHub CLI (gh) is required" >&2; exit 1; }; gh auth status
if ! git config user.name >/dev/null 2>&1 || [ -z "$(git config user.name 2>/dev/null || true)" ]; then git config --local user.name "$(gh api user --jq '.name // .login')"; fi
if ! git config user.email >/dev/null 2>&1 || [ -z "$(git config user.email 2>/dev/null || true)" ]; then GH_LOGIN=$(gh api user --jq .login); GH_ID=$(gh api user --jq .id); git config --local user.email "${GH_ID}+${GH_LOGIN}@users.noreply.github.com"; fi
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || git init -b main; git add .; if ! git diff --cached --quiet; then git commit -m "Initial Synology Tripp Lite 3028 compatibility package"; fi
if ! git remote get-url origin >/dev/null 2>&1; then gh repo create "$REPO_NAME" --"$VISIBILITY" --source=. --remote=origin --push --description "Fail-closed Synology DSM compatibility layer for Tripp Lite USB UPS 09ae:3028 using patched NUT usbhid-ups"; else git push -u origin HEAD; fi
gh repo edit --enable-issues --enable-wiki=false --add-topic synology --add-topic nut --add-topic ups --add-topic tripplite --add-topic dsm
gh label create hardware-validation --color 1D76DB --description "Independent hardware/DSM validation" 2>/dev/null || true; gh label create upstream --color 5319E7 --description "Work intended for upstream NUT" 2>/dev/null || true; gh label create safety --color B60205 --description "Power-loss / shutdown safety behavior" 2>/dev/null || true
create_issue(){ local title=$1 body=$2 labels=$3; if ! gh issue list --state all --search "in:title $title" --json title --jq '.[].title' | grep -Fxq "$title"; then gh issue create --title "$title" --body "$body" --label "$labels"; fi; }
create_issue "Submit Tripp Lite 0x3028 scaling support upstream to NUT" "Prepare a DCO-signed upstream PR using the included patch and upstream/pr-body.md. Link networkupstools/nut#2030 and include physical BR1500LCDT telemetry evidence." "upstream"
create_issue "Validate persistence across a full DS923+ reboot" "Perform one controlled full NAS reboot and document automatic recovery of the private driver and native DSM UPS stack." "hardware-validation,safety"
create_issue "Independent clean-install validation on DSM 7.4.1-90080" "Test the public installer from a clean supported DS923+ state: backup, install, healthcheck, rollback, reinstall, and OL->OB->OL." "hardware-validation,safety"
create_issue "Collect independent 09ae:3028 hardware reports" "Use the hardware template for other Tripp Lite models sharing product ID 3028. Do not broaden support without telemetry and a power-loss test." "hardware-validation"
printf '\nPublished: '; gh repo view --json url --jq .url
