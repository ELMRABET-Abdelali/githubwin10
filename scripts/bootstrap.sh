#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
umask 077
mkdir -p .secrets
if [[ ! -s .secrets/portainer-password ]]; then
  openssl rand -hex 16 > .secrets/portainer-password
fi
if [[ ! -f .env ]]; then
  cp .env.example .env
fi
if grep -q 'CHANGER_CE_MOT_DE_PASSE_AVANT_DE_DEMARRER' .env; then
  newpass="$(openssl rand -hex 16)"
  sed -i "s/^WINDOWS_PASSWORD=.*/WINDOWS_PASSWORD=${newpass}/" .env
fi
chmod 600 .env .secrets/portainer-password
echo "Identifiant Portainer : admin"
echo "Voir le mot de passe : bash scripts/show-credentials.sh"
if ! docker info >/dev/null 2>&1; then
  echo "ERREUR : daemon Docker indisponible. Voir scripts/check-host.sh" >&2
  exit 1
fi
if [[ -c /dev/kvm ]]; then
  echo "KVM disponible : demarrage Windows accelere."
  docker compose -f compose.yaml -f compose.kvm.yaml up -d
else
  echo "ATTENTION : KVM non accessible. Demarrage automatique en emulation QEMU lente."
  docker compose up -d
fi
docker compose ps
echo "Ouvrez l'onglet PORTS : Portainer 9000, Windows 8006 (visibilite privee)."
