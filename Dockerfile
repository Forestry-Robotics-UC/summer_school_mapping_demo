# ============================================================
# Build stage — compiles private packages (PRUNE, ENTFAC-Mapping).
# Source never reaches the runtime image.
# ============================================================
FROM osrf/ros:noetic-desktop-full AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG UFOMAP_REPO_URL=https://github.com/UnknownFreeOccupied/ufomap.git
ARG UFOMAP_REF=master

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libboost-all-dev \
    libeigen3-dev \
    libflann-dev \
    liblz4-dev \
    libtbb-dev \
    python3-catkin-tools \
    python3-numpy \
    python3-opencv \
    python3-pip \
    python3-rosdep \
    python3-scipy \
    python3-yaml \
    ros-noetic-compressed-depth-image-transport \
    ros-noetic-compressed-image-transport \
    ros-noetic-image-transport \
    ros-noetic-pcl-conversions \
    ros-noetic-pcl-ros \
    ros-noetic-rosbag \
    ros-noetic-tf \
    ros-noetic-tf2-ros \
    ros-noetic-xacro \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace/catkin_ws

# Private packages — source stays in this layer only
COPY PRUNE src/prune
COPY ENTFAC-Mapping src/entfac_mapping

# UFOMapping — cloned from the public repo.
# ufomap_ros contains an RViz plugin that fails to compile on Noetic; exclude it.
# Only ufomap_mapping (the mapping server node) and ufomap_msgs are needed.
RUN git clone --depth 1 --branch "${UFOMAP_REF}" "${UFOMAP_REPO_URL}" src/ufomap \
    && touch src/ufomap/ufomap_ros/CATKIN_IGNORE

RUN source /opt/ros/noetic/setup.bash \
    && catkin config --extend /opt/ros/noetic --install --cmake-args -DCMAKE_BUILD_TYPE=Release \
    && catkin build

# ============================================================
# Runtime stage — no private source code
# ============================================================
FROM osrf/ros:noetic-desktop-full

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=demo
ARG USER_UID=1000
ARG USER_GID=1000

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ffmpeg \
    python3-numpy \
    python3-opencv \
    python3-pip \
    python3-rosdep \
    python3-rospkg \
    python3-scipy \
    python3-tqdm \
    python3-yaml \
    ros-noetic-compressed-depth-image-transport \
    ros-noetic-compressed-image-transport \
    ros-noetic-image-transport \
    ros-noetic-pcl-conversions \
    ros-noetic-pcl-ros \
    ros-noetic-rqt-reconfigure \
    ros-noetic-robot-state-publisher \
    ros-noetic-rosbag \
    ros-noetic-tf \
    ros-noetic-tf2-ros \
    ros-noetic-topic-tools \
    ros-noetic-xacro \
    sudo \
    tmux \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home "${USERNAME}" \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

RUN mkdir -p /workspace/catkin_ws /workspace/demo \
    && chown -R "${USERNAME}:${USERNAME}" /workspace

# Compiled binaries only — no source
COPY --from=builder --chown=${USERNAME}:${USERNAME} \
    /workspace/catkin_ws/install /workspace/catkin_ws/install

# Public demo assets (scripts, configs, calibration baked in as fallback;
# docker-compose mounts these from the host for live editing)
COPY --chown=${USERNAME}:${USERNAME} summer_school_mapping_demo/scripts  /workspace/demo/scripts
COPY --chown=${USERNAME}:${USERNAME} summer_school_mapping_demo/config    /workspace/demo/config
COPY --chown=${USERNAME}:${USERNAME} summer_school_mapping_demo/calibration /workspace/demo/calibration

COPY summer_school_mapping_demo/scripts/entrypoint.sh /usr/local/bin/entfac-demo-entrypoint.sh
RUN chmod +x /usr/local/bin/entfac-demo-entrypoint.sh

USER "${USERNAME}"

RUN echo "source /opt/ros/noetic/setup.bash" >> "/home/${USERNAME}/.bashrc" \
    && echo "if [ -f /workspace/catkin_ws/install/setup.bash ]; then source /workspace/catkin_ws/install/setup.bash; fi" >> "/home/${USERNAME}/.bashrc"

ENTRYPOINT ["/usr/local/bin/entfac-demo-entrypoint.sh"]
CMD ["/bin/bash"]
