#!/usr/bin/env bash

set -e

# watch sql files in the src directory and run squirrel to generate gleam code
watchexec -r -e sql src -- gleam run -m squirrel </dev/null &

# watch gleam files in the src directory and run gleam compile/start server
watchexec -r -e gleam -- gleam run </dev/null &

# watch js files in the src directory and run esbuild to generate bundle
pnpm dev &

wait
