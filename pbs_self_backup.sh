#!/bin/bash

# 🔐 Auth avec API Token
export PBS_REPOSITORY='backup@pbs!pveclient@192.168.1.100:marechal-pve'
export PBS_PASSWORD='XXXxxxxxXXXXXXxxxxxxxxxxxXXXXXXxxxxx'

# 🗂️ Répertoire PBS de la VM 100 (PBS lui-même)
VM_ID="100"
DEST_VM_DIR="/mnt/ssd4to/vm/$VM_ID"

# 📄 Log
LOGFILE="/var/log/pbs_self_backup.log"
> "$LOGFILE"

# 📤 Discord Webhook
WEBHOOK="https://discord.com/api/webhooks/XXXxxxxxXXXXXXxxxxxxxxxxxXXXXXXxxxx/XXXxxxxxXXXXXXxxxxxxxxxxxXXXXXXxxxxXXXxxxxxXXXXXXxxxxxxxxxxxXXXXXXxxxx"

# 🧾 Début du backup
START_TIME=$(date "+%a %b %d %T %Z %Y")
echo "[$START_TIME] 🔄 Starting backup of PBS (self) to $PBS_REPOSITORY (vm/$VM_ID)" >> "$LOGFILE"

# ✅ S'assure que le fichier owner est correct
echo 'backup@pbs!pveclient' > "$DEST_VM_DIR/owner"
chown backup:backup "$DEST_VM_DIR/owner"

# 📝 Création d'un fichier note de contexte
NOTEFILE="/tmp/pbs_backup_note.txt"
echo "📦 Backup automatique de PBS (VM $VM_ID) – lancé le $START_TIME" > "$NOTEFILE"

# 📦 Lancer la sauvegarde (incluant la note)
proxmox-backup-client backup root.pxar:/ note.txt:$NOTEFILE \
  --repository "$PBS_REPOSITORY" \
  --backup-id "$VM_ID" \
  --backup-type vm >> "$LOGFILE" 2>&1

STATUS=$?
END_TIME=$(date "+%a %b %d %T %Z %Y")

if [ "$STATUS" -eq 0 ]; then
    echo "[$END_TIME] ✅ PBS self-backup completed successfully." >> "$LOGFILE"
else
    echo "[$END_TIME] ❌ PBS self-backup failed (status $STATUS)." >> "$LOGFILE"
fi

# 📤 Envoi Discord avec pièce jointe
curl -F "payload_json={\"content\":\"📦 Rapport sauvegarde PBS (self-backup vm/$VM_ID)\"}" \
     -F "file=@$LOGFILE;type=text/plain" \
     "$WEBHOOK"
