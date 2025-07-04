# 🚀 Universal System Monitor 
**v2.1** | *Real-time terminal dashboard for Linux, WSL, and Cloud Environments*

![Preview](https://i.imgur.com/ttsqVK6.png)

---

## 🌟 Key Features

### 🖥️ Multi-Environment Support
| Environment  | Detection Capabilities | Special Metrics |
|--------------|------------------------|-----------------|
| **WSL**      | Windows host integration | RAM allocation |
| **GCP**      | Instance metadata | Preemptible status |
| **AWS**      | EC2 metadata | IMDSv2 support |
| **Bare Metal** | Full hardware stats | SMART disk health |

### 🔥 Critical Monitoring

+ CPU: Usage %, temperature, load averages
+ Memory: RAM/swap with leak detection
+ Storage: Filesystem usage + large file scanner
+ Network: Bandwidth, connections, latency
+ Security: Failed logins, pending updates


### 🎨 Smart Display
- Color-coded thresholds (red/yellow/green)
- Adaptive layout for terminal size
- Both quick-glance and detailed views

---

## 🛠️ Installation

### 📦 Package Manager Options
**Debian/Ubuntu:**
```bash
curl -sSL https://raw.githubusercontent.com/dukesilvercrypto/gcp-vps-monitor/main/gcp_status.sh | sudo tee /usr/local/bin/sysmon >/dev/null && sudo chmod +x /usr/local/bin/sysmon
```

**RHEL/CentOS:**
```bash
curl -sSL https://raw.githubusercontent.com/dukesilvercrypto/gcp-vps-monitor/main/gcp_status.sh | sudo tee /usr/bin/sysmon >/dev/null && sudo chmod +x /usr/bin/sysmon
```

### 🏃 Direct Execution
```bash
bash <(curl -sSL https://raw.githubusercontent.com/dukesilvercrypto/gcp-vps-monitor/main/gcp_status.sh)
```

---

## 🎚️ Usage Options

| Command               | Description                          | Output Example |
|-----------------------|--------------------------------------|----------------|
| `sysmon`              | Full interactive dashboard | [Screenshot](#) |
| `sysmon --quick`      | Minimalist single-screen view | `CPU: 24% 62°C` |
| `sysmon --security`   | Security-focused report | `3 failed logins` |
| `sysmon --cloud`      | Enhanced cloud metadata | `GCP: e2-standard-2` |

---

## ⚙️ Configuration
Edit `~/.sysmon.conf`:
```ini
[alerts]
cpu_warning=75    # % threshold
temp_critical=85  # °C threshold
disk_warning=90   # % usage

[modules]
network=true
docker=true
gpu=true
```

---

## 📊 Sample Reports

### 🔧 System Health Snapshot
```text
════════ SYSTEM VITALS ════════
► Host: prod-db-01 (GCP n2-standard-4)  
► Uptime: 18 days, 7:32  
► OS: Ubuntu 22.04 LTS [5.15.0-1034-gcp]  
► Threats: 2 security updates pending

════════ RESOURCES ════════
► CPU: 62% (78°C⚠️) | Load: 3.8/16 cores  
► RAM: 14/16GB (88%⚠️) | Swap: 1.2/4GB  
► Disk: / 98/100GB (98%‼️) | /home 45/200GB  
► GPU: NVIDIA T4 (52°C) 8GB/16GB
```

### 🔍 Security Audit
```bash
sysmon --security
```
```text
════════ SECURITY STATUS ════════
► Logins: 3 failed attempts (last 1h)  
► Updates: 5 pending (2 security)  
► Services:  
  - sshd: active ✅  
  - ufw: inactive ⚠️  
  - fail2ban: not installed ❌  
► Suspicious:  
  - /tmp/.X11-unix (777 permissions)
```

---

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| Missing temperature readings | Install `lm-sensors` and run `sensors-detect` |
| No cloud metadata | Verify IMDS access in AWS/GCP |
| WSL data incomplete | Run Windows host as Admin |

---

## 🤝 Contributing Guide

1. **Feature Branches**:
   ```bash
   git checkout -b feature/amd-gpu-detection
   ```
2. **Testing**:
   ```bash
   ./test_environment.sh --platform=aws
   ```
3. **Style Rules**:
   - 4-space indents
   - `[FEATURE]` prefix in commits
   - ANSI color safety checks

---

## 📜 License
Apache 2.0 - Free for commercial and personal use

---

## 🏆 Credits
**Created by**: Duke Silver  
**Special Thanks**:  
- Linux kernel developers  
- Google Cloud Platform team  
- WSL integration contributors



Key improvements:
1. **Structured feature matrix** with environment support
2. **Multiple installation methods** for different distros
3. **Command examples** with output samples
4. **Real-world configuration** examples
5. **Troubleshooting table** for common issues
6. **Professional contribution guidelines**
7. **Visual separation** of sections
8. **Credits section** for recognition

Would you like me to:
1. Add an **animated terminal demo** GIF?
2. Include **benchmark comparisons**?
3. Add **API documentation** for integrations?
4. Create a **version changelog** section?
