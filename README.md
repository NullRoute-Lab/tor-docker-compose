# tor-docker-compose

This repository provides a powerful, privacy-preserving stack combining Tor, multitor, and Psiphon using Docker Compose. It features a Local Automation Strategy and Weekly Cloud Cache Seeding.

## Architecture

*   **multitor2**: A custom load-balancer that manages multiple Tor instances for enhanced performance and reliability.
*   **psiphon2**: A Psiphon instance configured to use `multitor2` as its upstream proxy, circumventing network restrictions.

## Changing Psiphon Region (Location)

- Users can easily change their exit IP location by editing `psiphon/psiphon.config` and modifying the `"EgressRegion"` value.
- Because the pre-seeded cache (`remote_server_list`) is globally cached by our GitHub Actions, changing the region works instantly without needing a new cache.
- Highly recommended 2-letter ISO country codes: `US` (USA), `GB` (UK), `DE` (Germany), `NL` (Netherlands), `FR` (France), `CA` (Canada), `SG` (Singapore), and `JP` (Japan).
- Setting `"EgressRegion": ""` (an empty string) allows Psiphon to auto-select the fastest available region based on ping.
- To apply the changes, simply run: `docker restart psiphon2`

## Keeping Relays Fresh (Automation)

To keep your Tor relays fresh and maintain optimal performance, the `run_local_scan.sh` script automatically scans for unblocked relays based on your specific ISP and restarts MultiTor. This script automates scanning for relays, updating the Tor configuration templates, and restarting `multitor2` gracefully so it picks up the freshly scanned relays. Since users run different Linux distros, you can choose from the two automation options below.

### Option A: Crontab (For Raspberry Pi / Debian / Ubuntu)

This is the simplest method for traditional distros like Raspberry Pi OS, Debian, or Ubuntu.

1.  Open your crontab:
    ```bash
    crontab -e
    ```

2.  Add the following line to run the script automatically every day at 03:30 AM. This includes simple log rotation to prevent infinite log bloat by keeping only the last 500 lines:
    ```bash
    30 3 * * * cd /path/to/your/tor-docker-compose && bash run_local_scan.sh >> local_scan.log 2>&1 && tail -n 500 local_scan.log > temp_scan.log && mv temp_scan.log local_scan.log
    ```
    *(Replace `/path/to/your/tor-docker-compose` with the actual path to your cloned repository.)*

### Option B: Systemd User Timers (For Bluefin / Fedora / Immutable Distros)

Modern immutable distributions (like Bluefin or Fedora Silverblue) typically use systemd instead of cron.

**Step 1:** Create the systemd service file at `~/.config/systemd/user/tor-scan.service`:
```ini
[Unit]
Description=Run Tor Local Relay Scanner
After=network-online.target

[Service]
Type=oneshot
WorkingDirectory=%h/tor-docker-compose
ExecStart=/usr/bin/bash run_local_scan.sh
```

**Step 2:** Create the timer file at `~/.config/systemd/user/tor-scan.timer`:
```ini
[Unit]
Description=Run Tor Local Scan Daily at 03:30

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true

[Install]
WantedBy=timers.target
```

**Step 3:** Reload the systemd daemon and enable the timer (no sudo needed):
```bash
systemctl --user daemon-reload
systemctl --user enable --now tor-scan.timer
```

**Pro-Tip:** Systemd's `journald` natively handles log rotation and disk space management, so you don't need to worry about log bloat. You can safely check your recent logs anytime with:
```bash
journalctl --user -u tor-scan.service -e
```

## Weekly Cloud Cache Seeding

To ensure that new devices can start instantly without encountering the `EstablishTunnelTimeout` error in Psiphon, a GitHub Actions workflow is set up to run every Sunday at midnight (`0 0 * * 0`).

The workflow spins up the stack, lets Psiphon fetch its global node directory, copies the critical cache files (`remote_server_list` and `psiphon.boltdb`) into the `psiphon-seed/` directory, and automatically commits these changes back to the repository.

### GitHub Actions Permissions

For the automated workflow to commit the seeded cache back to your repository, you need to enable specific permissions in your GitHub repository settings:

1.  Go to your repository on GitHub.
2.  Click on **Settings** > **Actions** > **General**.
3.  Scroll down to **Workflow permissions**.
4.  Select **Read and write permissions**.
5.  Check the box for **Allow GitHub Actions to create and approve pull requests**.
6.  Click **Save**.

### Zero-Touch New Device Boot

Thanks to the automated cache seeding, deploying this stack on a new device is completely hands-off.

When you clone this repository and run `docker compose up -d` for the first time, the `psiphon2` container utilizes a smart `entrypoint`. It detects the "cold start" (absence of the existing config) and instantly injects the pre-seeded cache from the `psiphon-seed/` directory into its configuration folder. This allows Psiphon to bypass the initial long bootstrapping process and connect immediately.
