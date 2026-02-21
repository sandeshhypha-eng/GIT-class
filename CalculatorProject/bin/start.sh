#!/usr/bin/env bash
# Start script for CalculatorProject
set -euo pipefail

APP_NAME=CalculatorProject
WORKDIR="$(cd "$(dirname "$0")/.." && pwd)"
JAR="$WORKDIR/target/CalculatorProject-1.0.jar"
LOG_DIR="${WORKDIR}/logs"
PID_FILE="${WORKDIR}/app.pid"

JAVA_OPTS="-Xms128m -Xmx512m -Dspring.profiles.active=prod"

mkdir -p "$LOG_DIR"

if [ ! -f "$JAR" ]; then
  echo "Jar not found at $JAR. Build first: mvn -f $WORKDIR clean package -DskipTests"
  exit 1
fi

if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
  echo "Application appears to be already running (pid $(cat $PID_FILE))." && exit 0
fi

echo "Starting $APP_NAME..."
nohup java $JAVA_OPTS -DLOG_HOME="$LOG_DIR" -jar "$JAR" > "$LOG_DIR/stdout.log" 2>&1 &
echo $! > "$PID_FILE"
echo "Started with pid $(cat $PID_FILE)"
