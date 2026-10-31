#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
echo "=== Connexions privees ==="
echo "Portainer : admin"
if [[ -r .secrets/portainer-password ]]; then
  printf 'Mot de passe Portainer (initial uniquement) : '
  cat .secrets/portainer-password
else
  echo "Mot de passe Portainer non genere."
fi
if [[ -r .env ]]; then
  printf 'Compte Windows : '
  sed -n 's/^WINDOWS_USERNAME=//p' .env
  printf 'Mot de passe Windows : '
  sed -n 's/^WINDOWS_PASSWORD=//p' .env
fi
echo "Ne partagez jamais cette sortie."
echo "Si Portainer a deja un compte, son mot de passe existant est conserve ; le fichier n'est pas une reinitialisation."
