#!/bin/bash
# Backup Inteligente con Lobster - Solo ejecuta si hay cambios
# Compara hash de archivos antes de hacer backup

WORKSPACE="$HOME/.openclaw/workspace"
BACKUP_DIR="$WORKSPACE/backups/memory"
STATE_DIR="$WORKSPACE/.backup-state"
TIMESTAMP=$(date +%Y%m%d_%H%M)
LOG_FILE="$WORKSPACE/logs/lobster_backup.log"

# Archivos críticos a monitorear
FILES=(
    "$WORKSPACE/memory/2026-02-14.md"
    "$WORKSPACE/MEMORY.md"
    "$WORKSPACE/TOOLS.md"
    "$WORKSPACE/SOUL.md"
    "$WORKSPACE/USER.md"
    "$WORKSPACE/IDENTITY.md"
)

mkdir -p "$BACKUP_DIR"
mkdir -p "$STATE_DIR"
mkdir -p "$WORKSPACE/logs"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Iniciando backup inteligente..." | tee -a "$LOG_FILE"

# Función para calcular hash
get_hash() {
    if [ -f "$1" ]; then
        md5sum "$1" | awk '{print $1}'
    else
        echo "NULL"
    fi
}

# Verificar si hay cambios
CHANGES_DETECTED=false
CHANGED_FILES=""

for file in "${FILES[@]}"; do
    filename=$(basename "$file")
    state_file="$STATE_DIR/${filename}.hash"
    
    current_hash=$(get_hash "$file")
    
    if [ -f "$state_file" ]; then
        previous_hash=$(cat "$state_file")
    else
        previous_hash="NULL"
    fi
    
    if [ "$current_hash" != "$previous_hash" ]; then
        CHANGES_DETECTED=true
        CHANGED_FILES="$CHANGED_FILES $filename"
        echo "$current_hash" > "$state_file"
        echo "  📝 Cambio detectado: $filename" | tee -a "$LOG_FILE"
    fi
done

if [ "$CHANGES_DETECTED" = false ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ✅ Sin cambios. Backup omitido." | tee -a "$LOG_FILE"
    echo '{"status": "skipped", "reason": "no_changes", "timestamp": "'$(date -Iseconds)'"}' > "$STATE_DIR/last_backup.json"
    exit 0
fi

# Ejecutar backup
echo "$(date '+%Y-%m-%d %H:%M:%S') - 💾 Ejecutando backup de archivos modificados..." | tee -a "$LOG_FILE"

BACKUP_COUNT=0
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .md)
        cp "$file" "$BACKUP_DIR/${filename}_${TIMESTAMP}.md"
        ((BACKUP_COUNT++))
    fi
done

# Rotación: mantener solo últimos 50 backups por archivo
for file in "$BACKUP_DIR"/*.md; do
    if [ -f "$file" ]; then
        # Mantener solo los 50 más recientes
        ls -t "$BACKUP_DIR"/$(basename "$file" | cut -d'_' -f1)*.md 2>/dev/null | tail -n +51 | xargs -r rm -f
    fi
done

echo "$(date '+%Y-%m-%d %H:%M:%S') - ✅ Backup completado. Archivos respaldados: $BACKUP_COUNT" | tee -a "$LOG_FILE"
echo '{"status": "success", "files_backed_up": '$BACKUP_COUNT', "changed_files": "'$CHANGED_FILES'", "timestamp": "'$(date -Iseconds)'", "backup_id": "'$TIMESTAMP'"}' > "$STATE_DIR/last_backup.json"

# Guardar resumen para Lobster
echo "$TIMESTAMP|$BACKUP_COUNT|$CHANGED_FILES" > "$STATE_DIR/last_run.txt"
