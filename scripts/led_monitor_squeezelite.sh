#!/bin/sh
# =============================================================================
# led_monitor_squeezelite.sh — LED status monitor + WiFi self-healing
# =============================================================================
#
# Combined monitoring and recovery script that:
#   1. Disables WiFi power management (prevents idle disconnects)
#   2. Monitors Squeezelite player and Lyrion Music Server reachability
#   3. Drives the SYMFONISK front-panel status LEDs
#   4. Attempts progressive WiFi recovery on connection failures
#
# LED states:
#   WHITE  = Normal operation (Squeezelite running, server reachable)
#   AMBER  = Squeezelite not running (server still reachable)
#   RED    = Server unreachable (recovery in progress)
#
# WiFi recovery escalation (based on consecutive 5s poll failures):
#   ~1 min  (12 failures)  → wpa_cli reassociate
#   ~3 min  (36 failures)  → full wlan0 interface restart
#   ~5 min  (60 failures)  → system reboot (max 3 attempts)
#   After max reboots      → periodic reassociate every ~5 min
#
# Boot order: 3 of 3 (after boot_health_check.sh and sbpd-script.sh)
# Configure via: piCorePlayer web UI > Tweaks > User commands
#
# Part of the opensymf project:
#   https://github.com/papadopouloskyriakos/opensymf
# =============================================================================

# --- Configuration -----------------------------------------------------------
SERVER_IP="192.168.181.102"     # Lyrion Music Server IP address
SERVER_PORT=9090                # Lyrion Music Server CLI port
POLL_INTERVAL=5                 # Seconds between checks

# --- Recovery settings -------------------------------------------------------
MAX_REBOOTS=3                   # Maximum reboot attempts before giving up
REASSOCIATE_AT=12               # Failure count to trigger wpa_cli (~1 min)
RESTART_IFACE_AT=36             # Failure count to restart wlan0 (~3 min)
REBOOT_AT=60                    # Failure count to trigger reboot (~5 min)

# --- Recovery state files ----------------------------------------------------
REBOOT_FILE="/tmp/wifi_reboot_count"
LOG_FILE="/tmp/wifi_recovery.log"

# --- GPIO pin assignments (SYMFONISK Bookshelf Gen 2) ------------------------
# Mapped via multimeter from the WOW B NFC/KEY BOARD P0.3 (2021-03-31)
# See: docs/GPIO_PINOUT.md for full pinout reference
WHITE_GPIO=5                    # FPC pin 09 → RPi GPIO 5
AMBER_GPIO=17                   # FPC pin 11 → RPi GPIO 17
RED_GPIO=6                      # FPC pin 13 → RPi GPIO 6

# --- Disable WiFi power management ------------------------------------------
# The Pi's default power-saving mode is the #1 cause of WiFi drops.
# This must run before the monitoring loop starts.
iwconfig wlan0 power off

# --- GPIO initialization -----------------------------------------------------
gpio -g mode $WHITE_GPIO out
gpio -g mode $AMBER_GPIO out
gpio -g mode $RED_GPIO out

# Start with white LED on (default/healthy state)
gpio -g write $WHITE_GPIO 1
gpio -g write $AMBER_GPIO 0
gpio -g write $RED_GPIO 0

# --- Load reboot counter from previous boot ----------------------------------
if [ -f "$REBOOT_FILE" ]; then
    REBOOT_COUNT=$(cat "$REBOOT_FILE")
else
    REBOOT_COUNT=0
fi

# --- Self-healing state ------------------------------------------------------
FAIL_COUNT=0
RECOVERY_ATTEMPTED=0

# --- Main monitoring loop ----------------------------------------------------
while true; do
    if nc -z -w 2 $SERVER_IP $SERVER_PORT; then
        # --- Server reachable: reset recovery state --------------------------
        FAIL_COUNT=0
        RECOVERY_ATTEMPTED=0
        rm -f "$REBOOT_FILE"

        # Check Squeezelite process (pcp sl returns 0 when running)
        STATUS=$(pcp sl)
        if [ "$STATUS" -eq 0 ]; then
            gpio -g write $AMBER_GPIO 0
            gpio -g write $RED_GPIO 0
            gpio -g write $WHITE_GPIO 1     # WHITE: all good
        else
            gpio -g write $AMBER_GPIO 1
            gpio -g write $RED_GPIO 0
            gpio -g write $WHITE_GPIO 0     # AMBER: player issue
        fi
    else
        # --- Server unreachable: show RED and attempt recovery ----------------
        gpio -g write $AMBER_GPIO 0
        gpio -g write $RED_GPIO 1
        gpio -g write $WHITE_GPIO 0         # RED: server unreachable

        FAIL_COUNT=$((FAIL_COUNT + 1))

        # Stage 1: ~1 min — try wpa_cli reassociate
        if [ $FAIL_COUNT -eq $REASSOCIATE_AT ] && [ $RECOVERY_ATTEMPTED -lt 1 ]; then
            echo "$(date): attempting wpa_cli reassociate" >> $LOG_FILE
            wpa_cli reassociate
            RECOVERY_ATTEMPTED=1
        fi

        # Stage 2: ~3 min — restart the WiFi interface entirely
        if [ $FAIL_COUNT -eq $RESTART_IFACE_AT ] && [ $RECOVERY_ATTEMPTED -lt 2 ]; then
            echo "$(date): restarting wlan0" >> $LOG_FILE
            ifdown wlan0 2>/dev/null
            sleep 2
            ifup wlan0 2>/dev/null
            wpa_supplicant -B -i wlan0 -c /usr/local/etc/pcp/wpa_supplicant.conf 2>/dev/null
            udhcpc -i wlan0 2>/dev/null
            RECOVERY_ATTEMPTED=2
        fi

        # Stage 3: ~5 min — reboot (with boot loop protection)
        if [ $FAIL_COUNT -ge $REBOOT_AT ]; then
            if [ $REBOOT_COUNT -lt $MAX_REBOOTS ]; then
                echo "$(date): rebooting (attempt $((REBOOT_COUNT + 1))/$MAX_REBOOTS)" >> $LOG_FILE
                echo $((REBOOT_COUNT + 1)) > "$REBOOT_FILE"
                sync
                reboot
            else
                # Max reboots reached — fall back to periodic reassociate
                if [ $((FAIL_COUNT % 60)) -eq 0 ]; then
                    echo "$(date): max reboots reached, retrying reassociate" >> $LOG_FILE
                    wpa_cli reassociate
                fi
            fi
        fi
    fi
    sleep $POLL_INTERVAL
done
