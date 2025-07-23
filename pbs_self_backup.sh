#!/bin/bash

# 🔐 Auth avec API Token
export PBS_REPOSITORY='backup@pbs!pveclient@192.168.1.100:marechal-pve'
export PBS_PASSWORD='XXXxxxxxXXXXXXxxxxxxxxxxxXXXXXXxxxxx'

# 🗂️ Répertoire PBS de la VM 100 (PBS lui-même)
VM_ID="100"

# 📝 Log journalier avec horodatage
LOGFILE="/var/log/pbs_self_backup-$(date +%F).log"
> "$LOGFILE"

# 📤 Discord Webhook
WEBHOOK="https://discord.com/api/webhooks/XXXxxxxxXXXXXXxxxxxxxxxxxXXXXXXxxxx/XXXxxxxxXXXXXXxxxxxxxxxxxXXXXXXxxxxXXXxxxxxXXXXXXxxxxxxxxxxxXXXXXXxxxx"

# 🔪 Tuer tout processus figé précédemment
pkill -f "proxmox-backup-client backup root.pxar:/" 2>/dev/null
sleep 1

# 🕓 Horodatage début
START_TIME=$(date "+%a %b %d %T %Z %Y")
echo "[$START_TIME] 🔄 Starting backup of PBS to $PBS_REPOSITORY (vm/$VM_ID)" >> "$LOGFILE"

# 📦 Lancer la sauvegarde PBS root
proxmox-backup-client backup root.pxar:/ \
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

# 📤 Notification Discord avec log en pièce jointe
curl -F "payload_json={\"content\":\"📦 Rapport sauvegarde PBS (self-backup vm/$VM_ID)\"}" \
     -F "file=@$LOGFILE;type=text/plain" \
     "$WEBHOOK"
