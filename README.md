# 🚀 GCP VPS Monitor  
*A real-time terminal dashboard for Google Cloud VPS resources.*  

## ✨ Features  
- **CPU**: Usage, load avg, core count  
- **Memory**: RAM + Swap usage  
- **Disk**: Root FS + Inodes  
- **Network**: Public + Internal IP  
- **UI**: Colorful, easy-to-read output  

## 🛠️ Installation  
```bash
# One-liner (run directly):
curl -s https://raw.githubusercontent.com/dukesilvercrypto/gcp-vps-monitor/main/gcp_status.sh | bash

```bash
# Install as a global command:
sudo curl -o /usr/local/bin/gcpstatus https://raw.githubusercontent.com/dukesilvercrypto/gcp-vps-monitor/main/gcp_status.sh
sudo chmod +x /usr/local/bin/gcpstatus
gcpstatus  # Run anytime!
