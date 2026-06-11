# <img src="docs/pics/fruc_logo.png" width="140" alt="FRUC logo" hspace="2em"/> ForestSphere Summer School Demo

Live mapping demo for the ForestSphere summer school. Runs from recorded data inside a Docker image. No host ROS installation required.

## What This Demo Does

| Script | What it runs |
|---|---|
| `run_mapping.sh` | UFOMap from pre-colored bags. Recommended for presentations. |
| `run_full_pipeline.sh` | Raw bags → sky mask → PRUNE → UFOMap. Full live pipeline. |
| `run_prune.sh` | PRUNE stage only with debug overlays. |

Start with `run_mapping.sh` if unsure.

## Requirements

- Linux with Docker installed ([install guide](https://docs.docker.com/engine/install/ubuntu/))
- A display (X11)
- The summer school dataset

If Docker is not installed, use the helper script:

```bash
sudo ./scripts/install_docker.sh
```

## 1. Get The Code

```bash
git clone https://github.com/Forestry-Robotics-UC/summer_school_mapping_demo.git
cd summer_school_mapping_demo
```

## 2. Get The Docker Image

```bash
docker pull duda1202/fruc:forestsphere-summer-school-demo-noetic
```

Then open `.env` and set:

```
SUMMER_SCHOOL_DEMO_IMAGE=duda1202/fruc:forestsphere-summer-school-demo-noetic
```

## 3. Copy The Dataset Into bags/

Download the dataset from [KDrive](https://kdrive.infomaniak.com/app/share/2981078/bda42ab6-4737-4eb1-ba80-6a3279133425).

Place files inside `bags/` so the layout looks like this:

```
bags/
  raw/
    pinhal_demo_ros1_chunk_000.bag
    pinhal_demo_ros1_chunk_001.bag
    ...
    pinhal_demo_sky_mask_480p.bag
  semantic_pcl/
    pinhal_demo_segmented_pcl.bag
  pinhal_demo_localisation_tf_50hz.bag
```

If your bags are stored elsewhere, set `SUMMER_SCHOOL_DATASET_DIR` in `.env`.

## 4. Configure .env

Copy the example and adjust for your machine:

```bash
cp .env.example .env   # if an example exists, otherwise .env is ready to use
```

Key variables:

| Variable | Purpose |
|---|---|
| `SUMMER_SCHOOL_DATASET_DIR` | Absolute path to your `bags/` folder if not the default |
| `SUMMER_SCHOOL_BAG_RATE` | Replay speed (1.0 = real-time, 0.75 = 75%) |
| `DISPLAY` | X display for RViz (must match `echo $DISPLAY`) |

## 5. Allow Docker To Open Windows

```bash
xhost +local:docker
```

Run once per login session.

## 6. Run The Demo

All demo scripts run inside the container. Open two terminals.

### Terminal 1 — start the stack

**Mapping (recommended):**
```bash
docker compose run --rm summer_school_demo \
  /workspace/demo/scripts/run_mapping.sh
```

**Full pipeline:**
```bash
docker compose run --rm summer_school_demo \
  /workspace/demo/scripts/run_full_pipeline.sh
```

**PRUNE only:**
```bash
docker compose run --rm summer_school_demo \
  /workspace/demo/scripts/run_prune.sh
```

### Terminal 2 — start bag replay

```bash
docker compose exec summer_school_demo /workspace/demo/scripts/replay_bag.sh mapping
```

Replace `mapping` with `full` or `prune` to match the stack mode. Press **Space** to pause/resume, **s** to step, **Ctrl-C** to stop.

## 7. Readiness Check

Run before a session to verify bags, configs, and tools are in place:

```bash
docker compose run --rm summer_school_demo \
  /workspace/demo/scripts/check_demo_ready.sh
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| RViz does not open | Run `xhost +local:docker`; check `DISPLAY=` in `.env` matches `echo $DISPLAY` |
| `no bags matched` error | Check bags are in `bags/` with the correct subfolder layout |
| Map stays empty | `bags/semantic_pcl/pinhal_demo_segmented_pcl.bag` is missing or does not publish `/ouster/rgb_colored` |
| UFOMap display blank | Confirm `insert_depth` and `publish_depth` in `config/ufomap_demo.yaml` are both `0` |
| PRUNE waits forever | Camera info file missing: `calibration/curt_mini_realsense_camera_info_480p.txt` |
| Changes to `.env` not picked up | Restart the container: `docker compose down && docker compose up -d` |

## Demo-Day Checklist

- [ ] Bags in `bags/` with correct layout
- [ ] `xhost +local:docker` done
- [ ] `DISPLAY` in `.env` matches `echo $DISPLAY`
- [ ] `docker compose build` completed successfully
- [ ] `check_demo_ready.sh` passes
- [ ] `run_mapping.sh` opens RViz and the UFOMap display is visible
