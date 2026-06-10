#!/usr/bin/env bash
set -euo pipefail

PRUNE_CONFIG="/workspace/demo/config/prune_demo.yaml"
MAPPER_CONFIG="/workspace/demo/config/mapper_demo.yaml"
RVIZ_CONFIG="/workspace/demo/config/rviz_demo.rviz"
STATIC_TFS_FILE="${STATIC_TFS_FILE:-/workspace/demo/calibration/example_static_tfs.yaml}"
CURTMINI_URDF="${SUMMER_SCHOOL_CURTMINI_URDF:-${CURTMINI_URDF:-/workspace/catkin_ws/src/entfac_mapping/entfac_mapping_ros/urdf/curtmini/robot.urdf.xacro}}"
RUN_CURTMINI_URDF="${SUMMER_SCHOOL_RUN_CURTMINI_URDF:-${RUN_CURTMINI_URDF:-true}}"
RUN_STATIC_TFS="${SUMMER_SCHOOL_RUN_STATIC_TFS:-${RUN_STATIC_TFS:-true}}"

PRUNE_SEMANTIC_TOPIC="${SUMMER_SCHOOL_PRUNE_SEMANTIC_TOPIC:-${PRUNE_SEMANTIC_TOPIC:-/semantic/mask}}"
PRUNE_SEMANTIC_INPUT_TYPE="${SUMMER_SCHOOL_PRUNE_SEMANTIC_INPUT_TYPE:-${PRUNE_SEMANTIC_INPUT_TYPE:-labels}}"
PRUNE_CAMERA_INFO_TXT="${SUMMER_SCHOOL_PRUNE_CAMERA_INFO_TXT:-${PRUNE_CAMERA_INFO_TXT:-/workspace/demo/calibration/curt_mini_realsense_camera_info_480p.txt}}"
PRUNE_CAMERA_INFO_TOPIC="${SUMMER_SCHOOL_PRUNE_CAMERA_INFO_TOPIC:-${PRUNE_CAMERA_INFO_TOPIC:-}}"
PRUNE_DEPTH_INPUT_TOPIC="${SUMMER_SCHOOL_PRUNE_DEPTH_INPUT_TOPIC:-${PRUNE_DEPTH_INPUT_TOPIC:-/ouster/points}}"
PRUNE_OUTPUT_TOPIC="${SUMMER_SCHOOL_PRUNE_OUTPUT_TOPIC:-${PRUNE_OUTPUT_TOPIC:-/colored_pcl_node/semantic_pointcloud}}"
PRUNE_TARGET_FRAME="${SUMMER_SCHOOL_PRUNE_TARGET_FRAME:-${PRUNE_TARGET_FRAME:-base_link}}"
PRUNE_PROJECTION_INVALID_MASK_TOPIC="${SUMMER_SCHOOL_PRUNE_PROJECTION_INVALID_MASK_TOPIC:-${PRUNE_PROJECTION_INVALID_MASK_TOPIC:-/semantic/mask}}"
PRUNE_PROJECTION_INVALID_MASK_VALUE="${SUMMER_SCHOOL_PRUNE_PROJECTION_INVALID_MASK_VALUE:-${PRUNE_PROJECTION_INVALID_MASK_VALUE:-255}}"
PRUNE_PROJECTION_INVALID_MASK_DILATE_PX="${SUMMER_SCHOOL_PRUNE_PROJECTION_INVALID_MASK_DILATE_PX:-${PRUNE_PROJECTION_INVALID_MASK_DILATE_PX:-1}}"
PRUNE_USE_INVALID_MASK="${SUMMER_SCHOOL_PRUNE_USE_INVALID_MASK:-${PRUNE_USE_INVALID_MASK:-true}}"
PRUNE_USE_DEPTH_EDGE_REJECTION="${SUMMER_SCHOOL_PRUNE_USE_DEPTH_EDGE_REJECTION:-${PRUNE_USE_DEPTH_EDGE_REJECTION:-true}}"
PRUNE_USE_OCCLUSION_GATE="${SUMMER_SCHOOL_PRUNE_USE_OCCLUSION_GATE:-${PRUNE_USE_OCCLUSION_GATE:-true}}"
PRUNE_PROJECTION_PATCH_SIZE="${SUMMER_SCHOOL_PRUNE_PROJECTION_PATCH_SIZE:-${PRUNE_PROJECTION_PATCH_SIZE:-3}}"
PRUNE_PROJECTION_CONFIDENCE_MIN="${SUMMER_SCHOOL_PRUNE_PROJECTION_CONFIDENCE_MIN:-${PRUNE_PROJECTION_CONFIDENCE_MIN:-0.0}}"
PRUNE_PROJECTION_REJECT_DEPTH_EDGES="${SUMMER_SCHOOL_PRUNE_PROJECTION_REJECT_DEPTH_EDGES:-${PRUNE_PROJECTION_REJECT_DEPTH_EDGES:-true}}"
PRUNE_PROJECTION_OCCLUSION_EPSILON_M="${SUMMER_SCHOOL_PRUNE_PROJECTION_OCCLUSION_EPSILON_M:-${PRUNE_PROJECTION_OCCLUSION_EPSILON_M:-0.20}}"
PRUNE_PROJECTION_OCCLUSION_RADIUS_PX="${SUMMER_SCHOOL_PRUNE_PROJECTION_OCCLUSION_RADIUS_PX:-${PRUNE_PROJECTION_OCCLUSION_RADIUS_PX:-1}}"
PRUNE_DEBUG_PROJECT_LIDAR="${SUMMER_SCHOOL_PRUNE_DEBUG_PROJECT_LIDAR:-${PRUNE_DEBUG_PROJECT_LIDAR:-false}}"
PRUNE_DEBUG_PROJECT_LIDAR_STRIDE="${SUMMER_SCHOOL_PRUNE_DEBUG_PROJECT_LIDAR_STRIDE:-${PRUNE_DEBUG_PROJECT_LIDAR_STRIDE:-1}}"
PRUNE_DEBUG_PROJECT_LIDAR_RADIUS="${SUMMER_SCHOOL_PRUNE_DEBUG_PROJECT_LIDAR_RADIUS:-${PRUNE_DEBUG_PROJECT_LIDAR_RADIUS:-2}}"
PRUNE_DEBUG_PROJECT_LIDAR_OUTLINE_ONLY="${SUMMER_SCHOOL_PRUNE_DEBUG_PROJECT_LIDAR_OUTLINE_ONLY:-${PRUNE_DEBUG_PROJECT_LIDAR_OUTLINE_ONLY:-false}}"
PRUNE_OVERLAY_OUTPUT_DIR="${SUMMER_SCHOOL_PRUNE_OVERLAY_OUTPUT_DIR:-${PRUNE_OVERLAY_OUTPUT_DIR:-/workspace/demo/logs/overlays}}"
PRUNE_OVERLAY_OUTPUT_STRIDE="${SUMMER_SCHOOL_PRUNE_OVERLAY_OUTPUT_STRIDE:-${PRUNE_OVERLAY_OUTPUT_STRIDE:-1}}"
PRUNE_OVERLAY_DOT_RADIUS="${SUMMER_SCHOOL_PRUNE_OVERLAY_DOT_RADIUS:-${PRUNE_OVERLAY_DOT_RADIUS:-2}}"

MAPPER_BACKEND="${SUMMER_SCHOOL_MAPPER_BACKEND:-${MAPPER_BACKEND:-dummy}}"
MAPPER_SITE="${SUMMER_SCHOOL_MAPPER_SITE:-${MAPPER_SITE:-forest}}"
MAPPER_WORLD_FRAME="${SUMMER_SCHOOL_MAPPER_WORLD_FRAME:-${MAPPER_WORLD_FRAME:-map}}"
RUN_MAPPER="${SUMMER_SCHOOL_RUN_MAPPER:-${RUN_MAPPER:-true}}"
RUN_RVIZ="${SUMMER_SCHOOL_RUN_RVIZ:-${RUN_RVIZ:-true}}"
ENABLE_PRUNE_GATES="${SUMMER_SCHOOL_ENABLE_PRUNE_GATES:-${ENABLE_PRUNE_GATES:-true}}"
RUN_PRUNE="${SUMMER_SCHOOL_RUN_PRUNE:-${RUN_PRUNE:-true}}"
RUN_RQT_RECONFIGURE="${SUMMER_SCHOOL_RUN_RQT_RECONFIGURE:-${RUN_RQT_RECONFIGURE:-false}}"
RUN_REPLAY_RAW="${SUMMER_SCHOOL_RUN_REPLAY_RAW:-${RUN_REPLAY_RAW:-false}}"
RUN_REPLAY_PRUNE="${SUMMER_SCHOOL_RUN_REPLAY_PRUNE:-${RUN_REPLAY_PRUNE:-false}}"
RUN_REPLAY_SKY_MASK="${SUMMER_SCHOOL_RUN_REPLAY_SKY_MASK:-${RUN_REPLAY_SKY_MASK:-false}}"
RUN_REPLAY_LOCALIZATION="${SUMMER_SCHOOL_RUN_REPLAY_LOCALIZATION:-${RUN_REPLAY_LOCALIZATION:-false}}"
SUMMER_SCHOOL_RAW_BAG_PATTERN="${SUMMER_SCHOOL_RAW_BAG_PATTERN:-${SUMMER_SCHOOL_RAW_BAG:-raw/2026_03_25_15_24_28__event-near_points__0_ros1_chunk_*_notf.bag}}"
SUMMER_SCHOOL_PRUNE_BAG="${SUMMER_SCHOOL_PRUNE_BAG:-semantic_pcl/prune_colored_rgb_no_gates_480p.bag}"
SUMMER_SCHOOL_SKY_MASK_BAG="${SUMMER_SCHOOL_SKY_MASK_BAG:-segmented/2026_03_25_15_24_28__event-near_points__0_ros1_chunk_*_segmented.bag}"
SUMMER_SCHOOL_LOCALIZATION_BAG="${SUMMER_SCHOOL_LOCALIZATION_BAG:-localisation_tf_50hz.bag}"
SUMMER_SCHOOL_BAG_RATE="${SUMMER_SCHOOL_BAG_RATE:-${BAG_RATE:-1.0}}"

PIDS=()

cleanup() {
  echo
  echo "[run_demo] stopping demo processes"
  for pid in "${PIDS[@]}"; do
    kill "${pid}" >/dev/null 2>&1 || true
  done
  wait || true
}
trap cleanup EXIT INT TERM

source /opt/ros/noetic/setup.bash
if [[ -f /workspace/catkin_ws/devel/setup.bash ]]; then
  source /workspace/catkin_ws/devel/setup.bash
fi

start_background() {
  echo "[run_demo] starting: $*"
  "$@" &
  PIDS+=("$!")
  sleep 1
}

append_matches() {
  local pattern="$1"
  shopt -s nullglob
  local matches=(/workspace/demo/bags/${pattern})
  shopt -u nullglob
  if (( ${#matches[@]} == 0 )); then
    echo "[run_demo] WARN: no bags matched pattern ${pattern}"
    return 1
  fi
  REPLAY_BAGS+=("${matches[@]}")
}

if ! rostopic list >/dev/null 2>&1; then
  start_background roscore
  sleep 2
else
  echo "[run_demo] roscore already running"
fi

rosparam set /use_sim_time true >/dev/null

if [[ "${RUN_CURTMINI_URDF}" == "true" ]]; then
  if [[ -f "${CURTMINI_URDF}" ]]; then
    echo "[run_demo] publishing CurtMini URDF: ${CURTMINI_URDF}"
    python3 - "${CURTMINI_URDF}" <<'PY'
import sys
import subprocess

import rospy

urdf_path = sys.argv[1]
rospy.init_node("summer_school_robot_description_loader", anonymous=True, disable_signals=True)
robot_description = subprocess.check_output(["xacro", urdf_path], text=True)
rospy.set_param("/robot_description", robot_description)
PY
    start_background rosrun robot_state_publisher robot_state_publisher
  else
    echo "[run_demo] WARN: CurtMini URDF not found: ${CURTMINI_URDF}"
  fi
fi

if [[ "${RUN_STATIC_TFS}" == "true" ]]; then
  echo "[run_demo] loading static TFs from ${STATIC_TFS_FILE}"
  python3 - "${STATIC_TFS_FILE}" <<'PY' >/tmp/demo_static_tf_commands.sh
import shlex
import sys
from pathlib import Path

import yaml

path = Path(sys.argv[1])
data = yaml.safe_load(path.read_text()) or {}
for item in data.get("transforms", []):
    parent = item["parent"]
    child = item["child"]
    xyz = item.get("xyz", [0, 0, 0])
    xyzw = item.get("xyzw", [0, 0, 0, 1])
    args = [*map(str, xyz), *map(str, xyzw), parent, child]
    print("rosrun tf2_ros static_transform_publisher " + " ".join(shlex.quote(arg) for arg in args))
PY

  while IFS= read -r command_line; do
    [[ -n "${command_line}" ]] || continue
    echo "[run_demo] starting static TF: ${command_line}"
    bash -lc "${command_line}" &
    PIDS+=("$!")
  done </tmp/demo_static_tf_commands.sh
fi

if [[ "${RUN_PRUNE}" == "true" ]]; then
  echo "[run_demo] starting PRUNE"
  python3 - "${PRUNE_CONFIG}" "/tmp/prune_demo_runtime.yaml" "${ENABLE_PRUNE_GATES}" <<'PY'
import os
import sys
from pathlib import Path

import yaml

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
enable_gates = sys.argv[3].lower() == "true"
data = yaml.safe_load(src.read_text()) or {}
overrides = {
    "semantic_topic": os.environ.get("PRUNE_SEMANTIC_TOPIC"),
    "semantic_input_type": os.environ.get("PRUNE_SEMANTIC_INPUT_TYPE"),
    "camera_info_txt": os.environ.get("PRUNE_CAMERA_INFO_TXT"),
    "camera_info": os.environ.get("PRUNE_CAMERA_INFO_TOPIC"),
    "depth_input_topic": os.environ.get("PRUNE_DEPTH_INPUT_TOPIC"),
    "target_frame": os.environ.get("PRUNE_TARGET_FRAME"),
    "debug_project_lidar": os.environ.get("PRUNE_DEBUG_PROJECT_LIDAR"),
    "debug_project_lidar_stride": os.environ.get("PRUNE_DEBUG_PROJECT_LIDAR_STRIDE"),
    "debug_project_lidar_radius": os.environ.get("PRUNE_DEBUG_PROJECT_LIDAR_RADIUS"),
    "debug_project_lidar_outline_only": os.environ.get("PRUNE_DEBUG_PROJECT_LIDAR_OUTLINE_ONLY"),
    "overlay_output_dir": os.environ.get("PRUNE_OVERLAY_OUTPUT_DIR"),
    "overlay_output_stride": os.environ.get("PRUNE_OVERLAY_OUTPUT_STRIDE"),
    "overlay_dot_radius": os.environ.get("PRUNE_OVERLAY_DOT_RADIUS"),
}
if enable_gates:
    overrides.update(
        {
            "projection_invalid_mask_topic": os.environ.get("PRUNE_PROJECTION_INVALID_MASK_TOPIC"),
            "projection_invalid_mask_value": os.environ.get("PRUNE_PROJECTION_INVALID_MASK_VALUE"),
            "projection_invalid_mask_dilate_px": os.environ.get("PRUNE_PROJECTION_INVALID_MASK_DILATE_PX"),
            "use_invalid_mask": os.environ.get("PRUNE_USE_INVALID_MASK"),
            "use_depth_edge_rejection": os.environ.get("PRUNE_USE_DEPTH_EDGE_REJECTION"),
            "use_occlusion_gate": os.environ.get("PRUNE_USE_OCCLUSION_GATE"),
            "projection_patch_size": os.environ.get("PRUNE_PROJECTION_PATCH_SIZE"),
            "projection_confidence_min": os.environ.get("PRUNE_PROJECTION_CONFIDENCE_MIN"),
            "projection_reject_depth_edges": os.environ.get("PRUNE_PROJECTION_REJECT_DEPTH_EDGES"),
            "projection_occlusion_epsilon_m": os.environ.get("PRUNE_PROJECTION_OCCLUSION_EPSILON_M"),
            "projection_occlusion_radius_px": os.environ.get("PRUNE_PROJECTION_OCCLUSION_RADIUS_PX"),
        }
    )
for key, value in overrides.items():
    if value:
        data[key] = yaml.safe_load(value)
dst.write_text(yaml.safe_dump(data, sort_keys=False))
PY
  if [[ "${ENABLE_PRUNE_GATES}" == "true" ]]; then
    echo "[run_demo] PRUNE gates: enabled"
  else
    echo "[run_demo] PRUNE gates: disabled"
  fi
  start_background roslaunch prune_ros prune.launch \
    use_sim_time:=true \
    dataset_config:=/tmp/prune_demo_runtime.yaml \
    semantic_topic:="${PRUNE_SEMANTIC_TOPIC}" \
    semantic_input_type:="${PRUNE_SEMANTIC_INPUT_TYPE}" \
    depth_input_topic:="${PRUNE_DEPTH_INPUT_TOPIC}" \
    output_topic:="${PRUNE_OUTPUT_TOPIC}" \
    target_frame:="${PRUNE_TARGET_FRAME}" \
    rviz:=false
else
  echo "[run_demo] PRUNE stage disabled; expecting pre-colored /colored_pcl_node/semantic_pointcloud from the replay bag"
fi

if [[ "${RUN_MAPPER}" == "true" ]]; then
  if rospack find entfac_mapping_ros >/dev/null 2>&1; then
    echo "[run_demo] starting mapper with backend=${MAPPER_BACKEND}; reference config=${MAPPER_CONFIG}"
    start_background roslaunch entfac_mapping_ros semantic_mapping.launch \
      backend:="${MAPPER_BACKEND}" \
      site:="${MAPPER_SITE}" \
      pointcloud_topic:="${PRUNE_OUTPUT_TOPIC}" \
      world_frame:="${MAPPER_WORLD_FRAME}"
  else
    echo "[run_demo] WARN: entfac_mapping_ros not found; mapper/UFOMapping stage skipped"
  fi
fi

if [[ "${RUN_RQT_RECONFIGURE}" == "true" ]]; then
  echo "[run_demo] starting rqt_reconfigure"
  start_background rosrun rqt_reconfigure rqt_reconfigure
fi

if [[ "${RUN_RVIZ}" == "true" ]]; then
  echo "[run_demo] starting RViz"
  start_background rviz -d "${RVIZ_CONFIG}"
fi

REPLAY_BAGS=()
if [[ "${RUN_REPLAY_RAW}" == "true" ]]; then
  append_matches "${SUMMER_SCHOOL_RAW_BAG_PATTERN}" || true
fi
if [[ "${RUN_REPLAY_PRUNE}" == "true" ]]; then
  append_matches "${SUMMER_SCHOOL_PRUNE_BAG}" || true
fi
if [[ "${RUN_REPLAY_SKY_MASK}" == "true" ]]; then
  append_matches "${SUMMER_SCHOOL_SKY_MASK_BAG}" || true
fi
if [[ "${RUN_REPLAY_LOCALIZATION}" == "true" ]]; then
  append_matches "${SUMMER_SCHOOL_LOCALIZATION_BAG}" || true
fi

if (( ${#REPLAY_BAGS[@]} > 0 )); then
  echo "[run_demo] replay bags: ${REPLAY_BAGS[*]}"
  echo "[run_demo] rosbag play is interactive: SPACE = pause/resume, 's' = step, Ctrl-C = stop."
  # Run in the foreground so rosbag play owns the TTY and the spacebar pause works.
  rosbag play "${REPLAY_BAGS[@]}" --clock -r "${SUMMER_SCHOOL_BAG_RATE}"
else
  echo "[run_demo] stack is running. In a SEPARATE terminal, start the (pausable) bag replay:"
  echo "  docker compose run --rm summer_school_demo_maintainer \\"
  echo "    /workspace/demo/scripts/replay_bag.sh ${SUMMER_SCHOOL_REPLAY_MODE:-full}"
  echo "[run_demo] (SPACE pauses the replay in that terminal). Ctrl-C here stops the stack."
  wait
fi
