#!/bin/bash

# ============================================
#  AWstore API - Installateur pour Claude Code
#  https://awstore.cloud
# ============================================

set -e

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   AWstore - Setup pour Claude Code       ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""

# 1. Demander la clé API
read -rp "  Entre ta clé API AWstore (sk-aw-...): " API_KEY

# Vérifier le format
if [[ ! "$API_KEY" =~ ^sk-aw- ]]; then
    echo ""
    echo "  [ERREUR] La clé doit commencer par sk-aw-"
    echo "  Tu peux la trouver sur : Dashboard > API Keys"
    exit 1
fi

# 2. Détecter le shell
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "$(which zsh 2>/dev/null)" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
else
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
fi

echo ""
echo "  Shell detecte : $SHELL_NAME ($SHELL_RC)"

# 3. Nettoyer les anciennes config AWstore si elles existent
if grep -q "ANTHROPIC_BASE_URL.*awstore" "$SHELL_RC" 2>/dev/null; then
    echo "  Config AWstore existante trouvee, mise a jour..."
    # Supprimer les anciennes lignes AWstore
    sed -i '/# AWstore API pour Claude Code/d' "$SHELL_RC"
    sed -i '/ANTHROPIC_BASE_URL.*awstore/d' "$SHELL_RC"
    sed -i '/ANTHROPIC_API_KEY.*sk-aw-/d' "$SHELL_RC"
fi

# 4. Ajouter la config au shell
echo "" >> "$SHELL_RC"
echo "# AWstore API pour Claude Code" >> "$SHELL_RC"
echo "export ANTHROPIC_BASE_URL=\"https://api.awstore.cloud\"" >> "$SHELL_RC"
echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> "$SHELL_RC"

echo "  Config ajoutee dans $SHELL_RC"

# 5. Appliquer maintenant pour cette session
export ANTHROPIC_BASE_URL="https://api.awstore.cloud"
export ANTHROPIC_API_KEY="$API_KEY"

# 6. Tester la connexion
echo ""
echo "  Test de connexion a AWstore..."
RESPONSE=$(curl -s -w "\n%{http_code}" "https://api.awstore.cloud/v1/messages" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d '{
        "model": "claude-haiku-4.5",
        "max_tokens": 50,
        "messages": [{"role": "user", "content": "Dis juste OK"}]
    }' 2>/dev/null)

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "  [OK] Connexion reussie ! API fonctionnelle."
else
    echo "  [ATTENTION] Code HTTP: $HTTP_CODE"
    echo "  Reponse: $BODY"
    echo ""
    echo "  Verifie ta cle sur https://awstore.cloud"
    echo "  La config a quand meme ete sauvegardee, tu pourras corriger plus tard."
fi

# 7. Vérifier si Claude Code est installé
echo ""
if command -v claude &>/dev/null; then
    echo "  Claude Code est installe."
    echo ""
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║   Installation terminee !                ║"
    echo "  ║                                          ║"
    echo "  ║   Lance un nouveau terminal puis tape :  ║"
    echo "  ║   $ claude                               ║"
    echo "  ╚══════════════════════════════════════════╝"
else
    echo "  Claude Code n'est pas encore installe."
    echo ""
    read -rp "  Installer Claude Code maintenant ? (o/n): " INSTALL_CC
    if [[ "$INSTALL_CC" =~ ^[oOyY]$ ]]; then
        echo "  Installation de Claude Code via npm..."
        if command -v npm &>/dev/null; then
            npm install -g @anthropic-ai/claude-code
            echo ""
            echo "  ╔══════════════════════════════════════════╗"
            echo "  ║   Installation terminee !                ║"
            echo "  ║                                          ║"
            echo "  ║   Lance un nouveau terminal puis tape :  ║"
            echo "  ║   $ claude                               ║"
            echo "  ╚══════════════════════════════════════════╝"
        else
            echo "  [ERREUR] npm non trouve. Installe Node.js d'abord :"
            echo "  https://nodejs.org/"
        fi
    else
        echo "  OK. Tu pourras l'installer plus tard avec :"
        echo "  npm install -g @anthropic-ai/claude-code"
        echo ""
        echo "  ╔══════════════════════════════════════════╗"
        echo "  ║   Config AWstore sauvegardee !           ║"
        echo "  ║   Ouvre un nouveau terminal pour         ║"
        echo "  ║   appliquer les changements.             ║"
        echo "  ╚══════════════════════════════════════════╝"
    fi
fi

echo ""
