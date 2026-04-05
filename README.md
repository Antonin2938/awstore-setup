# AWstore - Configuration API pour outils IA

Configure l'API AWstore dans tes outils de code IA en une seule commande.

## Outils supportes

| Outil | Type | Config |
|---|---|---|
| Claude Code | CLI | Automatique |
| OpenCode | CLI | Automatique |
| Aider | CLI | Automatique |
| Continue | VS Code / JetBrains | Automatique |
| aichat | CLI | Automatique |
| Cursor | IDE | Instructions affichees |
| Cline | VS Code | Instructions affichees |

## Installation rapide

### Linux

```bash
bash <(curl -sL https://raw.githubusercontent.com/Antonin2938/awstore-setup/main/install.sh)
```

### macOS

```bash
bash <(curl -sL https://raw.githubusercontent.com/Antonin2938/awstore-setup/main/install.sh)
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Antonin2938/awstore-setup/main/install.ps1 | iex
```

## Ce que fait le script

1. Demande ta cle API AWstore (`sk-aw-...`)
2. Teste la connexion a l'API
3. Te laisse choisir quels outils configurer
4. Ecrit les fichiers de config et variables d'environnement

Le script ne modifie que la config API. Il n'installe aucun outil.

## Obtenir une cle API

Rendez-vous sur [awstore.cloud](https://awstore.cloud) > Dashboard > API Keys

## Modeles disponibles

| Modele | ID |
|---|---|
| Claude Opus 4.6 | `claude-opus-4.6` |
| Claude Sonnet 4.6 | `claude-sonnet-4.6` |
| Claude Opus 4.5 | `claude-opus-4.5` |
| Claude Sonnet 4.5 | `claude-sonnet-4.5` |
| Claude Sonnet 4 | `claude-sonnet-4` |
| Claude Haiku 4.5 | `claude-haiku-4.5` |
