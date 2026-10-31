#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Lancer avec sudo : sudo bash scripts/install-docker-ubuntu.sh" >&2
  exit 1
fi
if [[ ! -r /etc/os-release ]]; then
  echo "Impossible d'identifier la distribution." >&2
  exit 1
fi
source /etc/os-release
if [[ "${ID}" != "ubuntu" ]]; then
  echo "Ce script est uniquement pour Ubuntu (pas pour le conteneur Codespaces)." >&2
  exit 1
fi

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  systemctl enable --now docker
  echo "Docker et Compose deja installes."
  exit 0
fi

apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

ubuntu_codename="${UBUNTU_CODENAME:-${VERSION_CODENAME}}"
arch="$(dpkg --print-architecture)"
printf 'Types: deb\nURIs: https://download.docker.com/linux/ubuntu\nSuites: %s\nComponents: stable\nArchitectures: %s\nSigned-By: /etc/apt/keyrings/docker.asc\n' "${ubuntu_codename}" "${arch}" > /etc/apt/sources.list.d/docker.sources

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
docker --version
docker compose version
