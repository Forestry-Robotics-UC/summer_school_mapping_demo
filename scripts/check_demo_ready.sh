#!/usr/bin/env bash
set -euo pipefail

SUMMER_SCHOOL_RAW_BAG_PATTERN="${SUMMER_SCHOOL_RAW_BAG_PATTERN:-${SUMMER_SCHOOL_RAW_BAG:-${SUMMER_SCHOOL_BAG:-${DEMO_BAG:-raw/2026_03_25_15_24_28__event-near_points__0_ros1_chunk_*.bag}}}}"
SUMMER_SCHOOL_PRUNE_BAG="${SUMMER_SCHOOL_PRUNE_BAG:-${SUMMER_SCHOOL_BAG:-semantic_pcl/prune_colored_event_near_points_480p.bag}}"
SUMMER_SCHOOL_LOCALIZATION_BAG="${SUMMER_SCHOOL_LOCALIZATION_BAG:-localization/localisation_tf_50hz.bag}"
shopt -s nullglob
RAW_BAG_PATHS=(/workspace/demo/bags/${SUMMER_SCHOOL_RAW_BAG_PATTERN})
shopt -u nullglob
PRUNE_BAG_PATH="/workspace/demo/bags/${SUMMER_SCHOOL_PRUNE_BAG}"
LOCALIZATION_BAG_PATH="/workspace/demo/bags/${SUMMER_SCHOOL_LOCALIZATION_BAG}"

REQUIRED_TOPICS=(
  "/ouster/points"
  "/camera/color/image_raw"
  "/camera/color/camera_info"
  "/semantic/mask"
)

OPTIONAL_TOPICS=(
  "/imu/data"
  "/tf"
  "/tf_static"
)

REQUIRED_FILES=(
  "/workspace/demo/calibration/example_static_tfs.yaml"
  "/workspace/demo/calibration/curt_mini_realsense_camera_info_480p.txt"
  "/workspace/demo/config/prune_demo.yaml"
  "/workspace/demo/config/mapper_demo.yaml"
  "/workspace/demo/config/rviz_demo.rviz"
)

REQUIRED_PACKAGES=(
  "rosbag"
  "tf2_ros"
  "rviz"
  "robot_state_publisher"
  "xacro"
  "prune_ros"
)

OPTIONAL_PACKAGES=(
  "entfac_mapping_ros"
  "ufomap_ros"
  "ufomap_mapping"
)

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

warn() {
  echo "WARN: $*" >&2
}

source /opt/ros/noetic/setup.bash
if [[ -f /workspace/catkin_ws/devel/setup.bash ]]; then
  source /workspace/catkin_ws/devel/setup.bash
fi

echo "[check] raw bags: ${RAW_BAG_PATHS[*]}"
echo "[check] prune bag: ${PRUNE_BAG_PATH}"
echo "[check] localization bag: ${LOCALIZATION_BAG_PATH}"
(( ${#RAW_BAG_PATHS[@]} > 0 )) || fail "No raw bags matched pattern. Set SUMMER_SCHOOL_RAW_BAG_PATTERN."
[[ -f "${PRUNE_BAG_PATH}" ]] || fail "PRUNE bag file not found. Copy/sync it into demo/bags or set SUMMER_SCHOOL_DATASET_DIR and SUMMER_SCHOOL_PRUNE_BAG."
[[ -f "${LOCALIZATION_BAG_PATH}" ]] || fail "Localization bag file not found. Copy/sync it into demo/bags or set SUMMER_SCHOOL_DATASET_DIR and SUMMER_SCHOOL_LOCALIZATION_BAG."

for path in "${REQUIRED_FILES[@]}"; do
  [[ -f "${path}" ]] || fail "Required file missing: ${path}"
done

if [[ "${SUMMER_SCHOOL_RUN_CURTMINI_URDF:-${RUN_CURTMINI_URDF:-true}}" == "true" ]]; then
  CURTMINI_URDF="${SUMMER_SCHOOL_CURTMINI_URDF:-${CURTMINI_URDF:-/workspace/catkin_ws/src/entfac_mapping/entfac_mapping_ros/urdf/curtmini/robot.urdf.xacro}}"
  [[ -f "${CURTMINI_URDF}" ]] || fail "CurtMini URDF missing: ${CURTMINI_URDF}"
fi

command -v roscore >/dev/null 2>&1 || fail "roscore is not available in PATH."
command -v rosbag >/dev/null 2>&1 || fail "rosbag is not available in PATH."

echo "[check] rosbag info"
rosbag info "${RAW_BAG_PATHS[0]}" >/tmp/demo_rosbag_info.txt
cat /tmp/demo_rosbag_info.txt

for topic in "${REQUIRED_TOPICS[@]}"; do
  if ! grep -Eq "^[[:space:]]*${topic//\//\\/}[[:space:]]" /tmp/demo_rosbag_info.txt; then
    fail "Required bag topic missing: ${topic}"
  fi
done

for topic in "${OPTIONAL_TOPICS[@]}"; do
  if ! grep -Eq "^[[:space:]]*${topic//\//\\/}[[:space:]]" /tmp/demo_rosbag_info.txt; then
    warn "Optional bag topic missing: ${topic}"
  fi
done

for package in "${REQUIRED_PACKAGES[@]}"; do
  rospack find "${package}" >/dev/null || fail "Required ROS package not discoverable: ${package}. Build/source the catkin workspace."
done

for package in "${OPTIONAL_PACKAGES[@]}"; do
  rospack find "${package}" >/dev/null || warn "Optional ROS package not discoverable: ${package}. Mapper/UFOMapping will be skipped unless this is installed."
done

echo "SUMMER SCHOOL DEMO READY"
