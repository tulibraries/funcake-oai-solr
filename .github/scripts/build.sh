#!/usr/bin/env bash
set -e
cd $GITHUB_WORKSPACE
zip -r ~/solrconfig.zip . -x ".git*" \
  Gemfile Gemfile.lock "spec/*" "vendor/*" \
  Makefile ".github/*" "bin/*" LICENSE "README*" \
  docker-compose.yml
