#!/bin/bash
set -e

bundle exec bump ${1:-patch} --no-commit
#bundle exec appraisal update
bundle exec rake generate_changelog
git add lib/botspec/version.rb CHANGELOG.md 
git commit -m "chore(release): version $(ruby -r ./lib/botspec/version.rb -e "puts Botspec::VERSION")" && git push
bundle exec rake release

