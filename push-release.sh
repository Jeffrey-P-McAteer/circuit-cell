#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Check if repo is clean
# -----------------------------
if ! git diff-index --quiet HEAD --; then
    echo "ERROR: Your repository has uncommitted changes. Please commit or stash them first."
    exit 1
fi

if ! git diff-index --quiet --cached HEAD --; then
    echo "ERROR: You have staged but uncommitted changes. Please commit or stash them first."
    exit 1
fi

# -----------------------------
# Fetch latest updates
# -----------------------------
# git fetch origin

if ! git show-ref --quiet refs/heads/master; then
    git checkout -b master origin/master
else
    git checkout master
    git pull origin master
fi

if ! git show-ref --quiet refs/heads/release; then
    git checkout -b release origin/release || git checkout -b release
else
    git checkout release
    git pull origin release || true
fi

echo "Merging master into release..."
git merge --no-ff master -m "Merge master into release"

git push origin release

git checkout master
