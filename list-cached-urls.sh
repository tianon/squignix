#!/usr/bin/env bash
set -Eeuo pipefail

docker exec squignix grep -Erho '^KEY: .*' /var/cache/nginx | cut -d' ' -f2- | sort -u
