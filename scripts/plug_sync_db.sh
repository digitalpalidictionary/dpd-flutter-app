#!/usr/bin/env bash
# Push the local DPD mobile db onto the plugged-in Pixel (debug app),
# but only when the local copy is newer than the phone's.
# Triggered by udev -> systemd service when the phone is connected.
set -uo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_DB="${DPD_LOCAL_DB:-$(dirname "$APP_DIR")/dpd-db/exporter/share/dpd-mobile.db}"
PKG="net.dpdict.dpd_flutter_app.debug"
DEVICE_DB="/storage/emulated/0/Android/data/${PKG}/files/dpd-mobile.db"

cd "$APP_DIR" || exit 1

if [ ! -f "$LOCAL_DB" ]; then
    echo "local db not found: $LOCAL_DB"
    exit 1
fi

# USB-debugging authorisation can lag a few seconds after plug-in.
for _ in $(seq 1 40); do
    if adb devices | grep -qw device; then
        break
    fi
    sleep 1
done
if ! adb devices | grep -qw device; then
    echo "no authorised adb device after 40s; aborting"
    exit 1
fi

# Confirm the shell transport works, so an empty stat result below means the
# remote db is genuinely absent rather than a transport hiccup.
if ! adb shell true >/dev/null 2>&1; then
    echo "adb transport not responding; aborting"
    exit 1
fi

local_epoch="$(date -r "$LOCAL_DB" +%s)"
device_epoch="$(adb shell "stat -c %Y '$DEVICE_DB' 2>/dev/null" | tr -d '\r' | tr -dc '0-9')"

local_human="$(date -r "$LOCAL_DB" +%F)"
if [ -n "$device_epoch" ]; then
    device_human="$(date -d "@$device_epoch" +%F 2>/dev/null || echo "$device_epoch")"
else
    device_human="<none>"
fi
echo "local db:  ${local_human} (${local_epoch})"
echo "device db: ${device_human} (${device_epoch:-none})"

if [ -n "$device_epoch" ] && [ "$local_epoch" -le "$device_epoch" ]; then
    echo "phone already has this db or newer; skipping."
    exit 0
fi

echo "pushing ${local_human} db to phone..."
just android-debug-push-db-no-launch
