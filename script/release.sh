#!/bin/bash
set -e

echo "release botspec ${MODE}"

bundle exec bump ${MODE} --no-commit

#bundle exec appraisal update
bundle exec rake generate_changelog
git add lib/botspec/version.rb CHANGELOG.md
git commit -m "chore(release): version $(ruby -r ./lib/botspec/version.rb -e "puts Botspec::VERSION")"
git tag -f circleci_current
#git push
git push
git push origin : circleci_current



#bundle exec rake release

