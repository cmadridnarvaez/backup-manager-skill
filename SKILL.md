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
