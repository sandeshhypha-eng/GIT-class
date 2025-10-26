#!/bin/bash
# monitor_system.sh
# Monitors CPU, memory, and disk usage and sends a report to Discord

# === CONFIG ===
DISCORD_WEBHOOK="${DISCORD_WEBHOOK}"  # Set this environment variable
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80

# === Get System Usage ===

# CPU usage (average of all cores)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
CPU=${CPU%.*}  # convert float to integer

# Memory usage %
MEM=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100}')

# Disk usage % for root /
DISK=$(df / | awk 'END{print $5}' | sed 's/%//')

# === Build Message ===
NOW=$(date "+%Y-%m-%d %H:%M:%S")
MSG="📊 **System Resource Usage Report** — $NOW\n"
MSG+="💻 CPU Usage: ${CPU}%"
[ $CPU -ge $CPU_THRESHOLD ] && MSG+=" ⚠️ High"
MSG+="\n"
MSG+="🧠 Memory Usage: ${MEM}%"
[ $MEM -ge $MEM_THRESHOLD ] && MSG+=" ⚠️ High"
MSG+="\n"
MSG+="💾 Disk Usage: ${DISK}%"
[ $DISK -ge $DISK_THRESHOLD ] && MSG+=" ⚠️ High"

# === Send to Discord ===
if [ -z "$DISCORD_WEBHOOK" ]; then
  echo "DISCORD_WEBHOOK not set. Skipping Discord notification."
  echo -e "$MSG"
else
  curl -s -H "Content-Type: application/json" \
       -X POST \
       -d "{\"content\": \"$MSG\"}" \
       $DISCORD_WEBHOOK
fi
