#!/bin/bash
set -e

RELEASE_SCRIPT="$( dirname "${BASH_SOURCE[0]}" )"/release.sh
MODE="patch"

source $RELEASE_SCRIPT
