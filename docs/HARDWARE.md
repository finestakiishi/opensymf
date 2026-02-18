# Hardware Reference

## Speaker Fleet

| Speaker                     | Qty | Compute          | DAC/Amp HAT           | Audio Approach        |
|-----------------------------|-----|------------------|-----------------------|-----------------------|
| SYMFONISK Bookshelf (Gen 2) | 4   | RPi Zero 2 WH   | IQaudIO DigiAMP+      | HAT drives passive speakers directly |
| SYMFONISK Picture Frame     | 2   | RPi Zero 2 WH   | IQaudIO DigiAMP+      | HAT drives passive speakers directly |
| Sonos Play:5 (Gen 1)        | 1   | RPi Zero 2 WH   | HiFiBerry DAC+/AMP    | Line-level into original amp stage   |

## DAC/Amp HATs

### IQaudIO DigiAMP+ SC0370 ("Black Card")

Used in all six SYMFONISK conversions (bookshelf + picture frame). This is a combined DAC and Class-D amplifier that sits on top of the Pi via the GPIO header and connects to passive speaker drivers via screw terminals.

| Setting        | Value                                |
|----------------|--------------------------------------|
| ALSA output    | `hw:CARD=IQaudIODAC,DEV=0`          |
| ALSA params    | `80 4 NULL 1 NULL`                   |
| Interface      | I²S                                  |
| Power          | Via original SYMFONISK PSU           |

**Sourcing:**
- Amazon.de — Order 302-0082169-2521942 — €61.23/unit
- Mouser — PO 35619874 — €34.49/unit

### HiFiBerry AMP+ (or DAC+)

Used in the Sonos Play:5 Gen 1 conversion. Feeds audio into the original Play:5 amplification stage (five Class-D amplifiers, six drivers).

| Setting        | Value                                |
|----------------|--------------------------------------|
| ALSA output    | `hw:CARD=sndrpihifiberry`            |
| ALSA params    | `80 4 NULL 1 NULL`                   |
| Interface      | I²S                                  |
| Power          | Via original Play:5 PSU             |

**Sourcing:**
- AliExpress — Order 3052253466206195 — €48.47/unit

## piCorePlayer Audio Configuration

In the piCorePlayer web UI, configure the audio output under **Squeezelite Settings**:

**For SYMFONISK speakers (IQaudIO DigiAMP+):**
- Audio output device: `IQaudIO DigiAMP+`
- Output setting: `hw:CARD=IQaudIODAC,DEV=0`

**For Sonos Play:5 (HiFiBerry):**
- Audio output device: `HiFiBerry AMP (and+)`
- Output setting: `hw:CARD=sndrpihifiberry`

## Raspberry Pi

All speakers use the **Raspberry Pi Zero 2 WH** (the "WH" variant with pre-soldered GPIO header). Key specs relevant to this project:

- 512MB RAM
- 2.4GHz 802.11 b/g/n WiFi (no 5GHz — keep your speakers on the 2.4GHz band)
- Bluetooth 4.2/BLE (not used)
- 40-pin GPIO header (pre-soldered)
- Micro-USB power (powered via HAT in this project)

## Original Speaker Components Retained

### SYMFONISK Bookshelf (Gen 2)
- Power supply (AC/DC)
- Speaker drivers (passive)
- Front panel PCB with 4 LEDs + 3 buttons (connected via GPIO)
- Enclosure

### Sonos Play:5 (Gen 1)
- Power supply
- 5× Class-D amplifiers
- 3× tweeters + 3× mid-woofers
- Enclosure

## Datasheets

See `docs/datasheets/` for:
- IQaudIO product brief and datasheet (20201209_IQaudIO_v32.pdf)
- DigiAMP+ HAT product brief (digiamp-plus-hat-product-brief.pdf)
