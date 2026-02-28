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

# -----------------------------
# Rebase release onto master
# -----------------------------
echo "Rebasing release onto master..."
git rebase master

# Optional: automatically abort if conflicts
if [ $? -ne 0 ]; then
    echo "Rebase failed due to conflicts. Resolve manually."
    exit 1
fi

git push origin release

git checkout master
