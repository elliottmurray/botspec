#!/bin/bash
set -e

RELEASE_SCRIPT="$( dirname "${BASH_SOURCE[0]}" )"/release.sh
MODE="minor"

source $RELEASE_SCRIPT
