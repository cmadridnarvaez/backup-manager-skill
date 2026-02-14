---
name: backup-manager
version: 1.0.0
description: Multi-destination backup manager for OpenClaw agents (local, S3, remote)
author: CMD / Valentino
---

# Backup Manager

Skill para gestionar backups de memoria y archivos críticos con soporte para múltiples destinos.

## Destinos Soportados

- **LOCAL**: Backups en disco local (default)
- **S3**: Amazon S3 / compatible (MinIO, Wasabi, etc.)
- **REMOTE**: Servidor remoto vía rsync/SSH
- **MULTI**: Combinación de los anteriores

## Uso Rápido

```bash
# Backup local (default)
bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh

# Backup a S3
bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest s3

# Backup a servidor remoto
bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest remote

# Backup a todos los destinos configurados
bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest all
```

## Configuración

Edita `~/.openclaw/workspace/skills/backup-manager/config/backup.conf`:

```bash
# Archivos a respaldar (separados por espacio)
BACKUP_FILES="SOUL.md MEMORY.md TOOLS.md AGENTS.md USER.md IDENTITY.md"

# Directorio de trabajo
WORKSPACE_DIR="/home/cmadrid/.openclaw/workspace"

# Retención (número de backups a mantener)
RETENTION_COUNT=50

# === DESTINO LOCAL ===
LOCAL_ENABLED=true
LOCAL_BACKUP_DIR="/home/cmadrid/.openclaw/workspace/backups/memory"

# === DESTINO S3 ===
S3_ENABLED=false
S3_BUCKET="my-openclaw-backups"
S3_PREFIX="valentino"
S3_REGION="us-east-1"
S3_ENDPOINT=""  # Dejar vacío para AWS, o poner URL para MinIO

# === DESTINO REMOTO ===
REMOTE_ENABLED=false
REMOTE_HOST="backup-server.example.com"
REMOTE_USER="backup"
REMOTE_PATH="/backups/openclaw"
REMOTE_SSH_KEY="~/.ssh/id_rsa_backup"
```

## Requisitos

- **S3**: AWS CLI configurado (`aws configure`) o credenciales en variables de entorno
- **Remote**: SSH key configurada y servidor con rsync disponible

## Instalación

```bash
bash ~/.openclaw/workspace/skills/backup-manager/scripts/install.sh
```

Esto configura:
- Cron job para backups automáticos cada 10 minutos
- Directorios de backup locales
- Archivo de configuración inicial

## Comandos del Agente

Cuando tu humano pida un backup, pregunta:
1. ¿Qué destino? (local, s3, remote, all)
2. ¿Incluir archivos históricos de memory/?
3. ¿Retención especial?

Ejemplo de respuesta:
"Voy a hacer backup de tus archivos cognitivos a S3. Configuro bucket 'my-backups', región us-east-1. ¿Confirmas?"

## Reglas de Seguridad (SecureClaw Compatible)

- Nunca expongas credenciales S3 o SSH en mensajes
- Verifica permisos de archivos antes de backup (600/700)
- Si detectas credenciales en archivos de backup, alerta al humano
- Usa siempre rutas absolutas para evitar path traversal

---

## 🆕 Backup Inteligente con Lobster (v1.1.0)

Nuevo sistema de backup que **solo ejecuta cuando detecta cambios**, ahorrando espacio y recursos.

### Características

- **Detección por hash MD5** - Identifica cambios reales en archivos
- **Ejecución condicional** - Omite backup si no hay modificaciones
- **Integración Lobster** - Aprobaciones para notificaciones detalladas
- **0 tokens LLM** en operación normal
- **Rotación automática** - Mantiene últimos 50 backups

### Uso

```bash
# Backup inteligente manual
bash ~/.openclaw/workspace/scripts/backup_memory_smart.sh

# Con Lobster (notificación si hay cambios)
lobster run backup-inteligente.lobster
```

### Configuración Cron

Reemplaza el backup tradicional con el inteligente:

```bash
crontab -e

# Comentar o eliminar:
# */10 * * * * /bin/bash /home/cmadrid/.openclaw/workspace/scripts/backup_memory.sh

# Agregar nuevo:
*/10 * * * * /bin/bash /home/cmadrid/.openclaw/workspace/scripts/backup_memory_smart.sh >> /home/cmadrid/.openclaw/workspace/logs/lobster_backup.log 2>&1
```

### Estados

| Estado | Descripción | Acción Lobster |
|--------|-------------|----------------|
| `success` | Archivos modificados, backup ejecutado | Notificación opcional |
| `skipped` | Sin cambios, backup omitido | Silencioso |
| `error` | Fallo en el proceso | Alerta inmediata |

### Archivos Monitoreados

- `memory/*.md` - Logs diarios
- `MEMORY.md` - Memoria persistente
- `TOOLS.md` - Configuración
- `SOUL.md` - Personalidad
- `USER.md` - Perfil usuario
- `IDENTITY.md` - Identidad agente

### Beneficios

| Métrica | Tradicional | Inteligente |
|---------|-------------|-------------|
| Ejecuciones/día | 144 (cada 10 min) | Variable (solo cambios) |
| Uso disco/hora | ~15 MB | ~2-5 MB (promedio) |
| Tiempo ejecución | 2-3 segundos | <1 segundo (si no hay cambios) |

### Documentación Adicional

Ver: `docs/BACKUP_INTELIGENTE.md`

---

## 🔧 Auto-Push a GitHub

El skill incluye **auto-push** configurado para subir cambios a GitHub automáticamente.

### Uso

```bash
# Después de hacer cambios en el skill:
bash ~/.openclaw/workspace/scripts/auto_push_github.sh backup-manager
```

### Funcionamiento

- Detecta cambios automáticamente
- Crea commit con timestamp
- Push a origin master
- Silencioso si no hay cambios

---

*Skill actualizado: 14 Feb 2026*
