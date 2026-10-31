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

echo "Identifiant initial Portainer : admin"
echo "Pour afficher les identifiants : bash scripts/show-credentials.sh"

if ! docker info >/dev/null 2>&1; then
  echo "ERREUR : le moteur Docker est indisponible." >&2
  exit 1
fi

# Portainer reste utilisable meme lorsque KVM est absent.
docker compose up -d portainer

if bash scripts/check-kvm.sh; then
  echo "Demarrage de Windows 10 avec KVM (aucune emulation logicielle)."
  docker compose up -d windows
  echo "Port 8006 : bureau Windows (a garder prive dans Codespaces)."
else
  # Une vieille installation demarree avec KVM=N ne doit pas rester active.
  docker compose stop windows >/dev/null 2>&1 || true
  echo "Windows n'a PAS ete lance : KVM n'est pas accessible." >&2
  echo "Portainer reste accessible sur le port 9000." >&2
fi

docker compose ps
