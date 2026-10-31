# GitHubWin10 — Windows 10 et Portainer automatiques

Guide étudiant : https://githubwin10-etudiants.vercel.app/

Après la création ou la reconstruction d'un GitHub Codespace, **postStartCommand** exécute `scripts/bootstrap.sh` automatiquement. Il génère **sur la machine** un mot de passe Windows et un mot de passe initial pour Portainer, puis lance les deux conteneurs sans intervention.

## Procédure

1. Ouvrir le dépôt : https://github.com/ELMRABET-Abdelali/githubwin10
2. **Code → Codespaces → Create codespace on main** (ou **Rebuild Container** si le Codespace existe).
3. Dans le terminal, exécuter : `bash scripts/show-credentials.sh` pour lire les identifiants privés.
4. Dans **Ports**, ouvrir **9000** pour Portainer et **8006** pour Windows. Garder **Private**.
5. Si l'initialisation automatique ne s'est pas achevée : `bash scripts/bootstrap.sh`.

> Le mot de passe Portainer est utilisé lors de la **création initiale** du compte admin uniquement. Si le volume Portainer contient déjà un compte, le mot de passe précédent reste valide. Le rebuild ne supprime ni ne réinitialise les volumes. Les mots de passe ne doivent **jamais** être partagés ou ajoutés à GitHub.

### Diagnostic

```bash
docker compose ps -a
docker logs --tail=100 githubwin10-windows
docker logs --tail=100 githubwin10-portainer
curl -I http://127.0.0.1:8006
df -h
docker system df
```

### Limites à connaître

- Windows utilise l'image `dockurr/windows:latest`, version 10, 4 vCPU, RAM 4 Go, disque virtuel QCOW2 de 32 Go.
- Un Codespace de **32 Go au total** peut manquer de place pour l'ISO, Docker et l'installation Windows, même si QCOW2 alloue le disque progressivement.
- Sans `/dev/kvm`, démarrage automatique en émulation QEMU **très lente** : l'interface 8006 peut apparaître alors que Windows ne peut pas démarrer correctement. Aucun code ne peut rendre KVM disponible si GitHub ne le fournit pas.
- Les ports exposés par Docker doivent rester **Private dans Codespaces**, et jamais être publiés à des utilisateurs non autorisés.
- Windows 10 est hors support standard, une licence Windows reste nécessaire.

### Initialisation ou dépannage manuel

```bash
bash scripts/bootstrap.sh
bash scripts/show-credentials.sh
docker compose restart portainer
docker compose restart windows
```

Pour un compte Portainer déjà créé, utiliser l'outil officiel de réinitialisation de Portainer après avoir stoppé le conteneur et sauvegardé son volume, pas la commande d'initialisation.
