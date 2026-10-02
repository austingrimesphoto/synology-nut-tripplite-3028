#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
./scripts/bootstrap-github.sh "${1:-synology-nut-tripplite-3028}"
VERSION=$(tr -d '[:space:]' < VERSION)
TAG="v$VERSION"
if ! git rev-parse "$TAG" >/dev/null 2>&1; then
    git tag -a "$TAG" -m "Release $TAG"
fi
if ! git ls-remote --exit-code --tags origin "refs/tags/$TAG" >/dev/null 2>&1; then
    git push origin "$TAG"
fi
printf 'Waiting for GitHub release workflow for %s...\n' "$TAG"
run_id=""
for _ in {1..30}; do
    run_id=$(gh run list --workflow release.yml --limit 20 --json databaseId,headBranch --jq ".[] | select(.headBranch == \"$TAG\") | .databaseId" | head -1)
    [ -n "$run_id" ] && break
    sleep 2
done
if [ -n "$run_id" ]; then
    gh run watch "$run_id" --exit-status
else
    echo "WARNING: release workflow did not appear yet; check GitHub Actions." >&2
fi
./scripts/prepare-upstream-pr.sh
printf '\nRepository: '; gh repo view --json url --jq .url
printf 'Release: '; gh release view "$TAG" --json url --jq .url 2>/dev/null || echo "pending"
