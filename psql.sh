#!/usr/bin/env bash

podman compose exec db psql --dbname postgres://postgres:password@db:5432
