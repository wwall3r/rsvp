#!/usr/bin/env bash

set -e

watchexec -r -e gleam -- gleam run </dev/null &
pnpm dev &
wait
