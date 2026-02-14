# Backup Manager - Guía de Uso

## Backup Inteligente con Lobster (Nuevo)

El backup inteligente solo ejecuta cuando detecta cambios en los archivos críticos, ahorrando espacio en disco y recursos.

### Características

- **Detección de cambios** por hash MD5
- **Solo backup incremental** - no duplica archivos sin cambios
- **Rotación automática** - mantiene últimos 50 backups
- **Integración Lobster** - aprobación para ver detalles
- **Logs detallados** en `logs/lobster_backup.log`

### Archivos Monitoreados

- `memory/YYYY-MM-DD.md` - Logs diarios
- `MEMORY.md` - Memoria persistente
- `TOOLS.md` - Configuración de herramientas
- `SOUL.md` - Personalidad del agente
- `USER.md` - Perfil del usuario
- `IDENTITY.md` - Identidad del agente

### Uso

#### Manual
```bash
bash scripts/backup_memory_smart.sh
```

#### Con Lobster
```bash
# Ejecutar workflow completo
lobster run backup-inteligente.lobster
```

#### Automático (Cron)
```bash
# Editar crontab
crontab -e

# Agregar cada 10 minutos
*/10 * * * * /bin/bash /home/cmadrid/.openclaw/workspace/scripts/backup_memory_smart.sh >> /home/cmadrid/.openclaw/workspace/logs/lobster_backup.log 2>&1
```

### Estados del Backup

| Estado | Descripción |
|--------|-------------|
| `success` | Backup ejecutado, archivos modificados respaldados |
| `skipped` | Sin cambios detectados, backup omitido |
| `error` | Error en el proceso |

### Archivos de Estado

- `.backup-state/*.hash` - Hashes de archivos monitoreados
- `.backup-state/last_backup.json` - Resumen último backup
- `.backup-state/last_run.txt` - Resumen para Lobster
- `logs/lobster_backup.log` - Logs completos

### Beneficios vs Backup Tradicional

| Aspecto | Backup Tradicional | Backup Inteligente |
|---------|-------------------|-------------------|
| Frecuencia | Cada 10 min | Cada 10 min (solo si hay cambios) |
| Uso de disco | Alto (50 archivos/hr) | Bajo (solo cambios) |
| Velocidad | Lento (siempre copia) | Rápido (hash check rápido) |
| Tokens LLM | 0 | 0 (con Lobster) |

### Troubleshooting

**¿No se ejecuta el backup?**
```bash
# Verificar permisos
chmod +x scripts/backup_memory_smart.sh

# Verificar logs
tail logs/lobster_backup.log
```

**¿Demasiados archivos en backup?**
```bash
# Limpiar manualmente
ls -t backups/memory/*.md | tail -n +51 | xargs rm -f
```

**¿Lobster no detecta cambios?**
```bash
# Verificar estado
.cat .backup-state/last_backup.json
```
