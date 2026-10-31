# GitHubWin10 — Windows 10 + Portainer, KVM obligatoire

Site pédagogique : https://githubwin10-etudiants.vercel.app/

## Identifiants Windows par defaut

Pour une **nouvelle installation**, utilisateur Windows : `win10` ; mot de passe Windows : `win10`. Le compte Portainer reste separe (`admin` + mot de passe genere localement, a consulter avec `bash scripts/show-credentials.sh`).

**Securite :** ces identifiants Windows sont publics et uniquement adaptes a un test prive. Garder les ports Codespaces en mode **Private** et definir un mot de passe Windows plus fort avant toute utilisation sensible.

Un Codespace existant avec un fichier `.env` deja cree ou une installation Windows deja effectuee conserve ses anciens identifiants. Changer `.env.example` ne modifie pas automatiquement un compte Windows existant.

## Ce qui change

Le fichier `compose.yaml` configure **Windows 10, 4 vCPU, 4 Go de RAM, disque virtuel QCOW2 de 32 Go, KVM=Y**, avec le périphérique `/dev/kvm`.

**Important : KVM et QCOW2 ne sont pas des alternatives.** KVM est l'accélérateur de la machine virtuelle. QCOW2 est le format de son disque. Les deux sont utilisés simultanément.

**Le nouveau démarrage refuse l'émulation lente** : si le moteur Docker n'a pas accès à KVM, seul **Portainer** est lancé. Il ne sert à rien de reconstruire le Codespace en boucle pour activer KVM : c'est une capacité de l'hôte GitHub, qui ne peut pas être créée par un Dockerfile ou un script.

## Recommandation avant de supprimer l'ancien Codespace

Dans le Codespace existant, essayer d'abord :

```bash
cd /workspaces/githubwin10
git pull --ff-only origin main
bash scripts/check-kvm.sh
```

- Si le résultat est **OK : Docker peut accéder au périphérique KVM**, Windows peut être essayé avec accélération.
- Si le résultat est **ERREUR : /dev/kvm n'est pas accessible**, ne supprimez pas l'ancienne machine en pensant qu'une nouvelle Codespace aura nécessairement KVM. Utilisez plutôt un hôte Linux KVM ou un serveur qui autorise la virtualisation imbriquée.

Ce test vérifie la disponibilité du périphérique Docker mais **ne garantit pas à lui seul** que Windows terminera son installation.

## Nouveau Codespace créé depuis ce dépôt

1. Ouvrir https://github.com/ELMRABET-Abdelali/githubwin10
2. **Code → Codespaces → Create codespace on main**
3. Le démarrage automatique génère le mot de passe initial de Portainer et démarre **Portainer sur 9000**. Windows sur **8006** ne démarre automatiquement **que si KVM est utilisable par Docker**.
4. Dans le terminal :

```bash
bash scripts/check-kvm.sh
bash scripts/show-credentials.sh
docker compose ps -a
```

Les ports doivent rester en visibilité **Private** dans l'onglet Ports.

## Codespace existant avec Docker

```bash
cd /workspaces
git clone https://github.com/ELMRABET-Abdelali/githubwin10.git
cd githubwin10
bash scripts/bootstrap.sh
bash scripts/show-credentials.sh
```

Le moteur Docker et Docker Compose doivent être installés et accessibles dans ce Codespace. La commande bootstrap ne peut pas créer KVM.

## Démarrage manuel sur un hôte avec KVM

```bash
cd /workspaces/githubwin10
bash scripts/check-kvm.sh
bash scripts/bootstrap.sh
docker compose ps
```

Le script `scripts/bootstrap.sh` :
- Génère les mots de passe (si absents) sans les publier sur GitHub.
- Démarre Portainer sur 9000.
- Teste KVM dans le moteur Docker.
- Démarre Windows sur 8006 **seulement si le test KVM réussit**.
- Ne supprime aucun disque ni volume Docker.

Identifiant initial Portainer : `admin`. Le compte Windows est celui de la variable `WINDOWS_USERNAME` dans `.env`, par défaut `win10`. Pour lire les mots de passe locaux :

```bash
bash scripts/show-credentials.sh
```

**Ne partagez jamais la sortie de cette commande.** Si un compte Portainer existait déjà, l'ancien mot de passe est conservé.

## Diagnostic

```bash
bash scripts/check-kvm.sh
docker compose ps -a
docker logs --tail=100 githubwin10-windows
docker logs --tail=100 githubwin10-portainer
df -h
docker system df
```

Dans Codespaces, Windows 10 avec un disque virtuel de 32 Go sur un volume hôte de 32 Go est très contraint : Linux, Docker et l'image d'installation utilisent aussi de l'espace. Le projet dockur/windows recommande au moins **32 Go libres sur l'hôte**, qui ne sont pas disponibles dans un Codespace totalisant seulement 32 Go après installation de Linux et Docker.

Si un Windows existant boucle sur une erreur d'installation, **rebuild Codespaces ne remet pas son disque à zéro**. Ne lancez pas `docker compose down -v` ni `docker volume prune` sans sauvegarde. Un nouveau Codespace possède ses propres volumes.

### Erreur Windows « L'ordinateur a redémarré de manière inattendue »

Dans l'interface Windows 8006, appuyer sur **Maj + F10** pendant le message d'erreur, puis exécuter cette commande **dans Windows CMD** (pas Linux) :

```cmd
reg add "HKLM\SYSTEM\Setup\Status\ChildCompletion" /v setup.exe /t REG_DWORD /d 3 /f
```

Fermer la console, cliquer OK, puis vérifier que l'installation continue. C'est un contournement limité, pas une garantie si KVM ou l'espace disque sont insuffisants.

## Références

- https://github.com/dockur/windows
- https://docs.github.com/en/codespaces
- https://docs.portainer.io/start/install-ce/server/docker/linux

Windows 10 a dépassé sa fin de support standard ; une licence appropriée reste nécessaire.
