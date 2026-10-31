#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ ! -f .env ]]; then
  echo "Creer .env : cp .env.example .env ; puis modifier WINDOWS_PASSWORD." >&2
  exit 1
fi
if ! grep -Eq '^WINDOWS_PASSWORD=[^[:space:]]+' .env || grep -Fq 'CHANGER_CE_MOT_DE_PASSE_AVANT_DE_DEMARRER' .env; then
  echo "Definir un mot de passe unique dans .env avant de lancer Windows." >&2
  exit 1
fi
if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "Docker daemon indisponible. Voir README.md." >&2
  exit 1
fi

echo "Verification de la configuration..."
if [[ -c /dev/kvm ]]; then
  echo "KVM disponible : lancement accelere."
  docker compose -f compose.yaml -f compose.kvm.yaml --profile windows config --quiet
  docker compose -f compose.yaml -f compose.kvm.yaml --profile windows up -d portainer windows
else
  if [[ "${ALLOW_SOFTWARE_EMULATION:-0}" != "1" ]]; then
    echo "KVM est indisponible. Windows sera extremement lent sans acceleration." >&2
    echo "Pour essayer quand meme : ALLOW_SOFTWARE_EMULATION=1 bash scripts/start-windows.sh" >&2
    exit 1
  fi
  echo "ATTENTION : lancement sans KVM (emulation QEMU lente)."
  docker compose --profile windows config --quiet
  docker compose --profile windows up -d portainer windows
fi

echo "Conteneurs :"
docker compose --profile windows ps
echo "Windows : port 8006 (web). Portainer : 9000 HTTP prive ou 9443 HTTPS."
