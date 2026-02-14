# 🚀 Instrucciones para Publicar en GitHub

## Paso 1: Crear Repositorio en GitHub

1. Ve a https://github.com/new
2. Nombre del repositorio: `backup-manager-skill`
3. Descripción: `Multi-destination backup manager for OpenClaw agents (local, S3, remote)`
4. Selecciona **Public** (para compartir con amigos)
5. **NO** inicialices con README (ya lo tenemos)
6. **NO** agregues .gitignore (ya lo tenemos)
7. **NO** agregues LICENSE (ya lo tenemos)
8. Click en **Create repository**

## Paso 2: Conectar tu Repositorio Local

Desde la terminal, ejecuta:

```bash
cd /tmp/backup-manager-skill

# Agregar el remote de GitHub (reemplaza TU_USUARIO)
git remote add origin https://github.com/TU_USUARIO/backup-manager-skill.git

# Renombrar rama a main (opcional pero recomendado)
git branch -M main

# Push al repositorio
git push -u origin main

# Push de tags
git push origin v1.0.0
```

## Paso 3: Crear Release en GitHub

1. Ve a tu repositorio en GitHub
2. Click en **Releases** (sidebar derecha)
3. Click en **Draft a new release**
4. En "Choose a tag", selecciona `v1.0.0`
5. Título: `v1.0.0 - Initial Release`
6. Descripción:
   ```markdown
   ## 🎉 Primera versión de Backup Manager

   Skill de backup multi-destino para agentes OpenClaw.

   ### Características
   - ✅ Backup local
   - ☁️ Backup a S3 (AWS, MinIO, Wasabi)
   - 🌐 Backup remoto vía SSH/rsync
   - 🔄 Retención automática
   - 🧪 Modo dry-run

   ### Instalación rápida
   ```bash
   git clone https://github.com/TU_USUARIO/backup-manager-skill.git
   bash backup-manager-skill/scripts/install.sh
   ```

   ### Documentación
   - Ver [README.md](README.md) para guía completa
   - Ver [SKILL.md](SKILL.md) para reglas del agente
   ```
7. Opcional: Generar archivos de release
   ```bash
   cd /tmp/backup-manager-skill
   ./release.sh 1.0.0
   ```
   Luego arrastra los archivos de `releases/` al release de GitHub.
8. Click en **Publish release**

## Paso 4: Compartir con Amigos

Ahora puedes compartir cualquiera de estas URLs:

- **Repositorio**: `https://github.com/TU_USUARIO/backup-manager-skill`
- **Último release**: `https://github.com/TU_USUARIO/backup-manager-skill/releases/latest`

**Instrucciones para tus amigos:**
```bash
# Clonar e instalar
git clone https://github.com/TU_USUARIO/backup-manager-skill.git
bash backup-manager-skill/scripts/install.sh

# O descargar release
curl -L https://github.com/TU_USUARIO/backup-manager-skill/releases/download/v1.0.0/backup-manager-skill-v1.0.0.tar.gz | tar -xz
```

## Paso 5: Desarrollo Continuo (Opcional)

Para agregar features en el futuro:

```bash
# Hacer cambios en el código
cd /tmp/backup-manager-skill

# Editar scripts/backup.sh, README.md, etc.

# Commit
git add .
git commit -m "Add new feature: encryption support"
git push origin main

# Crear nueva versión
./release.sh 1.1.0
git push origin v1.1.0
```

Luego crear el release en GitHub con el tag v1.1.0.

## 📁 Estructura Final del Repo

```
backup-manager-skill/
├── .gitignore              # Excluye configs locales
├── CHANGELOG.md            # Historial de cambios
├── CONTRIBUTING.md         # Guía para contribuidores
├── LICENSE                 # MIT License
├── README.md               # Documentación principal
├── release.sh              # Script para crear releases
├── skill.json              # Metadatos del skill
├── SKILL.md                # Reglas del agente
├── config/
│   ├── backup.conf.example # Template de configuración
│   └── backup.conf         # (ignorado por .gitignore)
└── scripts/
    ├── backup.sh           # Script principal
    └── install.sh          # Instalador
```

## ✅ Checklist Antes de Publicar

- [ ] Reemplazar `TU_USUARIO` con tu usuario real de GitHub
- [ ] Verificar que todo funciona: `bash scripts/backup.sh --dry-run`
- [ ] Leer README.md para ver si falta algo
- [ ] Considerar agregar un screenshot o diagrama al README

## 🆘 Solución de Problemas

**Error: "remote origin already exists"**
```bash
git remote remove origin
git remote add origin https://github.com/TU_USUARIO/backup-manager-skill.git
```

**Error: "failed to push some refs"**
```bash
git pull origin main --rebase
git push origin main
```

**Quiero cambiar el nombre del repo después**
```bash
git remote set-url origin https://github.com/TU_USUARIO/NUEVO_NOMBRE.git
```

---

¡Listo! Una vez publicado, tus amigos podrán instalar el skill fácilmente y tú podrás seguir desarrollando nuevas versiones.
