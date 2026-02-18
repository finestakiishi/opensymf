#!/bin/sh
# =============================================================================
# boot_health_check.sh — Post-boot system health check with LED feedback
# =============================================================================
#
# Runs a series of health checks after boot and signals the result
# via the front-panel LEDs:
#
#   3x GREEN blink  = All checks passed
#   3x RED blink    = One or more checks failed (see logs)
#
# Checks performed:
#   1. Root filesystem disk usage (threshold: 90%)
#   2. CPU temperature (threshold: 75°C)
#   3. WiFi connectivity (wlan0 has IP address)
#   4. Internet connectivity (ping 8.8.8.8)
#
# Boot order: 1 of 3 (runs first, before sbpd-script.sh and led_monitor)
# Configure via: piCorePlayer web UI > Tweaks > User commands
#
# Part of the opensymf project:
#   https://github.com/<your-username>/opensymf
# =============================================================================

# --- GPIO pin assignments ----------------------------------------------------
GREEN_GPIO=13                   # FPC pin 14 → RPi GPIO 13
WHITE_GPIO=5                    # FPC pin 09 → RPi GPIO 5
RED_GPIO=6                      # FPC pin 13 → RPi GPIO 6

# --- Thresholds --------------------------------------------------------------
DISK_THRESHOLD=90               # Percentage
TEMP_THRESHOLD=75               # Degrees Celsius

# --- GPIO initialization -----------------------------------------------------
gpio -g mode $GREEN_GPIO out
gpio -g mode $WHITE_GPIO out
gpio -g mode $RED_GPIO out

# --- LED feedback functions --------------------------------------------------
blink_led() {
    # Usage: blink_led <gpio_pin> <count>
    local pin="$1"
    local count="$2"
    local i=0
    while [ $i -lt "$count" ]; do
        gpio -g write "$pin" 1
        gpio -g write $WHITE_GPIO 0
        sleep 0.3
        gpio -g write "$pin" 0
        gpio -g write $WHITE_GPIO 1
        sleep 0.3
        i=$((i + 1))
    done
}

# --- Health checks -----------------------------------------------------------
FAILED=0

# 1. Disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    echo "[FAIL] Disk usage at ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)"
    FAILED=1
else
    echo "[ OK ] Disk usage at ${DISK_USAGE}%"
fi

# 2. CPU temperature
CPU_TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
CPU_TEMP=$((CPU_TEMP_RAW / 1000))
if [ "$CPU_TEMP" -ge "$TEMP_THRESHOLD" ]; then
    echo "[FAIL] CPU temperature at ${CPU_TEMP}°C (threshold: ${TEMP_THRESHOLD}°C)"
    FAILED=1
else
    echo "[ OK ] CPU temperature at ${CPU_TEMP}°C"
fi

# 3. WiFi connectivity
WIFI_INTERFACE="wlan0"
if ifconfig "$WIFI_INTERFACE" | grep -q "inet addr:"; then
    echo "[ OK ] WiFi connected on ${WIFI_INTERFACE}"
else
    echo "[FAIL] WiFi not connected on ${WIFI_INTERFACE}"
    FAILED=1
fi

# 4. Internet connectivity
if ping -q -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "[ OK ] Internet reachable"
else
    echo "[FAIL] No internet connectivity"
    FAILED=1
fi

# --- Signal result via LEDs --------------------------------------------------
if [ "$FAILED" -eq 0 ]; then
    echo "[PASS] All health checks passed"
    blink_led $GREEN_GPIO 3
else
    echo "[WARN] One or more health checks failed"
    blink_led $RED_GPIO 3
fi
