#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "ERREUR : le moteur Docker n'est pas accessible." >&2
  exit 2
fi

# Le conteneur de developpement peut masquer /dev/kvm meme lorsque
# le moteur Docker de la machine hote y a acces.
if [[ -c /dev/kvm ]]; then
  echo "Info : /dev/kvm est visible dans le terminal Codespaces."
else
  echo "Info : /dev/kvm n'est pas visible dans le terminal Codespaces."
fi

echo "Verification du peripherique KVM sur l'hote du moteur Docker..."
if docker run --rm --network none --device=/dev/kvm alpine:3.21 sh -c 'test -c /dev/kvm && test -r /dev/kvm && test -w /dev/kvm' >/dev/null 2>&1; then
  echo "OK : Docker peut acceder au peripherique KVM."
  exit 0
fi

echo "ERREUR : /dev/kvm n'est pas accessible au moteur Docker." >&2
echo "Windows 10 ne sera pas lance en mode logiciel lent." >&2
echo "Changer un fichier Compose ou reconstruire le Codespace ne cree pas KVM." >&2
echo "Utilisez un hote Linux avec virtualisation KVM ou une VM cloud autorisant la virtualisation imbriquee." >&2
exit 1
