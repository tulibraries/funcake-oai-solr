#!/usr/bin/env bash
set -e
cd ~/project
zip -r ~/solrconfig.zip . -x ".git*" \
  Gemfile Gemfile.lock "spec/*" "vendor/*" \
  Makefile ".circle*" "bin/*" LICENSE "README*" \
  docker-compose.yml
