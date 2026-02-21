#!/usr/bin/env bash
set -euo pipefail

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="${LOG_HOME:-$WORKDIR/logs}"
PID_FILE="$WORKDIR/app.pid"

mkdir -p "$LOG_DIR"

if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
  echo "Already running with pid $(cat $PID_FILE)"
  exit 0
fi

echo "Starting Python FastAPI app..."
nohup python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8081 > "$LOG_DIR/stdout.log" 2>&1 &
echo $! > "$PID_FILE"
echo "Started pid $(cat $PID_FILE)"
