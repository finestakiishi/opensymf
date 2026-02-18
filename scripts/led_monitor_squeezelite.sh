#!/bin/sh
# =============================================================================
# led_monitor_squeezelite.sh — Continuous LED status monitor
# =============================================================================
#
# Monitors Squeezelite player and Lyrion Music Server reachability,
# signaling status through the SYMFONISK front-panel LEDs:
#
#   WHITE  = Normal operation (Squeezelite running, server reachable)
#   AMBER  = Squeezelite not running (server still reachable)
#   RED    = Server unreachable
#
# Runs in an infinite loop, checking every POLL_INTERVAL seconds.
#
# Boot order: 3 of 3 (after boot_health_check.sh and sbpd-script.sh)
# Configure via: piCorePlayer web UI > Tweaks > User commands
#
# Part of the opensymf project:
#   https://github.com/<your-username>/opensymf
# =============================================================================

# --- Configuration -----------------------------------------------------------
SERVER_IP="192.168.181.102"     # Lyrion Music Server IP address
SERVER_PORT=9090                # Lyrion Music Server CLI port
POLL_INTERVAL=5                 # Seconds between status checks

# --- GPIO pin assignments (SYMFONISK Bookshelf Gen 2) ------------------------
# Mapped via multimeter from the WOW B NFC/KEY BOARD P0.3 (2021-03-31)
# See: docs/GPIO_PINOUT.md for full pinout reference
WHITE_GPIO=5                    # FPC pin 09 → RPi GPIO 5
AMBER_GPIO=17                   # FPC pin 11 → RPi GPIO 17
RED_GPIO=6                      # FPC pin 13 → RPi GPIO 6

# --- GPIO initialization -----------------------------------------------------
gpio -g mode $WHITE_GPIO out
gpio -g mode $AMBER_GPIO out
gpio -g mode $RED_GPIO out

# Start with white LED on (default/healthy state)
gpio -g write $WHITE_GPIO 1
gpio -g write $AMBER_GPIO 0
gpio -g write $RED_GPIO 0

# --- Helper functions --------------------------------------------------------
set_leds() {
    # Usage: set_leds <white> <amber> <red>
    gpio -g write $WHITE_GPIO "$1"
    gpio -g write $AMBER_GPIO "$2"
    gpio -g write $RED_GPIO "$3"
}

# --- Main monitoring loop ----------------------------------------------------
while true; do
    if nc -z -w 2 "$SERVER_IP" "$SERVER_PORT"; then
        # Server reachable — check Squeezelite process
        # pcp sl returns 0 when Squeezelite is running
        STATUS=$(pcp sl)
        if [ "$STATUS" -eq 0 ]; then
            set_leds 1 0 0      # WHITE: all good
        else
            set_leds 0 1 0      # AMBER: player issue
        fi
    else
        set_leds 0 0 1          # RED: server unreachable
    fi
    sleep $POLL_INTERVAL
done
