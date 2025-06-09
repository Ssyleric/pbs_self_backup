# PBS Self-Backup Script

Ce script permet de réaliser une sauvegarde automatique du système PBS lui-même, en tant que VM, directement dans un dépôt PBS distant via `proxmox-backup-client`. Il envoie ensuite un rapport avec les logs vers un canal Discord.

---

### 🔧 Configuration

```bash
# 🔐 Auth avec API Token
export PBS_REPOSITORY='backup@pbs!pveclient@192.168.1.100:marechal-pve'
export PBS_PASSWORD='xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

# 🗂️ Répertoire PBS de la VM 100 (PBS lui-même)
VM_ID="100"
DEST_VM_DIR="/mnt/ssd4to/vm/$VM_ID"

# 📄 Log
LOGFILE="/var/log/pbs_self_backup.log"
> "$LOGFILE"

# 📤 Discord Webhook
WEBHOOK="https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

---

### 🚀 Commande principale

```bash
# 🧾 Début du backup
START_TIME=$(date "+%a %b %d %T %Z %Y")
echo "[$START_TIME] 🔄 Starting backup of PBS (self) to $PBS_REPOSITORY (vm/$VM_ID)" >> "$LOGFILE"

# ✅ S'assure que le fichier owner est correct
echo 'backup@pbs!pveclient' > "$DEST_VM_DIR/owner"
chown backup:backup "$DEST_VM_DIR/owner"

# 📦 Lancer la sauvegarde
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
```

---

### 📤 Envoi du rapport à Discord

```bash
curl -F "payload_json={\"content\":\"📦 Rapport sauvegarde PBS (self-backup vm/$VM_ID)\"}" \
     -F "file=@$LOGFILE;type=text/plain" \
     "$WEBHOOK"
```

---

### 🕒 Cron (planification automatique)

Ajoutez cette ligne à la crontab (`crontab -e`) :

```cron
0 2 * * 1,4 bash /home/scripts/pbs_self_backup.sh > /dev/null 2>&1  # 100 pbs, pve, standalone node
```

Cela exécutera la sauvegarde chaque lundi et jeudi à 02:00.

---

💡 **Remarques** :
- La sauvegarde est **incrémentielle**.
- Le log est envoyé sous forme de **fichier attaché** à Discord.
- `owner` est automatiquement corrigé si besoin.
- Utiliser uniquement un **PBS externe** comme dépôt (pas self-backup dans même PBS).
