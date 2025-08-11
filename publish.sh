#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set +o xtrace # make sure we don't print out commands that may contain artifactory credentials

PACKAGE_NAME="splunk-wmbc-restricted-app"
WEBSTORE_URI="https://artefacts.tax.service.gov.uk/artifactory/webstore"
ARTEFACT_NAME="output/${PACKAGE_NAME}.tgz"

function publish() {
  VERSION=$1
  [[ -z $VERSION ]] && (
    echo "Version passed to the script is empty"
    exit 1
  )
  [[ ! -f ${ARTEFACT_NAME} ]] && (
    echo "${ARTEFACT_NAME} does not exist. run make/build to generate"
    exit 1
  )

  echo "Publishing $ARTEFACT_NAME"

  SHA1_CHECKSUM="$(shasum -a 1 "$ARTEFACT_NAME" | awk '{ print $1 }')"
  SHA256_CHECKSUM="$(shasum -a 256 "$ARTEFACT_NAME" | awk '{ print $1 }')"

  curl --fail --show-error -X PUT \
    --header "X-Checksum-Sha1:${SHA1_CHECKSUM}" \
    --header "X-Checksum-Sha256:${SHA256_CHECKSUM}" \
    -T "$ARTEFACT_NAME" \
    -u "$ARTIFACTORY_USERNAME:$ARTIFACTORY_PASSWORD" \
    "${WEBSTORE_URI}/splunk-apps/${PACKAGE_NAME}/${PACKAGE_NAME}-${VERSION}.tgz"
}

function unpublish() {
  VERSION=$1

  [[ -z $VERSION ]] && (
    echo "Version passed to the script is empty"
    exit 1
  )

  echo "Unpublishing $PACKAGE_NAME v$VERSION"
  curl --fail --show-error -X DELETE -u "$ARTIFACTORY_USERNAME:$ARTIFACTORY_PASSWORD" "${WEBSTORE_URI}/splunk-apps/${PACKAGE_NAME}/${PACKAGE_NAME}-${VERSION}.tgz"
}

"$@"