#!/bin/bash

################################################################################
# Restore pour MediaStock (Docker Compose + MySQL)
################################################################################

set -euo pipefail

# ---- CONFIG ----
BACKUP_DIR="./backups"
DB_CONTAINER="mediastock-db"
DB_USER="mediastock"
read -s -p "Entrez le mot de passe MySQL pour l'utilisateur $DB_USER: " DB_PASS
echo
APP_DIR="."  # Répertoire du projet
CONFIG_FILES=("config/.env" "config/docker-compose.yml" "config/docker-compose.production.yml")

# ---- Fonctions ----
log()    { echo -e "[INFO]  $(date +'%F %T') $1"; }
warn()   { echo -e "[WARN]  $(date +'%F %T') $1"; }
error()  { echo -e "[ERROR] $(date +'%F %T') $1"; exit 1; }

# Récupère le dernier backup si aucun argument
if [ $# -eq 0 ]; then
    BACKUP_FILE=$(ls -t "$BACKUP_DIR"/mediastock_backup_*.tar.gz | head -n1)
    [ -z "$BACKUP_FILE" ] && error "Aucun backup trouvé dans $BACKUP_DIR"
else
    BACKUP_FILE="$1"
fi

log "===== Restauration depuis : $BACKUP_FILE ====="

# ---- Extraction ----
TMP_RESTORE=$(mktemp -d)
tar -xzf "$BACKUP_FILE" -C "$TMP_RESTORE"

# ---- Restore MySQL ----
if [ -f "$TMP_RESTORE/$(basename "$BACKUP_FILE" .tar.gz)/db/mysql_all.sql.gz" ]; then
    log "🔹 Restauration MySQL"
    gunzip -c "$TMP_RESTORE/$(basename "$BACKUP_FILE" .tar.gz)/db/mysql_all.sql.gz" \
        | docker exec -i "$DB_CONTAINER" mysql -u"$DB_USER" -p"$DB_PASS"
    log "✔ MySQL restauré"
else
    warn "⚠ Dump MySQL manquant, restauration skipped"
fi

# ---- Restore code source ----
if [ -d "$TMP_RESTORE/$(basename "$BACKUP_FILE" .tar.gz)/app" ]; then
    log "🔹 Restauration code source"
    rsync -a --delete "$TMP_RESTORE/$(basename "$BACKUP_FILE" .tar.gz)/app/" "$APP_DIR/"
    log "✔ Code source restauré"
else
    warn "⚠ Dossier app manquant, restauration skipped"
fi

# ---- Restore config ----
if [ -d "$TMP_RESTORE/$(basename "$BACKUP_FILE" .tar.gz)/config" ]; then
    log "🔹 Restauration fichiers config"
    for f in "${CONFIG_FILES[@]}"; do
        if [ -f "$TMP_RESTORE/$(basename "$BACKUP_FILE" .tar.gz)/config/$(basename "$f")" ]; then
            cp "$TMP_RESTORE/$(basename "$BACKUP_FILE" .tar.gz)/config/$(basename "$f")" "$f"
        fi
    done
    log "✔ Config restaurée"
else
    warn "⚠ Dossier config manquant, restauration skipped"
fi

# ---- Cleanup ----
rm -rf "$TMP_RESTORE"

log "===== Restauration terminée 🎉 ====="
