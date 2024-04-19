#!/usr/bin/env bash
set -e

rm -f /app/tmp/pids/server.pid
yarn install
bundle install
bundle exec rails db:create
bundle exec rails db:migrate

exec "$@"
