#!/bin/bash
set -e

bundle exec bump ${1:-patch} --no-commit

RELEASE_SCRIPT="$( dirname "${BASH_SOURCE[0]}" )"/release.sh
MODE="patch"

source $RELEASE_SCRIPT
