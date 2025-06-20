#!/bin/bash

# Color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

# Header
clear
echo -e "${PURPLE}"
echo -e "${CYAN}╔════════════════════════════════════════════════╗"
echo -e "║ ${BLUE}🚀 GOOGLE CLOUD VPS - REAL-TIME STATUS ${CYAN}          ║"
echo -e "╚════════════════════════════════════════════════╝${NC}"




# System Info
echo -e "${YELLOW}► Hostname: ${NC}$(hostname)"
echo -e "${YELLOW}► OS: ${NC}$(lsb_release -d | cut -f2-)"
echo -e "${YELLOW}► Kernel: ${NC}$(uname -r) $(uname -m)"
echo -e "${YELLOW}► Uptime: ${NC}$(uptime -p) (since $(uptime -s))"

# CPU Section
echo -e "\n${CYAN}════════ CPU CORE LOAD ════════${NC}"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f", 100 - $8}')
echo -e "${YELLOW}► Usage: ${GREEN}${cpu_usage}%${NC}"
echo -e "${YELLOW}► Load Avg: ${NC}$(uptime | awk -F'load average:' '{print $2}' | awk '{printf "%.2f, %.2f, %.2f", $1, $2, $3}')"
echo -e "${YELLOW}► Cores: ${NC}$(nproc)x $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')"

# Memory Section
echo -e "\n${CYAN}════════ MEMORY USAGE ════════${NC}"
echo -e "${YELLOW}► RAM: ${GREEN}$(free -h | awk '/Mem:/ {print $3}')/$(free -h | awk '/Mem:/ {print $2}') ($(free | awk '/Mem:/ {printf "%.1f%%", $3/$2*100}') used)${NC}"
echo -e "${YELLOW}► Available: ${NC}$(free -h | awk '/Mem:/ {print $7}')"
echo -e "${YELLOW}► Swap: ${NC}$(free -h | awk '/Swap:/ {print $3}')/$(free -h | awk '/Swap:/ {print $2}')"

# Disk Section
echo -e "\n${CYAN}════════ STORAGE USAGE ════════${NC}"
echo -e "${YELLOW}► Root FS: ${GREEN}$(df -h / | awk 'NR==2 {print $3}')/$(df -h / | awk 'NR==2 {print $2}') ($(df -h / | awk 'NR==2 {print $5}') used)${NC}"
echo -e "${YELLOW}► Inodes: ${NC}$(df -i / | awk 'NR==2 {print $5}') used ($(df -i / | awk 'NR==2 {print $3}')/$(df -i / | awk 'NR==2 {print $2}'))"

# Network Section
echo -e "\n${CYAN}════════ NETWORK ═══════════${NC}"
echo -e "${YELLOW}► Public IP: ${NC}$(curl -4 -s ifconfig.me || echo 'Not Available')"
echo -e "${YELLOW}► Internal IP: ${NC}$(hostname -I | awk '{print $1}')"

# Footer
echo -e "\n${CYAN}╔════════════════════════════════════════════════╗"
echo -e "║ ${BLUE}🔧 QUICK COMMANDS ${CYAN}                              ║"
echo -e "╚════════════════════════════════════════════════╝${NC}"
echo -e "${YELLOW}► ${GREEN}htop${NC}       Process viewer"
echo -e "${YELLOW}► ${GREEN}nmon${NC}       Advanced monitor"
echo -e "${YELLOW}► ${GREEN}ncdu /${NC}     Disk analyzer"
echo -e "${YELLOW}► ${GREEN}glances${NC}    All-in-one stats"
echo -e "\n${PURPLE}$(date '+%Y-%m-%d %H:%M:%S')${NC} | ${CYAN}Duke Silver ❤️${NC} | ${YELLOW}$(hostname)${NC}"
