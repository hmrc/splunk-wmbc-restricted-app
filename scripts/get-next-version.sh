#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

IS_RELEASE=${IS_RELEASE:-false}

function find_latest_version() {
  git tag --list | grep -E "^v.+$" | sort --version-sort --reverse | head -n 1 | sed -r "s/(.+)/\1/"
}

function bump_version() {
  local CURRENT_VERSION=$1
  local RELEASE_VERSIONING_VERSION=0.17.0
  local ARTIFACTORY_URI=https://artefacts.tax.service.gov.uk/artifactory
  local ARTIFACT_PATH="hmrc-public-releases-local/uk/gov/hmrc/release-versioning_2.12/$RELEASE_VERSIONING_VERSION"
  local ARTIFACT_NAME="release-versioning_2.12-$RELEASE_VERSIONING_VERSION-assembly.jar"
  local ARTIFACT_FULL_URI="$ARTIFACTORY_URI/$ARTIFACT_PATH/$ARTIFACT_NAME"
  local ARTIFACT_LOCAL_PATH="/tmp/$ARTIFACT_NAME"

  if ! [ -f "$ARTIFACT_LOCAL_PATH" ]; then
    echo "Downloading release-versioning from $ARTIFACT_FULL_URI" >&2
    curl -L -q -o "$ARTIFACT_LOCAL_PATH" $ARTIFACT_FULL_URI
  fi

  RELEASE_FLAG=$(if $IS_RELEASE; then echo "--release"; fi)

  java -jar "$ARTIFACT_LOCAL_PATH" --git-describe "$CURRENT_VERSION" --major-version 1 $RELEASE_FLAG
}

function is_valid_tag() {
  [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+(-SNAPSHOT)?$ ]]
}

function get_new_version() {
  LATEST_VERSION=$(find_latest_version)

  bump_version "${LATEST_VERSION:-v0.0.0}"
}

NEXT_VERSION=$(get_new_version)

if ! is_valid_tag "$NEXT_VERSION"; then
  echo "------------------------------------------------------------------------------"
  echo "ERROR - Tag $NEXT_VERSION is invalid."
  echo "Expected format is: vX.Y.Z with optional '-SNAPSHOT' at the end."
  echo "------------------------------------------------------------------------------"
  exit 1
fi

echo "$NEXT_VERSION" > .version
