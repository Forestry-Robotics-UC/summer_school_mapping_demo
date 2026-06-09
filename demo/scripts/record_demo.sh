#!/usr/bin/env bash
set -euo pipefail

DISPLAY="${DISPLAY:-:0}"
VIDEO_SIZE="${VIDEO_SIZE:-1920x1080}"
FRAMERATE="${FRAMERATE:-30}"
OUTPUT_DIR="/workspace/demo/logs"
OUTPUT_PATH="${OUTPUT_PATH:-${OUTPUT_DIR}/demo_recording.mp4}"
OVERWRITE="${OVERWRITE:-false}"

mkdir -p "${OUTPUT_DIR}"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ERROR: ffmpeg is not installed in this image." >&2
  echo "Install ffmpeg or record the host display with the presentation laptop fallback." >&2
  exit 1
fi

if [[ -e "${OUTPUT_PATH}" && "${OVERWRITE}" != "true" ]]; then
  stamp="$(date +%Y%m%d_%H%M%S)"
  OUTPUT_PATH="${OUTPUT_DIR}/demo_recording_${stamp}.mp4"
fi

echo "[record_demo] display: ${DISPLAY}.0"
echo "[record_demo] size: ${VIDEO_SIZE}"
echo "[record_demo] framerate: ${FRAMERATE}"
echo "[record_demo] output: ${OUTPUT_PATH}"

exec ffmpeg \
  -video_size "${VIDEO_SIZE}" \
  -framerate "${FRAMERATE}" \
  -f x11grab \
  -i "${DISPLAY}.0" \
  "${OUTPUT_PATH}"

