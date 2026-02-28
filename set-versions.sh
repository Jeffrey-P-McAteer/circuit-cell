#!/usr/bin/env bash
set -e

# --- Compute version from current date ---
YEAR=$(date +%Y)
MONTH=$(date +%-m)    # 1..12
#DAY_OF_YEAR=$(date +%j)  # 001..366
EPOCH_S=$(date +%s)
PATCH=$(( ($EPOCH_S % (60*60*24*365) ) / (60*60) ))

VERSION_MAJOR=$YEAR
VERSION_MINOR=$MONTH
VERSION_PATCH=$PATCH
VERSION_STR="${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}"

echo "Generated version: $VERSION_STR"

# --- Update release.yml environment ---
RELEASE_YML=".github/workflows/release.yml"
if [[ -f "$RELEASE_YML" ]]; then
    sed -i -E "s/(VERSION_MAJOR:).*/\1 $VERSION_MAJOR/" "$RELEASE_YML"
    sed -i -E "s/(VERSION_MINOR:).*/\1 $VERSION_MINOR/" "$RELEASE_YML"
    echo "Updated $RELEASE_YML"
fi

# --- Update CMakeLists.txt PROJECT_VERSION ---
CMAKELISTS="CMakeLists.txt"
if [[ -f "$CMAKELISTS" ]]; then
    # sed -i -E "s/(set\(PROJECT_VERSION_MAJOR ).*/\1$VERSION_MAJOR)/" "$CMAKELISTS"
    # sed -i -E "s/(set\(PROJECT_VERSION_MINOR ).*/\1$VERSION_MINOR)/" "$CMAKELISTS"
    # sed -i -E "s/(set\(PROJECT_VERSION_PATCH ).*/\1$VERSION_PATCH)/" "$CMAKELISTS"
    sed -i -E "s/project\(circuit-cell VERSION .* LANGUAGES CXX\)/project\(circuit-cell VERSION $VERSION_STR LANGUAGES CXX\))/" "$CMAKELISTS"
    echo "Updated $CMAKELISTS"
fi

# --- Optional: Update version.h.in template ---
# VERSION_H_IN="include/version.h.in"
# if [[ -f "$VERSION_H_IN" ]]; then
#     sed -i -E "s/(#define PROJECT_VERSION \").*(\")/\1$VERSION_STR\2/" "$VERSION_H_IN"
#     echo "Updated $VERSION_H_IN"
# fi

echo "Version synchronization complete: $VERSION_STR"

