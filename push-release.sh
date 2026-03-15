#!/usr/bin/env bash
set -euo pipefail

trap 'echo "Error occurred. Returning to master branch."; git checkout master' ERR

git status

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
# Ensure script is run from master branch
# -----------------------------
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

if [ "$CURRENT_BRANCH" != "master" ]; then
    echo "ERROR: You must run this script from the 'master' branch. Current branch: $CURRENT_BRANCH"
    exit 1
fi


./set-versions.sh

git status

# -----------------------------
# Check if repo is clean - if not, the ONLY place the change could have occured from is ./set-versions.sh - auto-commit
# -----------------------------
if ! git diff-index --quiet HEAD -- || !git diff-index --quiet --cached HEAD --; then
    git add -A .
    git commit -m "Version Bump"
fi


# -----------------------------
# Fetch latest updates (unlikely to be necessary)
# -----------------------------
# git fetch origin

# if ! git show-ref --quiet refs/heads/master; then
#     git checkout -b master origin/master
# else
#     git checkout master
#     git pull origin master
# fi

# if ! git show-ref --quiet refs/heads/release; then
#     git checkout -b release origin/release || git checkout -b release
# else
#     git checkout release
#     git pull origin release || true
# fi

git checkout master

echo "Directly assigning release to master's commit..."
git branch -f release master

git checkout release

source build/version_data.sh

TAG_NAME="v$VERSION_STR"
# Forcefully create/update tag at current HEAD
git tag -f -a "$TAG_NAME" -m "Release version $VERSION_STR"
echo "Git tag $TAG_NAME created/updated at current commit."

# Optional: push tag to origin
#git push --force-with-lease origin release
git push --force origin refs/heads/release:refs/heads/release
git push -f origin "$TAG_NAME"

# Go back to where we began
git checkout master
