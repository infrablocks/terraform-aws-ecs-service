#!/usr/bin/env bash

[ -n "$DEBUG" ] && set -x
set -e
set -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/../../.." && pwd )"

cd "$PROJECT_DIR"

set +e
openssl version
openssl aes-256-cbc \
    -d \
    -md sha1 \
    -in ./.circleci/gpg.private.enc \
    -k "${ENCRYPTION_PASSPHRASE}" | gpg --import -
set -e

git crypt unlock

source config/secrets/ci/aws-credentials.sh

./go test:unit
./go test:integration
