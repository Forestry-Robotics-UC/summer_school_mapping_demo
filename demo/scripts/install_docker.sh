#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install_docker.sh [--dry-run]

Install Docker Engine and the Compose plugin on Debian/Ubuntu using the
official repository flow. The script does not run curl | sh.
EOF
}

dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

run() {
  if [[ "${dry_run}" == "true" ]]; then
    printf '[dry-run] %q' "$1"
    shift || true
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
    return 0
  fi
  "$@"
}

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run this script with sudo or as root." >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot determine Linux distribution: /etc/os-release is missing." >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != "ubuntu" && "${ID:-}" != "debian" ]]; then
  echo "This installer only targets Debian or Ubuntu." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

run apt-get update
run apt-get install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
run curl -fsSL "https://download.docker.com/linux/${ID}/gpg" -o /tmp/docker-gpg.key
run gpg --dearmor -o /etc/apt/keyrings/docker.gpg /tmp/docker-gpg.key
run rm -f /tmp/docker-gpg.key
run chmod a+r /etc/apt/keyrings/docker.gpg

architecture="$(dpkg --print-architecture)"
codename="${VERSION_CODENAME:-}"
if [[ -z "${codename}" ]]; then
  echo "VERSION_CODENAME is empty; cannot configure Docker repository." >&2
  exit 1
fi

cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=${architecture} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} ${codename} stable
EOF

run apt-get update
run apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
run systemctl enable --now docker

cat <<'EOF'
Docker installation complete.

Optional post-install step:
  sudo usermod -aG docker "$USER"
  newgrp docker
EOF
