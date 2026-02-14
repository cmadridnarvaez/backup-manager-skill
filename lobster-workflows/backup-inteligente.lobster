name: backup-inteligente
description: Backup inteligente que solo ejecuta cuando hay cambios en archivos críticos
version: 1.0.0

env:
  BACKUP_SCRIPT: /home/cmadrid/.openclaw/workspace/scripts/backup_memory_smart.sh
  STATE_DIR: /home/cmadrid/.openclaw/workspace/.backup-state

steps:
  # ============ 1. EJECUTAR BACKUP INTELIGENTE ============
  - id: run_backup
    command: exec "bash $BACKUP_SCRIPT 2>&1 | tail -20"
    
  # ============ 2. VERIFICAR RESULTADO ============
  - id: check_result
    command: exec "cat $STATE_DIR/last_backup.json 2>/dev/null || echo '{\"status\": \"unknown\"}'"
    
  # ============ 3. DECIDIR SI NOTIFICAR ============
  - id: decision_gate
    command: approve --prompt "💾 Backup inteligente completado. ¿Ver detalles?"
    condition: $check_result.status != "skipped"
    
  # ============ 4. NOTIFICAR ÉXITO ============
  - id: notify_success
    command: exec "echo '✅ Backup completado exitosamente'"
    condition: $check_result.status == "success" && $decision_gate.approved
