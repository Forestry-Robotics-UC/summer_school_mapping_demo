#!/usr/bin/env bash
set -euo pipefail

export SUMMER_SCHOOL_RUN_PRUNE=false
export SUMMER_SCHOOL_RUN_MAPPER=true
export SUMMER_SCHOOL_RUN_RVIZ=true
# UFOMAP occupancy + color voxel map backend.
export SUMMER_SCHOOL_MAPPER_BACKEND=ufomap
# The precomputed PRUNE bag publishes labeled clouds on this topic.
export SUMMER_SCHOOL_PRUNE_OUTPUT_TOPIC=/ouster/rgb_colored
# Replay is driven from a separate terminal so rosbag play can be paused.
export SUMMER_SCHOOL_RUN_RQT_RECONFIGURE=false
export SUMMER_SCHOOL_RVIZ_PROFILE=mapping

exec "$(dirname "$0")/run_demo.sh" "$@"
