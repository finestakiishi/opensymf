#!/bin/sh
# =============================================================================
# sbpd-script.sh — Physical button daemon for Squeezelite/Jivelite
# =============================================================================
#
# Initializes sbpd (Squeeze Button Pi Daemon) to map the SYMFONISK
# front-panel buttons to Squeezelite player commands via GPIO.
#
# Button mapping:
#   GPIO 27 (Play/Pause)  → PLAY   (short press and long press)
#   GPIO 23 (Volume +)    → VOL+   (short press and long press repeat)
#   GPIO 24 (Volume -)    → VOL-   (short press and long press repeat)
#
# Dependencies:
#   - pigpiod (GPIO daemon)
#   - sbpd (https://github.com/coolio107/SqueezeButtonPi-Daemon)
#   - uinput kernel module
#
# Boot order: 2 of 3 (after boot_health_check.sh, before led_monitor)
# Configure via: piCorePlayer web UI > Tweaks > User commands
#
# Full Jivelite key command reference:
#   https://github.com/ralph-irving/tcz-lirc/blob/master/jivekeys.csv
#
# Part of the opensymf project:
#   https://github.com/<your-username>/opensymf
# =============================================================================

# --- Start pigpiod daemon ----------------------------------------------------
# -t 0   : disable sample rate throttling
# -f     : run in foreground-compatible mode
# -l     : disable remote socket interface (localhost only)
# -s 10  : sample rate 10 microseconds
pigpiod -t 0 -f -l -s 10

# Wait for pigpiod to initialize (timeout ~10 seconds)
count=10
while ! pigs t >/dev/null 2>&1; do
    if [ $((count--)) -le 0 ]; then
        printf "\n[FAIL] pigpiod failed to initialize within timeout\n"
        exit 1
    fi
    sleep 1
done
printf "\n[ OK ] pigpiod is running\n"

# --- Load uinput module ------------------------------------------------------
# Required for sbpd to send keystroke events to Squeezelite/Jivelite
sudo modprobe uinput
sudo chmod g+w /dev/uinput

# --- GPIO button assignments (SYMFONISK Bookshelf Gen 2) ---------------------
# Mapped via multimeter from the WOW B NFC/KEY BOARD P0.3 (2021-03-31)
# See: docs/GPIO_PINOUT.md for full pinout reference

SW1=27              # Play/Pause button — FPC pin 15 → GPIO 27
SH1=PLAY            # Short press action
LO1=PLAY            # Long press action
LMS1=250            # Long press threshold (ms)

SW2=23              # Volume+ button — FPC pin 08 → GPIO 23
SH2=VOL+            # Short press action
LO2=VOL+            # Long press action (repeats)
LMS2=250            # Long press threshold (ms)

SW3=24              # Volume- button — FPC pin 07 → GPIO 24
SH3=VOL-            # Short press action
LO3=VOL-            # Long press action (repeats)
LMS3=250            # Long press threshold (ms)

# --- Launch sbpd -------------------------------------------------------------
CMD="sbpd -v \
b,$SW1,$SH1,2,0,$LO1,$LMS1,pull_up_down=GPIO.PUD_UP \
b,$SW2,$SH2,2,0,$LO2,$LMS2,pull_up_down=GPIO.PUD_UP \
b,$SW3,$SH3,2,0,$LO3,$LMS3,pull_up_down=GPIO.PUD_UP"

echo "$CMD"
$CMD > /dev/null 2>&1 &
