#!/usr/bin/env bash
set -euo pipefail

source /opt/ros/noetic/setup.bash

export ROS_MASTER_URI="${ROS_MASTER_URI:-http://localhost:11311}"
export ROS_IP="${ROS_IP:-127.0.0.1}"
export QT_X11_NO_MITSHM="${QT_X11_NO_MITSHM:-1}"

if [[ -f /workspace/catkin_ws/install/setup.bash ]]; then
  source /workspace/catkin_ws/install/setup.bash
elif [[ -f /workspace/catkin_ws/devel/setup.bash ]]; then
  source /workspace/catkin_ws/devel/setup.bash
fi

cat <<'EOF'
ForestSphere summer school demo container

Useful commands:
  /workspace/demo/scripts/check_demo_ready.sh
  /workspace/demo/scripts/run_mapping.sh
  /workspace/demo/scripts/run_full_pipeline.sh
  /workspace/demo/scripts/run_prune.sh
  /workspace/demo/scripts/replay_bag.sh
EOF

exec "$@"
