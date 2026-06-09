# <img src="docs/pics/fruc_logo.png" width="140" alt="FRUC logo" hspace="2em"/> ForestSphere Summer School Demo

The demo replays a prepared ROS1 Noetic forest dataset from local files, starts PRUNE semantic point cloud fusion with the RealSense sky-mask gate, publishes CurtMini URDF TFs, starts the semantic mapper when the mapping package is available in the container, and opens RViz for presentation monitoring.

## Dataset Layout

Copy or sync the KDrive dataset into one local folder, then point `SUMMER_SCHOOL_DATASET_DIR` at it. The KDrive folder is:

https://kdrive.infomaniak.com/app/collaborate/2981078/8ed3a25e-12bc-49dc-8e1b-b70e04fa80df

KDrive is not downloaded automatically. Use a local sync/copy method outside Docker unless a direct-download or KDrive sync method is added later.

Expected local layout:

```bash
demo/
  bags/
    raw/
      2026_03_25_15_24_28__event-near_points__0_ros1_chunk_000.bag
      ...
      sky_mask_event_near_points_480p.bag
    semantic_pcl/
      prune_colored_event_near_points_480p.bag
    localization/
      localisation_tf_50hz.bag
  calibration/
    example_static_tfs.yaml
  config/
    prune_demo.yaml
    mapper_demo.yaml
    rviz_demo.rviz
```

Set `SUMMER_SCHOOL_DATASET_DIR` in `.env` to the dataset root that contains `raw/`, `semantic_pcl/`, and `localization/`. Compose does not expand `*`.

The expected prepared bag for this demo should include:

```text
/ouster/points
/camera/color/camera_info
/semantic/mask
/tf or /tf_static when available
```

`/semantic/mask` is the RealSense-derived sky mask created offline from `/camera/color/image_raw`. It must have the same message count as the source image topic. Current verified mask bag:

```text
/home/forestsphere/work_utils/PRUNE-dev/output/prune_bags/20260604_event_near_points_480p/sky_mask/sky_mask_event_near_points_480p.bag
```

## Build And Enter

### Docker install on Debian/Ubuntu

If Docker is not installed on the host, run the local installer from this folder:

```bash
sudo ./scripts/install_docker.sh
```

It follows the official Docker repository flow for Debian/Ubuntu and does not use `curl | sh`.

Manual install path, if someone prefers to do it themselves:

1. Install the Docker Engine packages from Docker's official Debian/Ubuntu repository.
2. Install the Compose plugin.
3. Add the current user to the `docker` group.
4. Re-login or run `newgrp docker`.

The runtime image is based on the official `osrf/ros:noetic-desktop-full` image. The exact package names used by this demo are:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

```bash
cd demo
cp .env.example .env
docker compose build
```

Allow X11 for RViz:

```bash
xhost +local:docker
```

Enter the maintainer container:

```bash
docker compose run --rm summer_school_demo_maintainer
```

Open the GUI/RViz view directly:

```bash
docker compose run --rm summer_school_demo_gui
```

If the mounted PRUNE/ENTFAC-Mapping sources have not been built in the image:

```bash
cd /workspace/catkin_ws
catkin build
source devel/setup.bash
```

The maintainer image bakes these source trees into the image at build time:

```text
PRUNE                -> /workspace/catkin_ws/src/prune
ENTFAC-Mapping       -> /workspace/catkin_ws/src/entfac_mapping
summer_school_mapping_demo/demo -> /workspace/demo
```

For the current maintainer image, the workspace is built into the image during `docker compose build`. Students should not get source mounts in the later locked-down container.

## Demo Commands

Check readiness:

```bash
/workspace/demo/scripts/check_demo_ready.sh
```

Run mapping only. This replays the PRUNE-colored bag for map input and the raw chunk bags for visualization, but it does not start PRUNE:

```bash
/workspace/demo/scripts/run_mapping.sh
```

Run the full pipeline. This replays raw chunks, sky mask, and localization, then starts PRUNE and mapping:

```bash
/workspace/demo/scripts/run_full_pipeline.sh
```

Run PRUNE only. This replays raw chunks, sky mask, and localization, starts PRUNE, enables demo-friendly projection overlays, and opens `rqt_reconfigure`:

```bash
/workspace/demo/scripts/run_prune.sh
```

CurtMini URDF TFs are enabled by default:

```bash
CURTMINI_URDF=/workspace/catkin_ws/src/entfac_mapping/entfac_mapping_ros/urdf/curtmini/robot.urdf.xacro
RUN_CURTMINI_URDF=true
```

Use `RUN_STATIC_TFS=true` for supplemental map/odom fallback TFs from `/workspace/demo/calibration/example_static_tfs.yaml`.

Change raw replay inputs and replay rate:

```bash
SUMMER_SCHOOL_RAW_BAG_PATTERN='raw/2026_03_25_15_24_28__event-near_points__0_ros1_chunk_*.bag' \
SUMMER_SCHOOL_PRUNE_BAG=semantic_pcl/prune_colored_event_near_points_480p.bag \
SUMMER_SCHOOL_SKY_MASK_BAG=raw/sky_mask_event_near_points_480p.bag \
SUMMER_SCHOOL_LOCALIZATION_BAG=localization/localisation_tf_50hz.bag \
SUMMER_SCHOOL_BAG_RATE=1.0 \
/workspace/demo/scripts/run_full_pipeline.sh
```

Record the display:

```bash
/workspace/demo/scripts/record_demo.sh
```

Launch only the GUI view from inside the container:

```bash
rviz -d /workspace/demo/config/rviz_demo.rviz
```

## Demo-Day Checklist

- Dataset folder is present and mounted into `/workspace/demo/bags`.
- Docker image builds before the session.
- Catkin workspace is built and sourced.
- Maintainer image includes PRUNE and the semantic mapper binaries already built into the image.
- CurtMini URDF renders with `xacro` and `robot_state_publisher` is available.
- RViz opens through X11.
- The custom demo RViz view shows the CurtMini robot model, TF tree, image feed, sky mask, PRUNE cloud, and semantic map in one place.
- Bag topics pass `check_demo_ready.sh`.
- TF tree is valid for `map`, `odom`, `base_link`, LiDAR, and camera optical frames.
- `run_full_pipeline.sh` uses the `map -> odom` static bridge from `example_static_tfs.yaml` unless the bags already provide the needed TF.
- `run_prune.sh` publishes `/debug/lidar_projection`, uses 2-pixel projected dots, and writes gate overlays under `/workspace/demo/logs/overlays`.
- PRUNE output appears on `/colored_pcl_node/semantic_pointcloud`.
- Mapper output appears on `/semantic_mapping_node/semantic_map_pointcloud` when `entfac_mapping_ros` is available.
- Fallback recording can be created in `/workspace/demo/logs`.

## Known Integration Points

- PRUNE launch: `roslaunch prune_ros prune.launch`.
- Mapper launch: `roslaunch entfac_mapping_ros semantic_mapping.launch`.
- CurtMini URDF: `/workspace/catkin_ws/src/entfac_mapping/entfac_mapping_ros/urdf/curtmini/robot.urdf.xacro`.
- UFOMapping source mount: `/workspace/catkin_ws/src/ufomap`.
- UFOMapping-specific runtime package name is fork-dependent. Add the real package to `UFOMAP_SOURCE_DIR`, build it, then launch its documented node or add a small wrapper launch once the package name is confirmed.
