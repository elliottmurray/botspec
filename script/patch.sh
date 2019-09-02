#!/bin/bash
set -e

tag=`git name-rev --tags --name-only $(git rev-parse HEAD)`

if [ $tag == undefined ] 
then
  echo "Creating a commit for bumping purposes"
 
 
  RELEASE_SCRIPT="$( dirname "${BASH_SOURCE[0]}" )"/release.sh
  MODE="patch"
  source $RELEASE_SCRIPT
fi



