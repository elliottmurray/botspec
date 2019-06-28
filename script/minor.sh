#!/bin/bash
set -e

bundle exec bump ${1:-minor} --no-commit

RELEASE_SCRIPT="$( dirname "${BASH_SOURCE[0]}" )"/release.sh
echo $RELEASE_SCRIPT

source $RELEASE_SCRIPT


