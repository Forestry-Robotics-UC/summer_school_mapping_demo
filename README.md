# <img src="docs/pics/fruc_logo.png" width="140" alt="FRUC logo" hspace="2em"/> ForestSphere Summer School Demo

Live mapping demo for the ForestSphere summer school. Runs from recorded data inside a pre-built Docker image. You do not need to install ROS or build anything.

## What This Demo Does

| Script | What it shows |
|---|---|
| `run_mapping.sh` | Prepared semantic map replayed from bags. Safest for presentations. |
| `run_full_pipeline.sh` | Full live pipeline — raw bags → sky mask → PRUNE → mapping. |
| `run_prune.sh` | ENTFAC-Sensor-Fusion / PRUNE stage only, with debug overlays. |

Start with `run_mapping.sh` if you are unsure.

## Requirements

- Linux with Docker installed ([install guide](https://docs.docker.com/engine/install/ubuntu/))
- A display (X11)
- The summer school dataset

## 1. Get The Code

```bash
git clone <repo-url>
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

Download the dataset from KDrive:

https://kdrive.infomaniak.com/app/collaborate/2981078/8ed3a25e-12bc-49dc-8e1b-b70e04fa80df

Place the files inside the `bags/` folder so the layout looks like this:

```
bags/
  raw_notf/
    2026_03_25_15_24_28__event-near_points__0_ros1_chunk_000_notf.bag
    2026_03_25_15_24_28__event-near_points__0_ros1_chunk_001_notf.bag
    ...
  raw/
    sky_mask_event_near_points_480p.bag
  semantic_pcl/
    prune_colored_rgb_no_gates_480p.bag
  localisation_tf_50hz.bag
```

No other configuration is needed as long as bags are in `bags/`.

## 4. Allow Docker To Open Windows

```bash
xhost +local:docker
```

Run this once per login session.

## 5. Check Your Display

```bash
echo $DISPLAY
```

If the output is not `:1`, open `.env` and update the `DISPLAY=` line to match.

## 6. Run The Demo

### Mapping (recommended)

```bash
docker compose run --rm summer_school_demo_maintainer \
  /workspace/demo/scripts/run_mapping.sh
```

RViz opens. The CurtMini robot model and semantic map appear. Replay starts automatically.

### Full Pipeline

```bash
docker compose run --rm summer_school_demo_maintainer \
  /workspace/demo/scripts/run_full_pipeline.sh
```

### PRUNE Only

```bash
docker compose run --rm summer_school_demo_maintainer \
  /workspace/demo/scripts/run_prune.sh
```

## 7. Pause And Resume Bag Replay

Open a second terminal and connect to the running container:

```bash
docker exec -it forestsphere_summer_school_demo_maintainer bash
/workspace/demo/scripts/replay_bag.sh mapping   # or: full, prune
```

Controls:

- `SPACE` — pause / resume
- `s` — single step
- `Ctrl-C` — stop

## 8. Readiness Check

Run before a session to verify bags, configs, and tools are in place:

```bash
docker compose run --rm summer_school_demo_maintainer \
  /workspace/demo/scripts/check_demo_ready.sh
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| RViz does not open | Run `xhost +local:docker`; check `DISPLAY=` in `.env` matches `echo $DISPLAY` |
| `no bags matched` error | Check that bags are inside `bags/` with the correct subfolder layout |
| Map stays empty in mapping mode | `bags/semantic_pcl/prune_colored_rgb_no_gates_480p.bag` is missing |
| PRUNE waits forever | Camera info file missing: `calibration/curt_mini_realsense_camera_info_480p.txt` |

## Demo-Day Checklist

- [ ] `SUMMER_SCHOOL_DEMO_IMAGE` set in `.env`
- [ ] bags are in `bags/` with correct layout
- [ ] `xhost +local:docker` done
- [ ] `DISPLAY` in `.env` matches `echo $DISPLAY`
- [ ] `check_demo_ready.sh` passes
- [ ] `run_mapping.sh` opens RViz and the map is visible

---

For build, publish, and advanced configuration notes see `maintainer_notes.md` (local only, not committed).
