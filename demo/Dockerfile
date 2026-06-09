FROM osrf/ros:noetic-desktop-full

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=demo
ARG USER_UID=1000
ARG USER_GID=1000

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    cmake \
    ffmpeg \
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

RUN mkdir -p /workspace/catkin_ws/src /workspace/demo \
    && chown -R "${USERNAME}:${USERNAME}" /workspace

COPY --chown=${USERNAME}:${USERNAME} PRUNE /workspace/catkin_ws/src/prune
COPY --chown=${USERNAME}:${USERNAME} ENTFAC-Mapping /workspace/catkin_ws/src/entfac_mapping
COPY --chown=${USERNAME}:${USERNAME} summer_school_mapping_demo /workspace/catkin_ws/src/summer_school_mapping_demo
COPY --chown=${USERNAME}:${USERNAME} summer_school_mapping_demo/demo /workspace/demo

COPY summer_school_mapping_demo/demo/scripts/entrypoint.sh /usr/local/bin/entfac-demo-entrypoint.sh
RUN chmod +x /usr/local/bin/entfac-demo-entrypoint.sh

USER "${USERNAME}"
WORKDIR /workspace/catkin_ws

RUN source /opt/ros/noetic/setup.bash \
    && catkin config --extend /opt/ros/noetic --install --cmake-args -DCMAKE_BUILD_TYPE=Release \
    && catkin build

RUN echo "source /opt/ros/noetic/setup.bash" >> "/home/${USERNAME}/.bashrc" \
    && echo "if [ -f /workspace/catkin_ws/devel/setup.bash ]; then source /workspace/catkin_ws/devel/setup.bash; fi" >> "/home/${USERNAME}/.bashrc"

ENTRYPOINT ["/usr/local/bin/entfac-demo-entrypoint.sh"]
CMD ["/bin/bash"]
