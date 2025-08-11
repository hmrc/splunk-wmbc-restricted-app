#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

function tag() {
  RELEASE_VERSION=$1
  [[ -z $RELEASE_VERSION ]] && (echo "Version passed to the script is empty"; exit 1)
  [[ $1 =~ ^v.*-SNAPSHOT$ ]] && (echo "Don't tag SNAPSHOT releases!"; exit 1)

  TAG="v$RELEASE_VERSION"
  [[ $(git tag -l "$TAG") ]] && (echo "Tag $TAG already exists!"; exit 1)

  echo "Tagging release as $TAG"
	git tag -a "$TAG" -m "Released version $RELEASE_VERSION"
	git push origin "$TAG"
}

function untag() {
  RELEASE_VERSION=$1
  TAG="$RELEASE_VERSION"

	echo "Untagging release $RELEASE_VERSION"
	if [ $(git tag -l "$TAG") ]
	then
		git tag -d "$TAG"
		git push origin ":$TAG"
	else
		echo "No tag created not removing"
	fi
}

"$@"
