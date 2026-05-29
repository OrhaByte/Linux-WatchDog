<p align="center">
  <img src="dist/assets/watchdog-CErV5-Kq.png" alt="WatchDog Logo" width="160" style="background:#000;border-radius:16px;padding:16px;" />
</p>

<h1 align="center">WatchDog</h1>
<p align="center"><strong>Linux Security Monitoring Daemon</strong></p>
<p align="center">
  <img src="https://img.shields.io/badge/platform-Linux-blue?style=flat-square" />
  <img src="https://img.shields.io/badge/built_with-Rust-orange?style=flat-square" />
  <img src="https://img.shields.io/badge/dashboard-React-61dafb?style=flat-square" />
  <img src="https://img.shields.io/badge/license-GPL--3.0-green?style=flat-square" />
  <img src="https://img.shields.io/badge/Community_Edition-Free_Forever-brightgreen?style=flat-square" />
</p>

---

## What is WatchDog?

WatchDog is a lightweight, always-on **Linux security monitoring daemon** built for servers, VMs, and bare-metal machines. It continuously watches your system for suspicious activity — network anomalies, file tampering, reverse shells, brute-force logins, and more — and surfaces everything through a clean web dashboard with real-time event logs.

Whether you run a single VPS or a fleet of production servers, WatchDog gives you visibility into what is happening on your Linux host without the overhead of enterprise SIEM tools. Configure it once, deploy it as a systemd service, and let it watch silently in the background.

---

## Performance

WatchDog is engineered to have a near-zero footprint so it never competes with your workloads.

| Metric | Typical Value |
|---|---|
| **RAM usage** | < 7 MB |
| **CPU usage** | < 1 % (idle polling loop) |
| **Binary size** | ~ 10 MB (fully static, no runtime deps) |
| **Startup time** | < 1 second |

The daemon is written in **Rust** — no garbage collector, no JVM, no interpreter. Every collector runs as an async task on a single Tokio runtime, sleeping between polls and waking only when work is needed.

---

## Features

### Core (Community Edition — Free Forever)

- **Net Traffic Monitor** — Tracks per-interface byte counters from `/proc/net/dev` and alerts when sustained throughput exceeds a configurable threshold
- **Socket Connection Tracker** — Reads `/proc/net/tcp` to track established outbound connections, deduplicates with first/last-seen timestamps, and alerts on suspicious destination ports
- **Cron Watcher** — Hashes crontab files and directories at startup, then polls for additions, removals, or modifications — a common persistence technique
- **Upload Detector** — Tracks cumulative outbound bytes per remote IP and alerts when the threshold is exceeded, signalling potential data exfiltration
- **File Integrity Monitor (FIM)** — SHA-256 hashes critical files at startup and fires an alert on any modification, deletion, or unexpected new file
- **Port Monitor** — Diffs the TCP LISTEN port set between polls and alerts when a new port opens (potential backdoor) or an expected one closes
- **Web Dashboard** — Secure, session-authenticated React dashboard; view live events, toggle collectors, rotate logs, and manage configuration from a browser
- **Log Rotation** — Built-in daily log rotation with configurable retention period
- **Whitelist** — Per-collector IP/message whitelist to suppress known-good noise

### Pro Edition

- **Reverse Shell Detection**  — Inspects all open sockets via procfs against known reverse-shell signatures and configurable regex patterns
- **SSH Audit**  — Tails the auth log for failed logins and escalates to an alert when brute-force thresholds from a single IP are breached
- **Log Tamper Detection**  — Detects log truncation, inode replacement, and outright deletion — common tactics to hide intrusion evidence
- **Email Alerts**  — SMTP email notifications for ALERT / CRITICAL severity events with HTML-formatted alert emails

---

## Installation

WatchDog ships as a self-contained release folder. No package manager required.

### 1 — Clone the repository

```bash
git clone https://github.com/OrhaByte/Linux-WatchDog.git watchdog
cd watchdog
```

### 2 — Set installer permissions

```bash
chmod +x install.sh
```

### 3 — Run the installer

```bash
sudo ./install.sh
```

The installer will:

- Copy the binary to `/usr/local/bin/watchdog`
- Deploy the dashboard frontend to `/var/www/watchdog/`
- Install the config to `/etc/watchdog/config.json`
- Create the log directory at `/var/log/watchdog/`
- Register and start a **systemd** service

After installation the dashboard is available at `http://127.0.0.1:8081` or your server IP (default credentials: `administrator` / `SecurePass123#` — change immediately in from control panel).

### Managing the service

```bash
sudo systemctl status watchdog      # check status
sudo systemctl restart watchdog     # apply config changes
sudo journalctl -u watchdog -f      # live daemon logs
```

---

## Built With

| Layer | Technology |
|---|---|
| **Daemon / Backend** | [Rust](https://www.rust-lang.org/) · [Tokio](https://tokio.rs/) async runtime · [Axum](https://github.com/tokio-rs/axum) HTTP server |
| **Dashboard / Frontend** | [React 18](https://react.dev/) · [TypeScript](https://www.typescriptlang.org/) · [Vite](https://vitejs.dev/) · [MUI](https://mui.com/) |
| **Cryptography** | AES-256 encrypted config fields; Ed25519 product key signing |
| **Packaging** | Single static binary + pre-built `dist/` folder; no external runtime dependencies |

---

## Pricing

| Plan | Price | What's included |
|---|---|---|
| **Community Edition** | Free forever | All core features · GPL-3.0 licensed · No expiry |
| **Starter** | $59 / year | All Pro features · Email alerts · Priority support |
| **Patron** | $99 / year | Everything in Starter · **Sponsored badge** in the repository |

> Patron sponsors receive a permanent sponsored badge in the WatchDog repository acknowledging their support.

### How to upgrade

1. Pay via **[PayPal](https://www.paypal.com/paypalme/linuxwatchdog)** — select the amount matching your chosen plan ($59 for Starter, $99 for Patron).
2. Send an email to [info@orhabyte.com](mailto:info@orhabyte.com) with your PayPal transaction ID and the machine's instance ID (shown in the dashboard under **Settings → Licence**).
3. You will receive a product key by email, usually within 24 hours.

> **PayPal:** [paypal.me/linuxwatchdog](https://www.paypal.com/paypalme/linuxwatchdog)

---

## License

WatchDog is distributed under the **GNU General Public License v3.0**.  
See [`LICENSE`](LICENSE) for the full text.

> **Community Edition is free forever.** You may use, modify, and redistribute WatchDog under the terms of the GPL-3.0 licence at no cost. Pro features are available through a commercial licence — see the pricing table above.

---

## Credits

Developed and maintained by **OrhaByte Software Labs**.  
© 2026 OrhaByte Software Labs · [info@orhabyte.com](mailto:info@orhabyte.com)

---

## Bug Reports & Support

Found a bug or have a feature request? We welcome contributions and reports.

- **GitHub Issues** — Open an issue at [github.com/orhabyte/watchdog/issues](https://github.com/orhabyte/watchdog/issues)
- **Security vulnerabilities** — Please report security issues privately to [info@orhabyte.com](mailto:info@orhabyte.com) rather than opening a public issue
- **General support** — [info@orhabyte.com](mailto:info@orhabyte.com)

When filing a bug report, please include:

1. Linux distribution and kernel version (`uname -a`)
2. WatchDog binary version (`/usr/local/bin/watchdog --help`)
3. Relevant lines from `sudo journalctl -u watchdog -n 100 --no-pager`
4. Your `config.json` with passwords redacted

---

*WatchDog — because every Linux server deserves a guardian.*
