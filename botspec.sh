#!/bin/sh

echo "bot name $1"
echo "fixtures in $2"

bundle exec thor cli:verify --botname=$1 --dialogs=$2

