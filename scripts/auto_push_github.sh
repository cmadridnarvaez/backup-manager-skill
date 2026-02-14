#!/bin/bash
# Auto-push de skills a GitHub
# Ejecutar después de hacer cambios en skills

SKILL_NAME=$1
REPO_DIR="/tmp/backup-manager-skill"
WORKSPACE="$HOME/.openclaw/workspace"

if [ -z "$SKILL_NAME" ]; then
    echo "Uso: $0 <nombre-skill>"
    echo "Ejemplo: $0 backup-manager"
    exit 1
fi

echo "🚀 Auto-push de $SKILL_NAME a GitHub..."

cd "$REPO_DIR" || {
    echo "❌ No se encontró el repositorio en $REPO_DIR"
    exit 1
}

# Verificar si hay cambios
if git diff --quiet && git diff --cached --quiet; then
    echo "✅ No hay cambios para push"
    exit 0
fi

# Agregar cambios
git add -A

# Crear commit con timestamp
COMMIT_MSG="Auto-update: $(date '+%Y-%m-%d %H:%M') - $SKILL_NAME"
git commit -m "$COMMIT_MSG"

# Push
echo "📤 Subiendo a GitHub..."
if git push origin master; then
    echo "✅ Push exitoso: $(git log -1 --oneline)"
else
    echo "❌ Error en push"
    exit 1
fi
