#!/usr/bin/env bash
set -euo pipefail

# Interactive bag replay, meant to run in its own terminal so rosbag play owns
# the TTY (SPACE = pause/resume, 's' = step, Ctrl-C = stop). It talks to the
# stack started in the other terminal via the shared host-network roscore.
#
# Usage: replay_bag.sh [full|prune|mapping] [extra rosbag play args...]
#   full   : raw chunks + sky-mask + localization (live PRUNE processing)
#   prune  : raw chunks + sky-mask
#   mapping: raw chunks + precomputed PRUNE rgb_colored bag + localization

MODE="${1:-full}"

RAW_PATTERN="${SUMMER_SCHOOL_RAW_BAG_PATTERN:-raw/pinhal_demo_ros1_chunk_*.bag}"
PRUNE_BAG="${SUMMER_SCHOOL_PRUNE_BAG:-semantic_pcl/pinhal_demo_segmented_pcl.bag}"
SKY_MASK_BAG="${SUMMER_SCHOOL_SKY_MASK_BAG:-raw/pinhal_demo_sky_mask_480p.bag}"
LOCALIZATION_BAG="${SUMMER_SCHOOL_LOCALIZATION_BAG:-pinhal_demo_localisation_tf_50hz.bag}"
BAG_RATE="${SUMMER_SCHOOL_BAG_RATE:-1.0}"
BAGS_DIR=/workspace/demo/bags

source /opt/ros/noetic/setup.bash
if [[ -f /workspace/catkin_ws/devel/setup.bash ]]; then
  source /workspace/catkin_ws/devel/setup.bash
fi

BAGS=()
add_match() {
  local pattern="$1"
  shopt -s nullglob
  local matches=("${BAGS_DIR}"/${pattern})
  shopt -u nullglob
  if (( ${#matches[@]} == 0 )); then
    echo "[replay_bag] WARN: no bags matched ${pattern}" >&2
    return 0
  fi
  BAGS+=("${matches[@]}")
}

add_match "${RAW_PATTERN}"
case "${MODE}" in
  full)
    add_match "${SKY_MASK_BAG}"
    add_match "${LOCALIZATION_BAG}"
    ;;
  prune)
    add_match "${SKY_MASK_BAG}"
    ;;
  mapping)    add_match "${PRUNE_BAG}"
  add_match "${LOCALIZATION_BAG}"
 ;;
  *) echo "[replay_bag] unknown mode '${MODE}' (use full|prune|mapping)" >&2; exit 1 ;;
esac

(( ${#BAGS[@]} > 0 )) || { echo "[replay_bag] ERROR: no bags to play" >&2; exit 1; }

echo "[replay_bag] mode: ${MODE}"
echo "[replay_bag] bags: ${BAGS[*]}"
echo "[replay_bag] rate: ${BAG_RATE}"
exec rosbag play "${BAGS[@]}" --clock -r "${BAG_RATE}" "${@:2}"
