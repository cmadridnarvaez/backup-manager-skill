#!/bin/bash
# Backup Manager - Multi-destination backup script
# Uso: backup.sh [--dest local|s3|remote|all] [--retention N] [--verbose]

set -euo pipefail

# Configuración default
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="${SKILL_DIR}/config/backup.conf"

# Defaults
DEST="local"
RETENTION=""
VERBOSE=false
DRY_RUN=false

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --dest)
            DEST="$2"
            shift 2
            ;;
        --retention)
            RETENTION="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Uso: backup.sh [--dest local|s3|remote|all] [--retention N] [--verbose] [--dry-run]"
            exit 0
            ;;
        *)
            log_error "Opción desconocida: $1"
            exit 1
            ;;
    esac
done

# Cargar configuración
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    $VERBOSE && log_info "Configuración cargada desde $CONFIG_FILE"
else
    log_warn "No se encontró $CONFIG_FILE, usando defaults"
    # Defaults mínimos
    WORKSPACE_DIR="/home/cmadrid/.openclaw/workspace"
    BACKUP_FILES="SOUL.md MEMORY.md TOOLS.md AGENTS.md USER.md IDENTITY.md"
    RETENTION_COUNT=50
    LOCAL_ENABLED=true
    LOCAL_BACKUP_DIR="$WORKSPACE_DIR/backups/memory"
fi

# Aplicar retención desde argumento si se proporcionó
[[ -n "$RETENTION" ]] && RETENTION_COUNT="$RETENTION"

TIMESTAMP=$(date +%Y%m%d_%H%M)
log_info "Iniciando backup - Timestamp: $TIMESTAMP"
log_info "Destino: $DEST"

# ============================================
# Funciones de backup
# ============================================

backup_local() {
    if [[ "$LOCAL_ENABLED" != "true" ]]; then
        log_warn "Backup local deshabilitado en configuración"
        return 0
    fi

    log_info "Backup LOCAL → $LOCAL_BACKUP_DIR"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY-RUN] Crearía directorio: $LOCAL_BACKUP_DIR"
        return 0
    fi

    mkdir -p "$LOCAL_BACKUP_DIR"
    
    local backed=0
    local failed=0
    
    for file in $BACKUP_FILES; do
        local src="$WORKSPACE_DIR/$file"
        if [[ -f "$src" ]]; then
            local dest="$LOCAL_BACKUP_DIR/${file%.md}_$TIMESTAMP.md"
            if cp "$src" "$dest" 2>/dev/null; then
                ((backed++))
                $VERBOSE && log_ok "Copiado: $file"
            else
                ((failed++))
                log_error "Falló copia: $file"
            fi
        else
            $VERBOSE && log_warn "No encontrado: $src"
        fi
    done
    
    # Backup de archivos de memory/ diarios
    if [[ -d "$WORKSPACE_DIR/memory" ]]; then
        for memfile in "$WORKSPACE_DIR"/memory/*.md; do
            [[ -f "$memfile" ]] || continue
            local basename=$(basename "$memfile")
            cp "$memfile" "$LOCAL_BACKUP_DIR/${basename%.md}_$TIMESTAMP.md" 2>/dev/null && ((backed++))
        done
    fi
    
    # Limpiar backups antiguos
    if [[ "$RETENTION_COUNT" -gt 0 ]]; then
        local total_files
        total_files=$(ls -1 "$LOCAL_BACKUP_DIR"/*.md 2>/dev/null | wc -l)
        if [[ "$total_files" -gt "$RETENTION_COUNT" ]]; then
            ls -t "$LOCAL_BACKUP_DIR"/*.md | tail -n +$((RETENTION_COUNT + 1)) | while read -r oldfile; do
                rm -f "$oldfile"
                $VERBOSE && log_info "Eliminado backup antiguo: $(basename "$oldfile")"
            done
        fi
    fi
    
    log_ok "Backup local completado: $backed archivos, $failed fallos"
    return $((failed > 0 ? 1 : 0))
}

backup_s3() {
    if [[ "$S3_ENABLED" != "true" ]]; then
        log_warn "Backup S3 deshabilitado en configuración"
        return 0
    fi

    # Verificar AWS CLI
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI no instalado. Instalar: pip install awscli"
        return 1
    fi

    log_info "Backup S3 → s3://$S3_BUCKET/$S3_PREFIX/"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY-RUN] Subiría a: s3://$S3_BUCKET/$S3_PREFIX/$TIMESTAMP/"
        return 0
    fi

    local backed=0
    local failed=0
    
    # Preparar opciones de endpoint para S3 compatible (MinIO, etc.)
    local endpoint_opt=""
    if [[ -n "${S3_ENDPOINT:-}" ]]; then
        endpoint_opt="--endpoint-url=$S3_ENDPOINT"
    fi
    
    for file in $BACKUP_FILES; do
        local src="$WORKSPACE_DIR/$file"
        if [[ -f "$src" ]]; then
            local s3_key="$S3_PREFIX/$TIMESTAMP/$file"
            if aws s3 cp "$src" "s3://$S3_BUCKET/$s3_key" $endpoint_opt --quiet 2>/dev/null; then
                ((backed++))
                $VERBOSE && log_ok "Subido a S3: $file"
            else
                ((failed++))
                log_error "Falló subida S3: $file"
            fi
        fi
    done
    
    # Subir también archivos de memory/
    if [[ -d "$WORKSPACE_DIR/memory" ]]; then
        for memfile in "$WORKSPACE_DIR"/memory/*.md; do
            [[ -f "$memfile" ]] || continue
            local basename=$(basename "$memfile")
            aws s3 cp "$memfile" "s3://$S3_BUCKET/$S3_PREFIX/$TIMESTAMP/memory/$basename" $endpoint_opt --quiet 2>/dev/null && ((backed++))
        done
    fi
    
    # Lifecycle policy - mantener solo últimos N días (si está configurado)
    if [[ "${S3_CLEANUP_OLD:-false}" == "true" && -n "${S3_RETENTION_DAYS:-}" ]]; then
        log_info "Limpiando backups S3 antiguos (>$S3_RETENTION_DAYS días)..."
        # Listar y eliminar objetos antiguos
        aws s3api list-objects-v2 --bucket "$S3_BUCKET" --prefix "$S3_PREFIX/" \
            --query "Contents[?LastModified<='$(date -d "-$S3_RETENTION_DAYS days" +%Y-%m-%d)'].Key" \
            --output text $endpoint_opt 2>/dev/null | \
            while read -r key; do
                [[ -n "$key" ]] && aws s3 rm "s3://$S3_BUCKET/$key" $endpoint_opt --quiet
            done
    fi
    
    log_ok "Backup S3 completado: $backed archivos, $failed fallos"
    return $((failed > 0 ? 1 : 0))
}

backup_remote() {
    if [[ "$REMOTE_ENABLED" != "true" ]]; then
        log_warn "Backup remoto deshabilitado en configuración"
        return 0
    fi

    # Verificar rsync y ssh
    if ! command -v rsync &> /dev/null; then
        log_error "rsync no instalado"
        return 1
    fi

    log_info "Backup REMOTE → $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY-RUN] Sincronizaría vía rsync+ssh"
        return 0
    fi

    # Preparar directorio temporal para sincronización
    local tmpdir
    tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" EXIT
    
    # Copiar archivos a temp
    for file in $BACKUP_FILES; do
        local src="$WORKSPACE_DIR/$file"
        [[ -f "$src" ]] && cp "$src" "$tmpdir/"
    done
    
    # Copiar memory/
    if [[ -d "$WORKSPACE_DIR/memory" ]]; then
        mkdir -p "$tmpdir/memory"
        cp "$WORKSPACE_DIR"/memory/*.md "$tmpdir/memory/" 2>/dev/null || true
    fi
    
    # Sincronizar vía rsync
    local remote_dest="$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/$TIMESTAMP/"
    local ssh_opts="-i $REMOTE_SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    
    if rsync -avz -e "ssh $ssh_opts" "$tmpdir/" "$remote_dest" 2>/dev/null; then
        log_ok "Backup remoto completado"
    else
        log_error "Falló backup remoto"
        return 1
    fi
    
    # Limpiar backups antiguos en servidor remoto
    if [[ "$RETENTION_COUNT" -gt 0 ]]; then
        ssh $ssh_opts "$REMOTE_USER@$REMOTE_HOST" \
            "cd $REMOTE_PATH && ls -t | tail -n +$((RETENTION_COUNT + 1)) | xargs -r rm -rf" 2>/dev/null || true
    fi
    
    return 0
}

# ============================================
# Ejecución principal
# ============================================

ERRORS=0

case "$DEST" in
    local)
        backup_local || ((ERRORS++))
        ;;
    s3)
        backup_s3 || ((ERRORS++))
        ;;
    remote)
        backup_remote || ((ERRORS++))
        ;;
    all)
        log_info "Ejecutando backup en TODOS los destinos habilitados"
        backup_local || ((ERRORS++))
        backup_s3 || ((ERRORS++))
        backup_remote || ((ERRORS++))
        ;;
    *)
        log_error "Destino desconocido: $DEST"
        exit 1
        ;;
esac

if [[ "$ERRORS" -eq 0 ]]; then
    log_ok "Backup completado exitosamente"
    exit 0
else
    log_error "Backup completado con $ERRORS errores"
    exit 1
fi
