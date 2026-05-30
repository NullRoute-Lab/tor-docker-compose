# tor-docker-compose

This repository provides a powerful, privacy-preserving stack combining Tor, multitor, and Psiphon using Docker Compose. It features a Local Automation Strategy and Weekly Cloud Cache Seeding.

## Architecture

*   **multitor2**: A custom load-balancer that manages multiple Tor instances for enhanced performance and reliability.
*   **psiphon2**: A Psiphon instance configured to use `multitor2` as its upstream proxy, circumventing network restrictions.

## Local Automation Strategy

To keep your Tor relays fresh and maintain optimal performance, you can use the `run_local_scan.sh` script. This script automates scanning for relays, updating the Tor configuration templates, and restarting `multitor2` gracefully so it picks up the freshly scanned relays.

### Setting up a Daily Cronjob

On a machine like a Raspberry Pi, you can automate this process by setting up a cronjob.

1.  Make sure the script is executable:
    ```bash
    chmod +x run_local_scan.sh
    ```

2.  Open your crontab:
    ```bash
    crontab -e
    ```

3.  Add the following line to run the script automatically every day at 03:30 AM (e.g., Iran Time):
    ```cron
    30 3 * * * cd /path/to/your/tor-docker-compose && ./run_local_scan.sh >> /var/log/run_local_scan.log 2>&1
    ```
    *(Replace `/path/to/your/tor-docker-compose` with the actual path to your cloned repository.)*

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
