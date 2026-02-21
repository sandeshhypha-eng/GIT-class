#!/usr/bin/env bash
set -euo pipefail

WORKDIR="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="${WORKDIR}/app.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "No PID file found; is the app running?" && exit 1
fi

PID=$(cat "$PID_FILE")
if kill -0 "$PID" 2>/dev/null; then
  echo "Stopping application (pid $PID)"
  kill "$PID"
  sleep 2
  if kill -0 "$PID" 2>/dev/null; then
    echo "PID still alive, sending SIGKILL"
    kill -9 "$PID"
  fi
  rm -f "$PID_FILE"
  echo "Stopped"
else
  echo "Process $PID not running. Removing stale PID file." 
  rm -f "$PID_FILE"
fi
