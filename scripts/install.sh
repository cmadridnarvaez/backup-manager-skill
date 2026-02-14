#!/bin/bash
# Backup Manager - Script de instalación

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
WORKSPACE_DIR="/home/cmadrid/.openclaw/workspace"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Backup Manager - Instalador${NC}"
echo "================================"

# Verificar workspace
if [[ ! -d "$WORKSPACE_DIR" ]]; then
    echo -e "${RED}ERROR: No se encontró workspace en $WORKSPACE_DIR${NC}"
    exit 1
fi

# Copiar configuración de ejemplo si no existe
CONFIG_DEST="$SKILL_DIR/config/backup.conf"
if [[ ! -f "$CONFIG_DEST" ]]; then
    echo -e "${BLUE}📄 Creando archivo de configuración...${NC}"
    cp "$SKILL_DIR/config/backup.conf.example" "$CONFIG_DEST"
    echo -e "${GREEN}✅ Configuración creada en:${NC} $CONFIG_DEST"
    echo -e "${YELLOW}⚠️  Edita este archivo para configurar S3, remoto, etc.${NC}"
else
    echo -e "${YELLOW}⚠️  Configuración ya existe, preservando...${NC}"
fi

# Crear directorio de backup local por defecto
LOCAL_BACKUP_DIR="$WORKSPACE_DIR/backups/memory"
mkdir -p "$LOCAL_BACKUP_DIR"
echo -e "${GREEN}✅ Directorio de backup local:${NC} $LOCAL_BACKUP_DIR"

# Registrar en TOOLS.md si no está presente
TOOLS_MD="$WORKSPACE_DIR/TOOLS.md"
if [[ -f "$TOOLS_MD" ]]; then
    if ! grep -q "backup-manager" "$TOOLS_MD"; then
        echo "" >> "$TOOLS_MD"
        echo "### Backup Manager (Skill)" >> "$TOOLS_MD"
        echo "" >> "$TOOLS_MD"
        echo "Skill para backups multi-destino (local, S3, remoto)." >> "$TOOLS_MD"
        echo "" >> "$TOOLS_MD"
        echo "**Comandos:**" >> "$TOOLS_MD"
        echo "\`\`\`bash" >> "$TOOLS_MD"
        echo "# Backup local" >> "$TOOLS_MD"
        echo "bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh" >> "$TOOLS_MD"
        echo "" >> "$TOOLS_MD"
        echo "# Backup a S3" >> "$TOOLS_MD"
        echo "bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest s3" >> "$TOOLS_MD"
        echo "" >> "$TOOLS_MD"
        echo "# Backup remoto" >> "$TOOLS_MD"
        echo "bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest remote" >> "$TOOLS_MD"
        echo "\`\`\`" >> "$TOOLS_MD"
        echo "" >> "$TOOLS_MD"
        echo "**Configuración:** \`config/backup.conf\`" >> "$TOOLS_MD"
        echo "" >> "$TOOLS_MD"
        echo "---" >> "$TOOLS_MD"
        echo -e "${GREEN}✅ Registrado en TOOLS.md${NC}"
    fi
fi

# Registrar en AGENTS.md si existe
AGENTS_MD="$WORKSPACE_DIR/AGENTS.md"
if [[ -f "$AGENTS_MD" ]]; then
    if ! grep -q "backup-manager" "$AGENTS_MD"; then
        echo "" >> "$AGENTS_MD"
        echo "- **backup-manager**: Skill de backups multi-destino v1.0.0" >> "$AGENTS_MD"
        echo -e "${GREEN}✅ Registrado en AGENTS.md${NC}"
    fi
fi

# Probar backup inicial
echo ""
echo -e "${BLUE}🧪 Probando backup inicial (dry-run)...${NC}"
if bash "$SKILL_DIR/scripts/backup.sh" --dest local --dry-run --verbose; then
    echo -e "${GREEN}✅ Prueba exitosa${NC}"
else
    echo -e "${YELLOW}⚠️  Prueba falló - revisa configuración${NC}"
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✅ Backup Manager instalado${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Edita la configuración:"
echo "     nano $CONFIG_DEST"
echo ""
echo "  2. Configura S3 (opcional):"
echo "     aws configure"
echo ""
echo "  3. Configura backup remoto (opcional):"
echo "     ssh-keygen -f ~/.ssh/id_rsa_backup"
echo "     ssh-copy-id -i ~/.ssh/id_rsa_backup backup@tuservidor.com"
echo ""
echo "  4. Ejecuta tu primer backup:"
echo "     bash $SKILL_DIR/scripts/backup.sh"
echo ""
