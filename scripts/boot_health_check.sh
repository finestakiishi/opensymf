#!/bin/sh
# =============================================================================
# boot_health_check.sh — Post-boot system health check with LED feedback
# =============================================================================
#
# Runs a series of health checks after boot and signals the result
# via the front-panel LEDs:
#
#   3x GREEN blink  = All checks passed
#   (script exits early on any failure — no LED signal for failures)
#
# Checks performed (in order, exits on first failure):
#   1. Root filesystem disk usage (threshold: 90%)
#   2. CPU temperature (threshold: 75°C)
#   3. WiFi connectivity (wlan0 has IP address)
#   4. Internet connectivity (ping 8.8.8.8)
#
# After all checks pass, optionally starts SNMP daemon for monitoring.
#
# Boot order: 1 of 3 (runs first, before sbpd-script.sh and led_monitor)
# Configure via: piCorePlayer web UI > Tweaks > User commands
#
# Part of the opensymf project:
#   https://github.com/papadopouloskyriakos/opensymf
# =============================================================================

# Define GPIO pin for the green LED
GREEN_GPIO=13
WHITE_GPIO=5

# Configure the GPIO pin
gpio -g mode $GREEN_GPIO out
gpio -g mode $WHITE_GPIO out

# Function to blink the green LED
blink_green_led() {
    for i in 1 2 3; do
        gpio -g write $GREEN_GPIO 1
        gpio -g write $WHITE_GPIO 0
        sleep 0.3
        gpio -g write $GREEN_GPIO 0
        gpio -g write $WHITE_GPIO 1
        sleep 0.3
    done
}

# 1. Check disk space on root filesystem
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -ge 90 ]; then
    echo "Disk usage is above 90%."
    exit 1
fi

# 2. Check CPU temperature
CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
CPU_TEMP_C=$((CPU_TEMP / 1000))
if [ "$CPU_TEMP_C" -ge 75 ]; then
    echo "CPU temperature is above 75°C."
    exit 1
fi

# 3. Check Wi-Fi connectivity
WIFI_INTERFACE="wlan0"
if ifconfig "$WIFI_INTERFACE" | grep -q "inet addr:"; then
    echo "Wi-Fi is connected."
else
    echo "Wi-Fi is not connected."
    exit 1
fi

# 4. Check internet connectivity
if ! ping -q -c 1 -W 2 8.8.8.8 >/dev/null; then
    echo "No internet connectivity."
    exit 1
fi

# All checks passed; blink the green LED
blink_green_led

# Optional: start SNMP daemon for network monitoring
# Remove or comment out if you don't use SNMP-based monitoring
/usr/local/sbin/snmpd -c /etc/snmp/snmpd.conf &
