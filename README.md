# Backup Manager for OpenClaw

Skill de backup multi-destino para agentes OpenClaw. Soporta backup local, Amazon S3 (y compatibles como MinIO), y servidores remotos vía rsync/SSH.

## 🚀 Instalación Rápida

### Opción 1: Git Clone (recomendado)
```bash
cd /tmp
git clone https://github.com/tuusuario/backup-manager-skill.git
bash backup-manager-skill/scripts/install.sh
```

### Opción 2: Descargar y extraer
```bash
# Descargar el archivo backup-manager-skill.tar.gz
tar -xzf backup-manager-skill.tar.gz
cd backup-manager-skill
bash scripts/install.sh
```

### Opción 3: Copiar manualmente
Copia la carpeta `backup-manager/` a `~/.openclaw/workspace/skills/` y ejecuta:
```bash
bash ~/.openclaw/workspace/skills/backup-manager/scripts/install.sh
```

## 📋 Requisitos

- **Local**: Solo bash (incluido en Linux/macOS)
- **S3**: AWS CLI (`pip install awscli`)
- **Remote**: rsync, ssh

## ⚙️ Configuración

Edita `~/.openclaw/workspace/skills/backup-manager/config/backup.conf`:

```bash
# Archivos a respaldar
BACKUP_FILES="SOUL.md MEMORY.md TOOLS.md AGENTS.md USER.md IDENTITY.md"

# Destino local (siempre habilitado)
LOCAL_ENABLED=true
LOCAL_BACKUP_DIR="/home/tuusuario/.openclaw/workspace/backups/memory"

# Destino S3 (opcional)
S3_ENABLED=false
S3_BUCKET="mi-bucket"
S3_PREFIX="agent-backups"
S3_REGION="us-east-1"
# S3_ENDPOINT=""  # Para MinIO, Wasabi, etc.

# Destino remoto (opcional)
REMOTE_ENABLED=false
REMOTE_HOST="backup.example.com"
REMOTE_USER="backup"
REMOTE_PATH="/backups/openclaw"
REMOTE_SSH_KEY="~/.ssh/id_rsa_backup"
```

## 🎯 Uso

### Backup local (default)
```bash
bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh
```

### Backup a S3
```bash
bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest s3
```

### Backup remoto
```bash
bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest remote
```

### Backup a todos los destinos
```bash
bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest all
```

### Simular sin ejecutar (dry-run)
```bash
bash ~/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dry-run
```

## 🔧 Configurar S3

1. Instalar AWS CLI:
   ```bash
   pip install awscli
   aws configure
   ```

2. O usar variables de entorno:
   ```bash
   export AWS_ACCESS_KEY_ID="TU_KEY"
   export AWS_SECRET_ACCESS_KEY="TU_SECRET"
   export AWS_DEFAULT_REGION="us-east-1"
   ```

3. Para S3 compatible (MinIO, Wasabi):
   ```bash
   # En backup.conf:
   S3_ENDPOINT="https://minio.tuserver.com:9000"
   ```

## 🔧 Configurar Backup Remoto

1. Generar SSH key dedicada:
   ```bash
   ssh-keygen -f ~/.ssh/id_rsa_backup -N ""
   ```

2. Copiar al servidor remoto:
   ```bash
   ssh-copy-id -i ~/.ssh/id_rsa_backup backup@tuservidor.com
   ```

3. Probar conexión:
   ```bash
   ssh -i ~/.ssh/id_rsa_backup backup@tuservidor.com "mkdir -p /backups/openclaw"
   ```

## 🔄 Automatización (Cron)

Agregar a crontab para backups cada 10 minutos:
```bash
*/10 * * * * /bin/bash /home/tuusuario/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest local
```

Backup diario a S3:
```bash
0 */6 * * * /bin/bash /home/tuusuario/.openclaw/workspace/skills/backup-manager/scripts/backup.sh --dest s3
```

## 📁 Estructura

```
backup-manager/
├── SKILL.md              # Documentación del skill
├── skill.json            # Metadatos
├── README.md             # Este archivo
├── config/
│   ├── backup.conf.example   # Template de configuración
│   └── backup.conf           # Tu configuración (creado al instalar)
└── scripts/
    ├── install.sh        # Instalador
    └── backup.sh         # Script principal
```

## 🛡️ Seguridad

- Permisos de archivos: 600 para configs, 700 para directorios
- No expone credenciales en logs ni mensajes
- Compatible con [SecureClaw](https://github.com/adversa-ai/secureclaw) para auditoría

## 🐛 Troubleshooting

### "AWS CLI no instalado"
```bash
pip install awscli
aws configure
```

### "Permiso denegado en servidor remoto"
Verifica que la SSH key tenga los permisos correctos:
```bash
chmod 600 ~/.ssh/id_rsa_backup
```

### "No se encontró workspace"
Asegúrate de que `WORKSPACE_DIR` en `backup.conf` apunte a tu directorio de OpenClaw.

## 📄 Licencia

MIT License - Libre para usar, modificar y distribuir.

## 🙏 Créditos

Creado por Valentino para CMD SERVICIOS TECNOLOGICOS SPA.
Inspirado en SecureClaw de Adversa AI.
