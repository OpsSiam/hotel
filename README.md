# Opssiam 1hotel

ชุดสคริปต์ติดตั้ง Node Exporter และตั้งเวลา ClamAV scan ผ่าน Docker

## 1) ติดตั้ง Node Exporter (Docker Compose)

สคริปต์อยู่ที่ `node-exporter/install-node-exporter.sh`

### เงื่อนไข
- ต้องรันด้วยสิทธิ์ root
- ระบบที่ใช้ `dnf` (เช่น CentOS/Rocky/Alma)

### ขั้นตอน (วางไฟล์ไว้ที่ `/usr/local/bin`)
```bash
nano /usr/local/bin/install-node-exporter.sh
chmod +x /usr/local/bin/install-node-exporter.sh
sudo /usr/local/bin/install-node-exporter.sh
```

### ปรับค่า (ถ้าต้องการ)
ในสคริปต์กำหนดตัวแปร:
- `MONITOR_IP="10.10.20.3"` ใช้สำหรับ firewall ให้เปิดพอร์ต 9100 เฉพาะ IP นี้
- `INSTALL_DIR="/opt/node-exporter"`

หลังติดตั้ง Node Exporter จะฟังที่ `:9100`

## 2) ติดตั้ง ClamAV scan ผ่าน Docker (cron)

สคริปต์อยู่ที่ `clam-av/clamav_docker_setup.sh`

### เงื่อนไข
- ต้องติดตั้ง Docker ไว้ก่อน
- ต้องรันด้วยสิทธิ์ root

### ขั้นตอน (วางไฟล์ไว้ที่ `/usr/local/bin`)
```bash
nano /usr/local/bin/clamav_docker_setup.sh
chmod +x /usr/local/bin/clamav_docker_setup.sh
sudo /usr/local/bin/clamav_docker_setup.sh
```

### ค่าเริ่มต้น
- เวลา scan: `30 3 * * *` (ทุกวัน 03:30)
- สคริปต์: `/usr/local/bin/clamav_docker_scan.sh`
- cron: `/etc/cron.d/clamav_scan`
- log: `/var/log/clamav/scan-YYYY-MM-DD.log`

### ทดสอบ manual
```bash
sudo /usr/local/bin/clamav_docker_scan.sh
```
