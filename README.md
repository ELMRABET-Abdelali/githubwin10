# GitHubWin10 — Windows 10 + Docker + Portainer

Projet pour **GitHub Codespaces (32 Go de stockage maximum)** ou un serveur **Ubuntu x86_64**. L'image [dockurr/windows](https://github.com/dockur/windows) installe **Windows 10 Pro** dans une VM QEMU lancee par Docker.

Configuration : **4 vCPU, 4 Go RAM, disque virtuel QCOW2 de 32 Go**, interface Windows dans le navigateur (port 8006), RDP prive (port 3389) et Portainer CE (ports 9000 HTTP / 9443 HTTPS).

**Important : 32 Go de disque virtuel Windows ne signifient PAS que Windows tiendra dans un Codespace de 32 Go au total.** Linux, Docker et l'ISO Windows (~5,7 Go) utilisent aussi ce disque. L'installation est un essai a espace tres limite ; aucune reussite ne peut etre garantie.

## 1. Ouvrir GitHub Codespaces

Dans ce depot, choisir **Code → Codespaces → Create codespace on main**. GitHub applique `.devcontainer/devcontainer.json` afin de rendre Docker CLI et Compose disponibles. Aucun telechargement de Windows n'est lance automatiquement.

Dans le terminal :

```bash
cd /workspaces/githubwin10
docker version
docker compose version
bash scripts/check-host.sh
```

Si Docker ne repond pas, essayer de reconstruire le conteneur Codespaces (palette de commandes : **Codespaces: Rebuild Container**). Le fichier `.devcontainer/devcontainer.json` utilise le socket Docker de l'hote. Si aucun daemon n'est disponible, cette configuration ne peut pas le creer.

Si `/dev/kvm` est absent, Windows peut demarrer en emulation logicielle via `KVM=N`, mais sera **tres lent**. Le script ne lancera pas Windows en emulation lente sans accord explicite.

## 2. Configurer le compte Windows

```bash
cp .env.example .env
nano .env
```

Remplacer `WINDOWS_PASSWORD` par un **mot de passe fort et unique**, puis sauvegarder. Le fichier `.env` est ignore par Git : ne jamais le publier dans ce depot public.

## 3. Demarrer

Pour ne lancer que l'interface Docker/Portainer :

```bash
docker compose up -d portainer
```

Pour demarrer Portainer et Windows **avec KVM** (uniquement si `/dev/kvm` est un vrai peripherique accessible sur l'hote) :

```bash
bash scripts/start-windows.sh
```

Sans KVM, pour un **test experimental tres lent** uniquement :

```bash
ALLOW_SOFTWARE_EMULATION=1 bash scripts/start-windows.sh
```

Les scripts ne suppriment aucun ancien conteneur ni volume Docker. En particulier, un ancien Windows 11 provenant du depot `ratech` peut occuper le stockage du meme Codespace : verifier avant de lancer le nouveau Windows.

## 4. Interfaces graphiques

Dans VS Code / Codespaces, ouvrir l'onglet **Ports**. Les ports doivent rester **Private**.

| Service | Port local | Interface |
| --- | --- | --- |
| Windows 10 (web) | 8006 | `http://localhost:8006` / lien prive du port |
| Portainer (Codespaces) | 9000 | `http://localhost:9000` / lien prive du port |
| Portainer HTTPS (serveur Ubuntu) | 9443 | `https://localhost:9443` |
| Windows RDP | 3389 TCP | `localhost:3389`, via tunnel SSH ou routage prive |

Le port 9000 est HTTP **sur localhost seulement** ; ne le rendre jamais public. Pour une VM Ubuntu distante, utiliser de preference 9443 avec tunnel SSH. La protection du bureau web Windows est activee.

## 5. Diagnostic, arret et reprise

```bash
df -h
docker system df -v
docker compose ps -a
docker compose logs -f windows
docker compose stop windows
docker compose start windows
```

Ne pas utiliser `docker compose down -v` ni `docker volume prune` : ces commandes peuvent effacer le disque Windows et les donnees Portainer. Le volume du nouveau Windows se nomme `githubwin10_windows_storage`.

**Codespaces n'est pas une VM Windows permanente** : il consomme des heures-coeur pendant qu'il est actif, et du stockage meme arrete. Les droits KVM, les limites de quota et le stockage disponible dependent de GitHub. Une licence Windows appropriee reste necessaire ; Windows 10 Pro a atteint sa fin de support general en octobre 2025.

## 6. Hote Ubuntu (hors Codespaces)

Sur un vrai hote Ubuntu avec `sudo` :

```bash
git clone https://github.com/ELMRABET-Abdelali/githubwin10.git
cd githubwin10
sudo bash scripts/install-docker-ubuntu.sh
cp .env.example .env
nano .env
sudo bash scripts/check-host.sh
sudo bash scripts/start-windows.sh
```

## References

- [dockurr/windows](https://github.com/dockur/windows)
- [Portainer CE](https://docs.portainer.io/start/install-ce/server/docker/linux)
- [Docker Engine Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [GitHub Codespaces — machines et stockage](https://docs.github.com/en/codespaces/customizing-your-codespace/changing-the-machine-type-for-your-codespace)
