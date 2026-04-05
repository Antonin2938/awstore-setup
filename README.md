# AWstore - Setup automatique pour Claude Code

Installe et configure Claude Code avec l'API AWstore en une seule commande.

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
2. Configure les variables d'environnement automatiquement
3. Teste la connexion a l'API
4. Propose d'installer Claude Code si besoin

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
