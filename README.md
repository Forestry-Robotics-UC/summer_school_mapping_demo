# <img src="docs/pics/fruc_logo.png" width="140" alt="FRUC logo" hspace="2em"/> ForestSphere Summer School Demo

This folder contains the live demo environment for the ForestSphere summer school.

It is designed for non-robotics users to run prepared demonstrations from recorded data. You do not need to understand ROS internals to use it. In normal use, you only need:

1. the dataset folder
2. Docker
3. one command for the demo mode you want

## What This Demo Does

There are three demo modes:

- `run_mapping.sh`
  - shows mapping results from a prepared semantic point cloud bag
  - also replays the raw sensor bags for context in RViz
  - does not run PRUNE live
- `run_full_pipeline.sh`
  - runs the full live pipeline from raw bags
  - includes sky mask, PRUNE, and mapping
- `run_prune.sh`
  - runs only the PRUNE fusion stage
  - opens debug-friendly views for presentation

If you are unsure which one to use:

- use `run_mapping.sh` for the safest demo
- use `run_full_pipeline.sh` to show the complete live pipeline
- use `run_prune.sh` to focus on PRUNE behavior and gates

## 1. Prepare The Dataset Folder

The bags are not downloaded automatically.

Copy or sync the summer school dataset from KDrive into one local folder:

https://kdrive.infomaniak.com/app/collaborate/2981078/8ed3a25e-12bc-49dc-8e1b-b70e04fa80df

Expected folder layout:

```bash
summer_school/
  raw/
    2026_03_25_15_24_28__event-near_points__0_ros1_chunk_000.bag
    2026_03_25_15_24_28__event-near_points__0_ros1_chunk_001.bag
    ...
    sky_mask_event_near_points_480p.bag
  semantic_pcl/
    prune_colored_event_near_points_480p.bag
  localization/
    localisation_tf_50hz.bag
```

Important:

- `raw/` contains the original sensor recordings split into chunks
- `semantic_pcl/` contains the prepared PRUNE-colored point cloud bag
- `localization/` contains localization / TF support bags
- `sky_mask_event_near_points_480p.bag` must match the RealSense image stream used for PRUNE

## 2. Install Docker

If Docker is not already installed:

```bash
cd /home/forestsphere/work_utils/summer_school_mapping_demo/demo
sudo ./scripts/install_docker.sh
```

This uses the official Docker repository flow for Debian/Ubuntu.

If you prefer to install manually, install:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

## 3. Build The Demo Image

From this folder:

```bash
cd /home/forestsphere/work_utils/summer_school_mapping_demo/demo
cp .env.example .env
docker compose build
```

This image already includes the maintainer workspace with:

- PRUNE
- ENTFAC-Mapping
- CurtMini URDFs
- the demo scripts and configs

## 4. Allow RViz To Open

Before running the demo:

```bash
xhost +local:docker
```

This allows Docker to open GUI windows on your screen.

## 5. Run A Demo

All examples below assume the dataset is at:

```bash
/home/forestsphere/datasets/summer_school
```

If your dataset is somewhere else, replace that path.

### Option A: Mapping Only

Best default for presentations.

```bash
cd /home/forestsphere/work_utils/summer_school_mapping_demo/demo
SUMMER_SCHOOL_DATASET_DIR=/home/forestsphere/datasets/summer_school \
docker compose run --rm summer_school_demo_maintainer \
/workspace/demo/scripts/run_mapping.sh
```

What you should see:

- RViz opens
- the CurtMini model appears
- the semantic map appears
- raw bags replay in the background for context

### Option B: Full Pipeline

Runs the live pipeline from raw bags.

```bash
cd /home/forestsphere/work_utils/summer_school_mapping_demo/demo
SUMMER_SCHOOL_DATASET_DIR=/home/forestsphere/datasets/summer_school \
docker compose run --rm summer_school_demo_maintainer \
/workspace/demo/scripts/run_full_pipeline.sh
```

What you should see:

- RViz opens
- PRUNE runs live
- mapping runs live
- the full replay starts from the raw dataset

### Option C: PRUNE Only

Use this when the talk is specifically about PRUNE and filtering / gates.

```bash
cd /home/forestsphere/work_utils/summer_school_mapping_demo/demo
SUMMER_SCHOOL_DATASET_DIR=/home/forestsphere/datasets/summer_school \
docker compose run --rm summer_school_demo_maintainer \
/workspace/demo/scripts/run_prune.sh
```

What you should see:

- RViz opens
- `rqt_reconfigure` opens
- projected LiDAR debug views are available
- PRUNE overlays are written to `demo/logs/overlays`

## 6. Replay Bags Manually

Normally you do not need this, because the main run scripts can start replay themselves.

Use manual replay only if you want the bag playback in a separate terminal so you can pause it with the keyboard.

From inside the container:

```bash
/workspace/demo/scripts/replay_bag.sh mapping
/workspace/demo/scripts/replay_bag.sh full
/workspace/demo/scripts/replay_bag.sh prune
```

Meaning:

- `mapping`
  - replays raw + prepared semantic point cloud + localization
- `full`
  - replays raw + sky mask + localization
- `prune`
  - same replay inputs as `full`, intended for PRUNE-only demos

Interactive controls in the replay terminal:

- `SPACE` pause / resume
- `s` single-step
- `Ctrl-C` stop replay

## 7. Quick Readiness Check

Before a session, run:

```bash
docker compose run --rm summer_school_demo_maintainer \
/workspace/demo/scripts/check_demo_ready.sh
```

This checks:

- the selected bags exist
- the configs exist
- the bag topics look correct
- ROS tools are available inside the container

## 8. Change Which Bags Are Used

If you need different bag names, set them explicitly:

```bash
SUMMER_SCHOOL_DATASET_DIR=/home/forestsphere/datasets/summer_school \
SUMMER_SCHOOL_RAW_BAG_PATTERN='raw/2026_03_25_15_24_28__event-near_points__0_ros1_chunk_*.bag' \
SUMMER_SCHOOL_PRUNE_BAG='semantic_pcl/prune_colored_event_near_points_480p.bag' \
SUMMER_SCHOOL_SKY_MASK_BAG='raw/sky_mask_event_near_points_480p.bag' \
SUMMER_SCHOOL_LOCALIZATION_BAG='localization/localisation_tf_50hz.bag' \
SUMMER_SCHOOL_BAG_RATE=1.0 \
docker compose run --rm summer_school_demo_maintainer \
/workspace/demo/scripts/run_full_pipeline.sh
```

## 9. Record The Screen

To save a recording:

```bash
/workspace/demo/scripts/record_demo.sh
```

The recording is saved under:

```bash
demo/logs/
```

## 10. If Something Goes Wrong

Start with these checks:

1. confirm the dataset folder path is correct
2. confirm `raw/`, `semantic_pcl/`, and `localization/` exist
3. run the readiness check
4. make sure `xhost +local:docker` was run
5. rebuild the image if code or configs changed:

```bash
docker compose build
```

Common symptoms:

- RViz does not open:
  - X11 is not allowed yet
- bags do not replay:
  - the dataset folder path is wrong
  - the bag names do not match the configured defaults
- the map stays empty in `run_mapping.sh`:
  - the semantic point cloud bag is missing from `semantic_pcl/`
- PRUNE waits for camera info:
  - confirm the demo calibration file exists:
    - `/workspace/demo/calibration/curt_mini_realsense_camera_info_480p.txt`

## 11. Demo-Day Checklist

- dataset is present locally
- Docker builds before the session
- `xhost +local:docker` was run
- `check_demo_ready.sh` passes
- `run_mapping.sh` opens RViz successfully
- the CurtMini model is visible
- the semantic map is visible
- the PRUNE cloud is visible when using PRUNE modes
- a fallback recording can be created

## Maintainer Notes

This is still a maintainer-facing environment.

It currently includes source-based workspace content for:

- PRUNE
- ENTFAC-Mapping
- UFOMapping integration hooks
- CurtMini URDF assets

The later student-facing version should be more locked down and should expose only the prepared commands, configs, and dataset mounts.
