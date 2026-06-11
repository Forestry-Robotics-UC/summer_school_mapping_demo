#!/usr/bin/env bash
set -euo pipefail

PRUNE_CONFIG="/workspace/demo/config/prune_demo.yaml"
UFOMAP_CONFIG="/workspace/demo/config/ufomap_demo.yaml"
RVIZ_CONFIG="/workspace/demo/config/rviz_demo.rviz"
RVIZ_PROFILE="${SUMMER_SCHOOL_RVIZ_PROFILE:-${RVIZ_PROFILE:-mapping}}"
CURTMINI_URDF="${SUMMER_SCHOOL_CURTMINI_URDF:-${CURTMINI_URDF:-/workspace/demo/config/urdf/curtmini/robot.urdf.xacro}}"
RUN_CURTMINI_URDF="${SUMMER_SCHOOL_RUN_CURTMINI_URDF:-${RUN_CURTMINI_URDF:-true}}"
RUN_MAPPER="${SUMMER_SCHOOL_RUN_MAPPER:-${RUN_MAPPER:-true}}"
RUN_RVIZ="${SUMMER_SCHOOL_RUN_RVIZ:-${RUN_RVIZ:-true}}"
RUN_PRUNE="${SUMMER_SCHOOL_RUN_PRUNE:-${RUN_PRUNE:-true}}"
RUN_RQT_RECONFIGURE="${SUMMER_SCHOOL_RUN_RQT_RECONFIGURE:-${RUN_RQT_RECONFIGURE:-false}}"
UFOMAP_INPUT_TOPIC="${SUMMER_SCHOOL_UFOMAP_INPUT_TOPIC:-${UFOMAP_INPUT_TOPIC:-/ouster/rgb_colored}}"
PRUNE_OUTPUT_TOPIC="${SUMMER_SCHOOL_PRUNE_OUTPUT_TOPIC:-${PRUNE_OUTPUT_TOPIC:-${UFOMAP_INPUT_TOPIC}}}"

PIDS=()
declare -A CMD_BY_PID=()

cleanup() {
  for pid in "${PIDS[@]}"; do
    kill "${pid}" >/dev/null 2>&1 || true
  done
  wait || true
}
trap cleanup EXIT INT TERM

source /opt/ros/noetic/setup.bash
if [[ -f /workspace/catkin_ws/install/setup.bash ]]; then
  source /workspace/catkin_ws/install/setup.bash
elif [[ -f /workspace/catkin_ws/devel/setup.bash ]]; then
  source /workspace/catkin_ws/devel/setup.bash
fi

start_background() {
  "$@" &
  pid="$!"
  PIDS+=("$pid")
  CMD_BY_PID["$pid"]="$*"
  sleep 1
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

if [[ "${RUN_PRUNE}" == "true" ]]; then
  echo "[run_demo] starting PRUNE"
  # Use the provided PRUNE config file directly; do not inject environment-variable overrides.
  python3 - "${PRUNE_CONFIG}" "/tmp/prune_demo_runtime.yaml" <<'PY'
import sys
import shutil
shutil.copyfile(sys.argv[1], sys.argv[2])
PY
  start_background roslaunch prune_ros prune.launch \
    use_sim_time:=true \
    dataset_config:=/tmp/prune_demo_runtime.yaml \
    output_topic:="${PRUNE_OUTPUT_TOPIC}" \
    rviz:=false
else
  echo "[run_demo] PRUNE stage disabled; expecting pre-colored /ouster/rgb_colored from the replay bag"
fi

if [[ "${RUN_MAPPER}" == "true" ]]; then
  echo "[run_demo] starting UFOMAP mapping server; reference config=${UFOMAP_CONFIG}"
  rosparam load "${UFOMAP_CONFIG}" /ufomap_mapping_server_node
  start_background rosrun ufomap_mapping ufomap_mapping_server_node \
    __name:=ufomap_mapping_server_node \
    cloud_in:="${UFOMAP_INPUT_TOPIC}"
fi

if [[ "${RUN_RQT_RECONFIGURE}" == "true" ]]; then
  echo "[run_demo] starting rqt_reconfigure"
  start_background rosrun rqt_reconfigure rqt_reconfigure
fi

if [[ "${RUN_RVIZ}" == "true" ]]; then
  RVIZ_RUNTIME_CONFIG="${RVIZ_CONFIG}"
  if [[ "${RVIZ_PROFILE}" == "prune" ]]; then
    RVIZ_RUNTIME_CONFIG="/workspace/demo/config/rviz_prune_demo.rviz"
  elif [[ "${RVIZ_PROFILE}" == "mapping" ]]; then
    RVIZ_RUNTIME_CONFIG="/workspace/demo/config/rviz_mapping_demo.rviz"
  fi
  echo "[run_demo] starting RViz"
  start_background rviz -d "${RVIZ_RUNTIME_CONFIG}"
fi

wait -n || true

