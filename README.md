# Neptune Radar Linux

This repository contains the Ubuntu/Linux build of Neptune Radar.

## Requirements

- Ubuntu 22.04 LTSC
- 1 vCPU core
- 4 GB RAM (maybe less will work but I didn't test)
- 50 GB NVMe disk space
- Internet access during install
- `sudo` access

The installer will install Node.js 24 and required packages automatically.

## Default Install Path

```bash
/opt/neptune-radar
```

## One-Command Install from GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/pubgdma/NEPTUNE-RADAR-LINUX/main/install-from-github.sh | sudo bash
```

This installer will:

- download the radar files
- install Node.js 24 if needed
- install the radar into `/opt/neptune-radar`
- create the `neptune-radar` systemd service
- enable the service
- start the service immediately
- run a local health check

After a Linux reboot, the radar will start automatically.

## Radar Address

In Neptune under Web Radar options:

- IP: `YOUR_VPS_IP`
- Port: `7823`

Click `Connect Web Radar`.

Open your browser and go to:

```bash
http://YOUR_VPS_IP:7823
```

## Update Radar

To update the installed radar files from GitHub:

```bash
cd /opt/neptune-radar
sudo ./update-radar.sh
```

The updater will:

- check GitHub for file changes
- show `You're running the latest version.` if nothing changed
- ask whether you want to update if changes are found
- download only changed files
- remove files that no longer exist in the repo
- restart the `neptune-radar` service when run as root
To update the installed radar files from GitHub:

```bash
cd /opt/neptune-radar
sudo ./update-radar.sh
```

The updater will:

- check GitHub for file changes
- show `You're running the latest version.` if nothing changed
- ask whether you want to update if changes are found
- download only changed files
- remove files that no longer exist in the repo
- restart the `neptune-radar` service when run as root
