#!/bin/bash

# Color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

# Storage Analyzer Configuration
SCAN_PATH="$HOME"  # Default: User's home directory
SHOW_ITEMS=10       # Number of items to display
MIN_FILE_SIZE="100M"  # Minimum file size to report

# Function to display system status
show_system_status() {
    # Header
    clear
    echo -e "${PURPLE}"
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗"
    echo -e "║ ${BLUE}🚀 GOOGLE CLOUD VPS - COMPREHENSIVE MONITORING TOOL ${CYAN}     ║"
    echo -e "╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}► Generated: ${GREEN}$(date)${NC}"
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
}

# Function to analyze storage
analyze_storage() {
    echo -e "\n${CYAN}════════ STORAGE ANALYSIS ════════${NC}"
    echo -e "${YELLOW}Scanning: ${GREEN}$SCAN_PATH${NC}"
    
    # Top Folders Analysis
    echo -e "\n${CYAN}📂 TOP $SHOW_ITEMS LARGEST FOLDERS ${NC}"
    echo -e "${BLUE}════════════════════════════════════${NC}"
    du -h --max-depth=2 "$SCAN_PATH" 2>/dev/null | sort -rh | grep -v '^[0-9\.]\+K' | head -n $SHOW_ITEMS | awk -v y="$YELLOW" -v n="$NC" '{printf "  %-10s %s%s%s\n", $1, y, $2, n}'

    # Top Files Analysis
    echo -e "\n${CYAN}📄 TOP $SHOW_ITEMS LARGEST FILES (>$MIN_FILE_SIZE) ${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════${NC}"
    find "$SCAN_PATH" -type f -size +"$MIN_FILE_SIZE" -exec du -h {} + 2>/dev/null | sort -rh | head -n $SHOW_ITEMS | awk -v g="$GREEN" -v n="$NC" '{printf "  %-10s %s%s%s\n", $1, g, $2, n}'

    # Summary
    echo -e "\n${CYAN}🔍 STORAGE SUMMARY ${NC}"
    echo -e "${BLUE}══════════════════${NC}"
    echo -e "${YELLOW}Total Folders:${NC} $(find "$SCAN_PATH" -type d | wc -l)"
    echo -e "${YELLOW}Total Files:${NC} $(find "$SCAN_PATH" -type f | wc -l)"
    echo -e "${YELLOW}Total Storage:${NC} $(du -sh "$SCAN_PATH" 2>/dev/null | cut -f1)"
}

# Function to show quick commands
show_quick_commands() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════╗"
    echo -e "║ ${BLUE}🔧 QUICK COMMANDS ${CYAN}                              ║"
    echo -e "╚════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}► ${GREEN}htop${NC}       Process viewer"
    echo -e "${YELLOW}► ${GREEN}nmon${NC}       Advanced monitor"
    echo -e "${YELLOW}► ${GREEN}ncdu /${NC}     Disk analyzer"
    echo -e "${YELLOW}► ${GREEN}glances${NC}    All-in-one stats"
    echo -e "${YELLOW}► ${GREEN}df -h${NC}      Disk space usage"
    echo -e "${YELLOW}► ${GREEN}free -h${NC}    Memory usage"
    echo -e "\n${PURPLE}$(date '+%Y-%m-%d %H:%M:%S')${NC} | ${CYAN}Duke Silver ❤️${NC} | ${YELLOW}$(hostname)${NC}"
}

# Main execution
show_system_status
analyze_storage
show_quick_commands
