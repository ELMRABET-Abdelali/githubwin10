#!/usr/bin/env bash
set -u

echo "=== GitHubWin10 : diagnostic non destructif ==="
if command -v docker >/dev/null 2>&1; then
  docker --version
  docker compose version || true
  if docker info >/dev/null 2>&1; then
    echo "Docker daemon disponible."
  else
    echo "ATTENTION : Docker CLI present, mais daemon non accessible."
  fi
else
  echo "ATTENTION : Docker absent. Voir README.md."
fi

if [[ -c /dev/kvm ]]; then
  echo "KVM disponible dans ce terminal : acceleration materielle possible."
else
  echo "KVM indisponible ici : emulation logicielle seulement, tres lente."
fi

if [[ -c /dev/net/tun ]]; then
  echo "TUN disponible (non requis pour le mode NETWORK=user)."
else
  echo "TUN indisponible ; mode NETWORK=user prevu."
fi

echo "CPU logiques : $(nproc)"
free -h || true
df -h . || true
echo "ATTENTION : 32 Go de stockage total pour Linux + Docker + ISO + Windows 10 peut etre insuffisant."
