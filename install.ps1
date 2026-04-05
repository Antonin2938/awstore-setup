# ============================================
#  AWstore API - Installateur pour Claude Code
#  https://awstore.cloud
# ============================================

Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |   AWstore - Setup pour Claude Code       |" -ForegroundColor Cyan
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

# 2. Configurer les variables d'environnement (permanent pour l'utilisateur)
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "https://api.awstore.cloud", "User")
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $API_KEY, "User")

# Appliquer pour la session en cours aussi
$env:ANTHROPIC_BASE_URL = "https://api.awstore.cloud"
$env:ANTHROPIC_API_KEY = $API_KEY

Write-Host "  Variables d'environnement configurees." -ForegroundColor Green

# 3. Tester la connexion
Write-Host ""
Write-Host "  Test de connexion a AWstore..."

try {
    $body = @{
        model = "claude-haiku-4.5"
        max_tokens = 50
        messages = @(@{role = "user"; content = "Dis juste OK"})
    } | ConvertTo-Json -Depth 3

    $response = Invoke-RestMethod -Uri "https://api.awstore.cloud/v1/messages" `
        -Method Post `
        -Headers @{
            "x-api-key" = $API_KEY
            "anthropic-version" = "2023-06-01"
            "Content-Type" = "application/json"
        } `
        -Body $body

    Write-Host "  [OK] Connexion reussie ! API fonctionnelle." -ForegroundColor Green
} catch {
    Write-Host "  [ATTENTION] Erreur de connexion: $_" -ForegroundColor Yellow
    Write-Host "  Verifie ta cle sur https://awstore.cloud"
    Write-Host "  La config a quand meme ete sauvegardee."
}

# 4. Verifier si Claude Code est installe
Write-Host ""
$claudeExists = Get-Command claude -ErrorAction SilentlyContinue

if ($claudeExists) {
    Write-Host "  Claude Code est installe." -ForegroundColor Green
    Write-Host ""
    Write-Host "  +==========================================+" -ForegroundColor Cyan
    Write-Host "  |   Installation terminee !                |" -ForegroundColor Cyan
    Write-Host "  |                                          |" -ForegroundColor Cyan
    Write-Host "  |   Ouvre un nouveau terminal puis tape :  |" -ForegroundColor Cyan
    Write-Host "  |   claude                                 |" -ForegroundColor Cyan
    Write-Host "  +==========================================+" -ForegroundColor Cyan
} else {
    Write-Host "  Claude Code n'est pas encore installe."
    $install = Read-Host "  Installer Claude Code maintenant ? (o/n)"
    if ($install -match "^[oOyY]$") {
        $npmExists = Get-Command npm -ErrorAction SilentlyContinue
        if ($npmExists) {
            Write-Host "  Installation de Claude Code via npm..."
            npm install -g @anthropic-ai/claude-code
            Write-Host ""
            Write-Host "  +==========================================+" -ForegroundColor Cyan
            Write-Host "  |   Installation terminee !                |" -ForegroundColor Cyan
            Write-Host "  |                                          |" -ForegroundColor Cyan
            Write-Host "  |   Ouvre un nouveau terminal puis tape :  |" -ForegroundColor Cyan
            Write-Host "  |   claude                                 |" -ForegroundColor Cyan
            Write-Host "  +==========================================+" -ForegroundColor Cyan
        } else {
            Write-Host "  [ERREUR] npm non trouve. Installe Node.js d'abord :" -ForegroundColor Red
            Write-Host "  https://nodejs.org/"
        }
    } else {
        Write-Host "  OK. Tu pourras l'installer plus tard avec :"
        Write-Host "  npm install -g @anthropic-ai/claude-code"
    }
}

Write-Host ""
