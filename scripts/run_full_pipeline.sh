#!/usr/bin/env bash
set -euo pipefail

export SUMMER_SCHOOL_RUN_PRUNE=true
export SUMMER_SCHOOL_RUN_MAPPER=true
export SUMMER_SCHOOL_RUN_RVIZ=true
export SUMMER_SCHOOL_RUN_RQT_RECONFIGURE=true
export SUMMER_SCHOOL_REPLAY_MODE=full

exec "$(dirname "$0")/run_demo.sh" "$@"
