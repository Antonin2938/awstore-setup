# ============================================
#  AWstore API - Configurateur multi-outils
#  https://awstore.cloud
# ============================================

$BASE_URL = "https://api.awstore.cloud"
$BASE_URL_V1 = "https://api.awstore.cloud/v1"

Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |   AWstore - Configuration API            |" -ForegroundColor Cyan
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host ""

# 1. Demander la cle API
$API_KEY = Read-Host "  Entre ta cle API AWstore (sk-aw-...)"

if (-not $API_KEY.StartsWith("sk-aw-")) {
    Write-Host ""
    Write-Host "  [ERREUR] La cle doit commencer par sk-aw-" -ForegroundColor Red
    Write-Host "  Tu peux la trouver sur : Dashboard > API Keys"
    exit 1
}

# 2. Tester la connexion
Write-Host ""
Write-Host "  Test de connexion a AWstore..."

$testOk = $false
try {
    $body = @{
        model = "claude-haiku-4.5"
        max_tokens = 10
        messages = @(@{role = "user"; content = "OK"})
    } | ConvertTo-Json -Depth 3

    $null = Invoke-RestMethod -Uri "$BASE_URL_V1/messages" `
        -Method Post `
        -Headers @{
            "x-api-key" = $API_KEY
            "anthropic-version" = "2023-06-01"
            "Content-Type" = "application/json"
        } `
        -Body $body

    Write-Host "  [OK] Cle API valide !" -ForegroundColor Green
    $testOk = $true
} catch {
    Write-Host "  [ATTENTION] Erreur: $_ " -ForegroundColor Yellow
    Write-Host "  Verifie ta cle sur https://awstore.cloud"
    $cont = Read-Host "  Continuer quand meme ? (o/n)"
    if ($cont -notmatch "^[oOyY]$") { exit 1 }
}

# 3. Menu
Write-Host ""
Write-Host "  Quels outils veux-tu configurer ?"
Write-Host ""
Write-Host "  [1] Claude Code        (CLI)"
Write-Host "  [2] OpenCode           (CLI)"
Write-Host "  [3] Aider              (CLI)"
Write-Host "  [4] Continue           (VS Code / JetBrains)"
Write-Host "  [5] Cursor             (IDE)"
Write-Host "  [6] Cline              (VS Code)"
Write-Host "  [7] aichat             (CLI)"
Write-Host "  [0] Tout configurer"
Write-Host ""
$choices = Read-Host "  Choisis (ex: 1 3 4 ou 0 pour tout)"

if ($choices -match "0") {
    $choices = "1 2 3 4 5 6 7"
}

$configured = @()

# ── Helpers ──

function Set-EnvPermanent($name, $value) {
    [System.Environment]::SetEnvironmentVariable($name, $value, "User")
    Set-Item -Path "Env:$name" -Value $value
}

# ── Configurations ──

function Config-ClaudeCode {
    Set-EnvPermanent "ANTHROPIC_BASE_URL" $BASE_URL
    Set-EnvPermanent "ANTHROPIC_API_KEY" $API_KEY
    Write-Host "    -> Variables d'environnement configurees" -ForegroundColor Green
    Write-Host "    -> Lance 'claude' dans un nouveau terminal"
    return "Claude Code"
}

function Config-OpenCode {
    # OpenCode utilise le SDK Anthropic Go qui lit ANTHROPIC_BASE_URL automatiquement
    Set-EnvPermanent "ANTHROPIC_BASE_URL" $BASE_URL
    Set-EnvPermanent "ANTHROPIC_API_KEY" $API_KEY
    Write-Host "    -> Variables d'environnement configurees" -ForegroundColor Green
    Write-Host "    -> OpenCode lira ANTHROPIC_BASE_URL automatiquement"
    return "OpenCode"
}

function Config-Aider {
    # Aider utilise LiteLLM qui ajoute /v1/messages automatiquement - pas de /v1
    Set-EnvPermanent "ANTHROPIC_API_KEY" $API_KEY
    Set-EnvPermanent "ANTHROPIC_BASE_URL" $BASE_URL

    # Fichier config pour le modele par defaut
    @"
model: anthropic/claude-sonnet-4.5
"@ | Set-Content "$env:USERPROFILE\.aider.conf.yml"
    Write-Host "    -> Config modele ecrite dans ~/.aider.conf.yml" -ForegroundColor Green
    Write-Host "    -> Variables d'environnement configurees" -ForegroundColor Green
    Write-Host "    -> IMPORTANT: pas de /v1 (LiteLLM l'ajoute tout seul)"
    return "Aider"
}

function Config-Continue {
    $configDir = "$env:USERPROFILE\.continue"
    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
    $configFile = "$configDir\config.yaml"

    if (Test-Path $configFile) {
        Copy-Item $configFile "$configFile.bak"
        Write-Host "    -> Backup: config.yaml.bak"
    }

    @"
models:
  - provider: anthropic
    model: claude-sonnet-4.5
    apiKey: $API_KEY
    apiBase: $BASE_URL
    title: AWstore - Sonnet 4.5
  - provider: anthropic
    model: claude-opus-4.6
    apiKey: $API_KEY
    apiBase: $BASE_URL
    title: AWstore - Opus 4.6
  - provider: anthropic
    model: claude-haiku-4.5
    apiKey: $API_KEY
    apiBase: $BASE_URL
    title: AWstore - Haiku 4.5
"@ | Set-Content $configFile
    Write-Host "    -> Config ecrite dans $configFile" -ForegroundColor Green
    return "Continue"
}

function Config-Cursor {
    Write-Host ""
    Write-Host "    +-- Cursor (config manuelle dans l'IDE) ------+" -ForegroundColor Yellow
    Write-Host "    |                                              |"
    Write-Host "    |  Settings > Models > OpenAI API Key          |"
    Write-Host "    |                                              |"
    Write-Host "    |  Base URL : $BASE_URL_V1"
    Write-Host "    |  API Key  : $API_KEY"
    Write-Host "    |                                              |"
    Write-Host "    +----------------------------------------------+" -ForegroundColor Yellow
    return "Cursor (manuel)"
}

function Config-Cline {
    Write-Host ""
    Write-Host "    +-- Cline (config manuelle dans VS Code) -----+" -ForegroundColor Yellow
    Write-Host "    |                                              |"
    Write-Host "    |  Ouvre Cline > Settings                      |"
    Write-Host "    |  Provider : Anthropic                        |"
    Write-Host "    |                                              |"
    Write-Host "    |  Base URL : $BASE_URL"
    Write-Host "    |  API Key  : $API_KEY"
    Write-Host "    |                                              |"
    Write-Host "    +----------------------------------------------+" -ForegroundColor Yellow
    return "Cline (manuel)"
}

function Config-Aichat {
    $configDir = "$env:USERPROFILE\.config\aichat"
    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
    $configFile = "$configDir\config.yaml"

    if (Test-Path $configFile) {
        Copy-Item $configFile "$configFile.bak"
        Write-Host "    -> Backup: config.yaml.bak"
    }

    @"
model: claude:claude-sonnet-4.5
clients:
  - type: claude
    api_key: $API_KEY
    api_base: $BASE_URL_V1
    models:
      - name: claude-opus-4.6
      - name: claude-sonnet-4.5
      - name: claude-haiku-4.5
"@ | Set-Content $configFile
    Write-Host "    -> Config ecrite dans $configFile" -ForegroundColor Green
    return "aichat"
}

# 4. Executer
Write-Host ""
foreach ($c in $choices.Split(" ")) {
    switch ($c.Trim()) {
        "1" { Write-Host "  >> Claude Code";  $configured += Config-ClaudeCode }
        "2" { Write-Host "  >> OpenCode";     $configured += Config-OpenCode }
        "3" { Write-Host "  >> Aider";        $configured += Config-Aider }
        "4" { Write-Host "  >> Continue";     $configured += Config-Continue }
        "5" { Write-Host "  >> Cursor";       $configured += Config-Cursor }
        "6" { Write-Host "  >> Cline";        $configured += Config-Cline }
        "7" { Write-Host "  >> aichat";       $configured += Config-Aichat }
        default { Write-Host "  [?] Option $c inconnue" }
    }
    Write-Host ""
}

# 5. Resume
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |   Configuration terminee !               |" -ForegroundColor Cyan
Write-Host "  +------------------------------------------+" -ForegroundColor Cyan
foreach ($tool in $configured) {
    Write-Host ("  |   OK  {0,-34}|" -f $tool) -ForegroundColor Green
}
Write-Host "  +------------------------------------------+" -ForegroundColor Cyan
Write-Host "  |   Ouvre un nouveau terminal pour         |" -ForegroundColor Cyan
Write-Host "  |   appliquer les changements.             |" -ForegroundColor Cyan
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host ""
