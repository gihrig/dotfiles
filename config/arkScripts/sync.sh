#!/bin/zsh
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# ---------------------------------------------------------------------------
# sync.sh — macOS Volume Sync Script
# Mounts source/backup Thunderbolt HDD pairs, rsyncs each pair, then ejects.
#
# Scheduled via root cron: sudo crontab -e
# PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
# 00      03      *       *       *       /Users/glen/.config/arkScripts/sync.sh
#
# sudoers matches the full command + arguments exactly, so this is genuinely restrictive.
#    You can restrict to exact volume paths:
#
# sudo visudo -f /etc/sudoers.d/sync_clean
# glen ALL=(ALL) NOPASSWD:/usr/bin/mdutil -i off /Volumes/Glen-DATA, \
# /usr/bin/mdutil -i off /Volumes/Janis-DATA, \
# /usr/bin/mdutil -i off /Volumes/iCrumz-DATA, \
# /usr/bin/mdutil -X /Volumes/Glen-DATA, \
# /usr/bin/mdutil -X /Volumes/Janis-DATA, \
# /usr/bin/mdutil -X /Volumes/iCrumz--DATA, \
# /usr/bin/mdutil -i off /Volumes/Glen-DATAb, \
# /usr/bin/mdutil -i off /Volumes/Janis-DATAb, \
# /usr/bin/mdutil -i off /Volumes/iCrumz-DATAb, \
# /usr/bin/mdutil -X /Volumes/Glen-DATAb, \
# /usr/bin/mdutil -X /Volumes/Janis-DATAb, \
# /usr/bin/mdutil -X /Volumes/iCrumz--DATAb, \
# /usr/local/bin/clean_meta_priv.sh
#                           ...
# ---
# /usr/local/bin/clean_meta_priv.sh  (owned root:admin, chmod 700)
#
# #!/bin/bash
# vol_path="$1"
# rm -rf "$vol_path"/{.DS_Store,.fseventsd,.Trashes,.TemporaryItems}
# find "$vol_path" -name ".DS_Store" -delete
# mdutil -i off "$vol_path"
# if [[ -d "$vol_path/.Spotlight-V100" ]]; then
#     mdutil -X "$vol_path"
# fi

# ---------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------

LOG_FILE="/Users/glen/logs/sync.log"
SOURCES=("Glen-DATA"   "Janis-DATA"   "iCrumz-DATA")
DESTS=(  "Glen-DATAb"  "Janis-DATAb"  "iCrumz-DATAb")
EXCLUDES=(".Spotlight-V100" ".Trashes" ".TemporaryItems")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

mount_volume() {
    local vol="$1"
    if mount | grep -q "/Volumes/$vol"; then
        log "  $vol already mounted — skipping mount"
        return 0
    fi
    if diskutil mount "$vol" >> "$LOG_FILE" 2>&1; then
        log "  Mounted $vol"
        return 0
    else
        log "  ERROR: Failed to mount $vol (drive not connected?)"
        return 1
    fi
}

unmount_volume() {
    # diskutil eject affects all volumes in RAID 1 set
    local vol="$1"
    if diskutil unmount "$vol" >> "$LOG_FILE" 2>&1; then
        log "  Unmounted $vol"
    else
        log "  WARNING: Could not unmount $vol (may already be unmounted)"
    fi
}

clean_meta() {
    local vol_path="$1"
    log "  Cleaning metadata on $vol_path"
    /usr/local/bin/clean_meta_priv.sh "$vol_path" >> "$LOG_FILE" 2>&1;
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

mkdir -p "/Users/glen/logs"
echo "" > "$LOG_FILE"

log "=== Sync started ==="

exclude_flags=()
for e in "${EXCLUDES[@]}"; do
    exclude_flags+=(--exclude="$e")
done

for i in $(seq 1 ${#SOURCES[@]}); do
    src="${SOURCES[$i]}"
    dst="${DESTS[$i]}"

    log ""
    log "--- Pair $i: $src → $dst ---"

    mount_volume "$src" || { log "  Skipping pair $i (source unavailable)"; continue }
    mount_volume "$dst" || { log "  Skipping pair $i (destination unavailable)"; continue }

    clean_meta "/Volumes/$src"

    log "  Starting rsync: /Volumes/$src/ → /Volumes/$dst/"
    if rsync -avh --delete --progress "${exclude_flags[@]}" "/Volumes/$src/" "/Volumes/$dst/" >> "$LOG_FILE" 2>&1; then
        log "  rsync completed successfully for pair $i"
        clean_meta "/Volumes/$dst"
    else
        log "  ERROR: rsync failed for pair $i (exit code $?)"
    fi
done

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

log ""
log "--- Unmounting volumes ---"
for i in $(seq 1 ${#SOURCES[@]}); do
    unmount_volume "${SOURCES[$i]}"
    unmount_volume "${DESTS[$i]}"
done

log ""
log "=== Sync completed ==="
