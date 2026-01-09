# ClamAV Docker-Based Malware Scanning

This project provides a **containerized ClamAV malware scanning solution** designed for
Linux servers (NAT / Application / Monitoring / Database nodes).

The solution avoids host-level ClamAV installation issues (e.g. OpenSSL ABI conflicts)
by running scans inside an official ClamAV Docker container.

---

## ✨ Features

- 🐳 Uses **official `clamav/clamav` Docker image**
- 🔒 Host filesystem mounted **read-only** during scan
- 📝 Daily scan logs with **START / END timestamps**
- ⏱ Long-running scans visible immediately via pre-scan logs
- 🔁 Automated scheduling via `cron`
- 🧾 Audit & compliance ready (PCI DSS / ISO 27001 friendly)
- 🚫 No ClamAV or OpenSSL dependency on host OS

---

## 📁 Files

| Path | Description |
|---|---|
| `/opt/clam-av/clamav_docker_setup.sh` | One-time setup & deployment script |
| `/usr/local/bin/clamav_docker_scan.sh` | Actual scan script (auto-generated) |
| `/etc/cron.d/clamav_scan` | Daily cron job |
| `/var/log/clamav/` | Scan logs directory |

---

## ⚙️ Requirements

- Linux server
- Docker installed and running
- Root or sudo privileges

---

## 🚀 Installation

### 1. Clone or copy the setup script
```bash
mkdir -p /opt/clam-av
nano /opt/clam-av/clamav_docker_setup.sh
```

Paste the setup script contents into the file.

---

### 2. Run setup
```bash
chmod +x /opt/clam-av/clamav_docker_setup.sh
/opt/clam-av/clamav_docker_setup.sh
```

This will:
- Create `/usr/local/bin/clamav_docker_scan.sh`
- Configure daily cron job (03:30)
- Prepare log directory `/var/log/clamav`

---

## ▶️ Manual Test

Run a scan manually:
```bash
/usr/local/bin/clamav_docker_scan.sh
```

Watch the log:
```bash
tail -f /var/log/clamav/scan-$(date +%F).log
```

---

## 🕒 Cron Schedule

Default schedule:
```
30 3 * * *
```

Configured in:
```
/etc/cron.d/clamav_scan
```

---

## 📄 Log Example

```
==================================================
ClamAV Scan START
Host      : nat-gw-app.example.com
Start Time: 2026-01-09 22:46:29
Mode      : Docker (read-only filesystem)
Log File  : scan-2026-01-09.log
==================================================

Known viruses: 3627110
Scanned directories: 6596
Scanned files: 35525
Infected files: 0
Data scanned: 7.70 GiB
Time: 2369.393 sec

==================================================
ClamAV Scan END
End Time: 2026-01-09 23:25:58
==================================================
```

---

## 🔐 Security Design

- Host filesystem mounted as **read-only**
- Logs mounted separately as **read-write**
- No persistent container left behind (`--rm`)
- No privileged container access

---

## 🧾 Compliance Notes

This solution supports:
- PCI DSS Requirement 5 (Malware Protection)
- ISO/IEC 27001 A.12.2 (Protection from Malware)

Suggested audit statement:
> Malware protection is implemented using a containerized ClamAV scanning model.
> Scans are executed daily with read-only filesystem access, and results are logged
> and retained for security monitoring and audit review.

---

## 🧹 Cleanup / Re-deploy

To re-install or update:
```bash
rm -f /usr/local/bin/clamav_docker_scan.sh
/opt/clam-av/clamav_docker_setup.sh
```

---

## 📌 Notes

- Designed for servers with **small or large filesystems**
- NAT / Gateway nodes may complete scans very quickly due to minimal files
- No alerts are sent by default (can be integrated with SIEM later)

---

## 📈 Future Enhancements (Optional)

- Wazuh / SIEM integration
- Email or Slack alerts on detection
- Ansible role for fleet-wide deployment
- Log retention & rotation

---

## 📝 License

MIT / Internal Use