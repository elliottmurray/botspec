#!/bin/bash

mkdir /home/circleci/.gem
echo -e "---\r\n:rubygems_api_key: $RUBYGEMS_API_KEY" > /home/circleci/.gem/credentials
chmod 0600 /home/circleci/.gem/credentials
