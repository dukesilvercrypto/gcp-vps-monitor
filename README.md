# 🚀 GCP VPS Monitor  
*A real-time terminal dashboard for Google Cloud VPS resources.*  

## ✨ Features

- **System Overview**: Hostname, OS, uptime, and GCP metadata
- **CPU Monitoring**: Usage, load averages, temperature, and core count
- **Memory Analysis**: RAM and swap usage with percentages
- **Disk Statistics**: Root filesystem usage and inode counts
- **Network Info**: Public + internal IPs and bandwidth usage
- **Storage Scanner**: Top large files/folders identification
- **GCP Integration**: Automatic instance metadata detection
- **Beautiful UI**: Color-coded, well-organized terminal output 

## 🛠️ Installation  
```bash
# One-liner (run directly):
curl -s https://raw.githubusercontent.com/dukesilvercrypto/gcp-vps-monitor/main/gcp_status.sh | bash

# Install as a global command:
sudo curl -o /usr/local/bin/gcpstatus https://raw.githubusercontent.com/dukesilvercrypto/gcp-vps-monitor/main/gcp_status.sh
sudo chmod +x /usr/local/bin/gcpstatus
gcpstatus  # Run anytime!
