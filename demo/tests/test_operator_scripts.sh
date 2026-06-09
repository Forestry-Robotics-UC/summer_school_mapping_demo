#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="${ROOT_DIR}/scripts"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || fail "missing file: ${path}"
}

assert_contains() {
  local path="$1"
  local pattern="$2"
  rg -q "${pattern}" "${path}" || fail "expected pattern '${pattern}' in ${path}"
}

assert_file "${SCRIPTS_DIR}/run_mapping.sh"
assert_file "${SCRIPTS_DIR}/run_full_pipeline.sh"
assert_file "${SCRIPTS_DIR}/run_prune.sh"

assert_contains "${SCRIPTS_DIR}/run_mapping.sh" 'SUMMER_SCHOOL_RUN_PRUNE=false'
assert_contains "${SCRIPTS_DIR}/run_mapping.sh" 'SUMMER_SCHOOL_RUN_MAPPER=true'
assert_contains "${SCRIPTS_DIR}/run_mapping.sh" 'SUMMER_SCHOOL_RUN_REPLAY_PRUNE=true'
assert_contains "${SCRIPTS_DIR}/run_mapping.sh" 'SUMMER_SCHOOL_RUN_REPLAY_RAW=true'

assert_contains "${SCRIPTS_DIR}/run_full_pipeline.sh" 'SUMMER_SCHOOL_RUN_PRUNE=true'
assert_contains "${SCRIPTS_DIR}/run_full_pipeline.sh" 'SUMMER_SCHOOL_RUN_MAPPER=true'
assert_contains "${SCRIPTS_DIR}/run_full_pipeline.sh" 'SUMMER_SCHOOL_RUN_REPLAY_SKY_MASK=true'
assert_contains "${SCRIPTS_DIR}/run_full_pipeline.sh" 'SUMMER_SCHOOL_RUN_REPLAY_LOCALIZATION=true'

assert_contains "${SCRIPTS_DIR}/run_prune.sh" 'SUMMER_SCHOOL_RUN_PRUNE=true'
assert_contains "${SCRIPTS_DIR}/run_prune.sh" 'SUMMER_SCHOOL_RUN_MAPPER=false'
assert_contains "${SCRIPTS_DIR}/run_prune.sh" 'SUMMER_SCHOOL_RUN_RQT_RECONFIGURE=true'
assert_contains "${SCRIPTS_DIR}/run_prune.sh" 'SUMMER_SCHOOL_PRUNE_DEBUG_PROJECT_LIDAR=true'
assert_contains "${SCRIPTS_DIR}/run_prune.sh" 'SUMMER_SCHOOL_PRUNE_OVERLAY_OUTPUT_DIR=/workspace/demo/logs/overlays'

echo "operator script checks passed"
