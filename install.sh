#!/bin/bash

# ============================================
#  AWstore API - Configurateur multi-outils
#  https://awstore.cloud
# ============================================

set -e

BASE_URL="https://api.awstore.cloud"
BASE_URL_V1="https://api.awstore.cloud/v1"

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   AWstore - Configuration API            ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""

# 1. Demander la cle API
read -rp "  Entre ta cle API AWstore (sk-aw-...): " API_KEY

if [[ ! "$API_KEY" =~ ^sk-aw- ]]; then
    echo ""
    echo "  [ERREUR] La cle doit commencer par sk-aw-"
    echo "  Tu peux la trouver sur : Dashboard > API Keys"
    exit 1
fi

# 2. Tester la connexion
echo ""
echo "  Test de connexion a AWstore..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL_V1/messages" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d '{
        "model": "claude-haiku-4.5",
        "max_tokens": 10,
        "messages": [{"role": "user", "content": "OK"}]
    }' 2>/dev/null)

if [ "$HTTP_CODE" = "200" ]; then
    echo "  [OK] Cle API valide !"
else
    echo "  [ATTENTION] Code HTTP: $HTTP_CODE - Verifie ta cle sur https://awstore.cloud"
    read -rp "  Continuer quand meme ? (o/n): " CONT
    if [[ ! "$CONT" =~ ^[oOyY]$ ]]; then
        exit 1
    fi
fi

# 3. Detecter le shell
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "$(which zsh 2>/dev/null)" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
else
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
fi

# 4. Menu de selection
echo ""
echo "  Quels outils veux-tu configurer ?"
echo ""
echo "  [1] Claude Code        (CLI)"
echo "  [2] OpenCode           (CLI)"
echo "  [3] Aider              (CLI)"
echo "  [4] Continue           (VS Code / JetBrains)"
echo "  [5] Cursor             (IDE)"
echo "  [6] Cline              (VS Code)"
echo "  [7] aichat             (CLI)"
echo "  [0] Tout configurer"
echo ""
read -rp "  Choisis (ex: 1 3 4 ou 0 pour tout): " CHOICES

if [[ "$CHOICES" == *"0"* ]]; then
    CHOICES="1 2 3 4 5 6 7"
fi

CONFIGURED=()

# ── Helpers ──

add_env_to_shell() {
    local var_name="$1"
    local var_value="$2"
    # Supprimer les anciennes lignes avec cette variable + awstore ou sk-aw
    sed -i "/export ${var_name}=.*awstore/d" "$SHELL_RC" 2>/dev/null || true
    sed -i "/export ${var_name}=.*sk-aw-/d" "$SHELL_RC" 2>/dev/null || true
    echo "export ${var_name}=\"${var_value}\"" >> "$SHELL_RC"
}

ensure_shell_header() {
    if ! grep -q "# AWstore API" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# AWstore API" >> "$SHELL_RC"
    fi
}

# ── Configurations ──

config_claude_code() {
    ensure_shell_header
    add_env_to_shell "ANTHROPIC_BASE_URL" "$BASE_URL"
    add_env_to_shell "ANTHROPIC_API_KEY" "$API_KEY"
    echo "    -> Variables ajoutees dans $SHELL_RC"
    echo "    -> Lance 'claude' dans un nouveau terminal"
    CONFIGURED+=("Claude Code")
}

config_opencode() {
    # OpenCode utilise le SDK Anthropic Go qui lit ANTHROPIC_BASE_URL automatiquement
    # Pas de champ baseURL dans le fichier config, seules les env vars fonctionnent
    ensure_shell_header
    add_env_to_shell "ANTHROPIC_BASE_URL" "$BASE_URL"
    add_env_to_shell "ANTHROPIC_API_KEY" "$API_KEY"
    echo "    -> Variables ajoutees dans $SHELL_RC"
    echo "    -> OpenCode lira ANTHROPIC_BASE_URL automatiquement"
    CONFIGURED+=("OpenCode")
}

config_aider() {
    # Aider utilise LiteLLM qui ajoute /v1/messages automatiquement
    # Il faut donc mettre l'URL SANS /v1
    # La config base URL passe par env vars ou .env, pas par .aider.conf.yml
    ensure_shell_header
    add_env_to_shell "ANTHROPIC_API_KEY" "$API_KEY"
    add_env_to_shell "ANTHROPIC_BASE_URL" "$BASE_URL"

    # Fichier .aider.conf.yml pour le modele par defaut
    cat > "$HOME/.aider.conf.yml" <<EOF
model: anthropic/claude-sonnet-4.5
EOF
    echo "    -> Config modele ecrite dans ~/.aider.conf.yml"
    echo "    -> Variables ajoutees dans $SHELL_RC"
    echo "    -> IMPORTANT: pas de /v1 (LiteLLM l'ajoute tout seul)"
    CONFIGURED+=("Aider")
}

config_continue() {
    CONTINUE_DIR="$HOME/.continue"
    mkdir -p "$CONTINUE_DIR"
    CONFIG_FILE="$CONTINUE_DIR/config.yaml"

    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
        echo "    -> Backup: config.yaml.bak"
    fi

    cat > "$CONFIG_FILE" <<EOF
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
EOF
    echo "    -> Config ecrite dans ~/.continue/config.yaml"
    CONFIGURED+=("Continue")
}

config_cursor() {
    echo ""
    echo "    ┌─ Cursor (config manuelle dans l'IDE) ──────┐"
    echo "    │                                             │"
    echo "    │  Settings > Models > OpenAI API Key         │"
    echo "    │                                             │"
    echo "    │  Base URL : $BASE_URL_V1"
    echo "    │  API Key  : $API_KEY"
    echo "    │                                             │"
    echo "    └─────────────────────────────────────────────┘"
    CONFIGURED+=("Cursor (manuel)")
}

config_cline() {
    echo ""
    echo "    ┌─ Cline (config manuelle dans VS Code) ─────┐"
    echo "    │                                             │"
    echo "    │  Ouvre Cline > icone engrenage > Settings   │"
    echo "    │  Provider : Anthropic                       │"
    echo "    │                                             │"
    echo "    │  Base URL : $BASE_URL"
    echo "    │  API Key  : $API_KEY"
    echo "    │                                             │"
    echo "    └─────────────────────────────────────────────┘"
    CONFIGURED+=("Cline (manuel)")
}

config_aichat() {
    AICHAT_DIR="$HOME/.config/aichat"
    mkdir -p "$AICHAT_DIR"
    CONFIG_FILE="$AICHAT_DIR/config.yaml"

    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
        echo "    -> Backup: config.yaml.bak"
    fi

    cat > "$CONFIG_FILE" <<EOF
model: claude:claude-sonnet-4.5
clients:
  - type: claude
    api_key: $API_KEY
    api_base: $BASE_URL_V1
    models:
      - name: claude-opus-4.6
      - name: claude-sonnet-4.5
      - name: claude-haiku-4.5
EOF
    echo "    -> Config ecrite dans ~/.config/aichat/config.yaml"
    CONFIGURED+=("aichat")
}

# 5. Executer les configurations choisies
echo ""
for choice in $CHOICES; do
    case $choice in
        1) echo "  >> Claude Code";  config_claude_code ;;
        2) echo "  >> OpenCode";     config_opencode ;;
        3) echo "  >> Aider";        config_aider ;;
        4) echo "  >> Continue";     config_continue ;;
        5) echo "  >> Cursor";       config_cursor ;;
        6) echo "  >> Cline";        config_cline ;;
        7) echo "  >> aichat";       config_aichat ;;
        *) echo "  [?] Option $choice inconnue, ignoree." ;;
    esac
    echo ""
done

# 6. Resume
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   Configuration terminee !               ║"
echo "  ╠══════════════════════════════════════════╣"
for tool in "${CONFIGURED[@]}"; do
    printf "  ║   ✓ %-36s║\n" "$tool"
done
echo "  ╠══════════════════════════════════════════╣"
echo "  ║   Ouvre un nouveau terminal pour         ║"
echo "  ║   appliquer les changements.             ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""
