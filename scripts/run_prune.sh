#!/usr/bin/env bash
set -euo pipefail

export SUMMER_SCHOOL_RUN_PRUNE=true
export SUMMER_SCHOOL_RUN_MAPPER=false
export SUMMER_SCHOOL_RUN_RVIZ=true
export SUMMER_SCHOOL_RUN_RQT_RECONFIGURE=true
export SUMMER_SCHOOL_RVIZ_PROFILE=prune

exec "$(dirname "$0")/run_demo.sh" "$@"
