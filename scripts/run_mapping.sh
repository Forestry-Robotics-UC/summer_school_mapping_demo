#!/usr/bin/env bash
set -euo pipefail

export SUMMER_SCHOOL_RUN_PRUNE=false
export SUMMER_SCHOOL_RUN_MAPPER=true
export SUMMER_SCHOOL_RUN_RVIZ=true
# Make UFOMapping the first-class mapping backend for the demo path.
export SUMMER_SCHOOL_MAPPER_BACKEND=ufomap
# Replay is driven from a separate terminal so rosbag play can be paused.
export SUMMER_SCHOOL_RUN_REPLAY_RAW=false
export SUMMER_SCHOOL_RUN_REPLAY_PRUNE=false
export SUMMER_SCHOOL_RUN_REPLAY_SKY_MASK=false
export SUMMER_SCHOOL_RUN_REPLAY_LOCALIZATION=false
export SUMMER_SCHOOL_RUN_RQT_RECONFIGURE=false
export SUMMER_SCHOOL_REPLAY_MODE=mapping

exec "$(dirname "$0")/run_demo.sh" "$@"
