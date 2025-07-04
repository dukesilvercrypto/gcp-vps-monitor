#!/bin/bash

# Color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

# Configuration
SHOW_ITEMS=15
MIN_FILE_SIZE="100M"
TEMP_THRESHOLD=70  # Temperature warning threshold in °C

# Check for sudo privileges early
HAS_SUDO=false
if [ "$(id -u)" -eq 0 ]; then
    HAS_SUDO=true
elif sudo -n true 2>/dev/null; then
    HAS_SUDO=true
fi

# Function to display header
show_header() {
    clear
    echo -e "${PURPLE}"
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════╗"
    echo -e "║ ${BLUE}💻 SYSTEM CHECKER - ALL YOUR STATS IN ONE PLACE! ${CYAN}                   ║"
    echo -e "╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}► Generated: ${GREEN}$(date +"%Y-%m-%d %T")${NC} ${YELLOW}► Hostname: ${GREEN}$(hostname)${NC} ${YELLOW}► Uptime: ${GREEN}$(uptime -p)${NC}"
    echo -e "${YELLOW}► OS: ${GREEN}$(source /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || uname -o)${NC} ${YELLOW}► Kernel: ${GREEN}$(uname -r)${NC} ${YELLOW}► Arch: ${GREEN}$(uname -m)${NC}"
}

# Function to check temperatures
check_temps() {
    echo -e "\n${CYAN}════════ TEMPERATURE MONITORING ════════${NC}"
    local any_temp=0
    
    # CPU Temperature
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        cpu_temp=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))
        color=$([ $cpu_temp -ge $TEMP_THRESHOLD ] && echo "$RED" || echo "$GREEN")
        echo -e "${YELLOW}► CPU Temp: ${color}${cpu_temp}°C${NC}"
        any_temp=1
    fi
    
    # GPU Temperatures (NVIDIA)
    if command -v nvidia-smi &>/dev/null; then
        nvidia_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | head -1)
        color=$([ $nvidia_temp -ge $TEMP_THRESHOLD ] && echo "$RED" || echo "$GREEN")
        echo -e "${YELLOW}► GPU Temp (NVIDIA): ${color}${nvidia_temp}°C${NC}"
        any_temp=1
    fi
    
    # Drive Temperatures
    if command -v smartctl &>/dev/null && [ "$HAS_SUDO" = true ]; then
        for drive in $(lsblk -d -o NAME -n); do
            if [ -e "/dev/${drive}" ]; then
                temp=$(sudo smartctl -A "/dev/${drive}" | grep "Temperature_Celsius" | awk '{print $10}' 2>/dev/null)
                if [ -n "$temp" ]; then
                    color=$([ $temp -ge $TEMP_THRESHOLD ] && echo "$RED" || echo "$GREEN")
                    echo -e "${YELLOW}► Drive ${drive} Temp: ${color}${temp}°C${NC}"
                    any_temp=1
                fi
            fi
        done
    fi
    
    [ $any_temp -eq 0 ] && echo -e "${YELLOW}► No temperature sensors found${NC}"
}

# Function to check battery status (for laptops)
check_battery() {
    echo -e "\n${CYAN}════════ POWER STATUS ════════${NC}"
    if [ -f /sys/class/power_supply/BAT0/capacity ]; then
        bat_level=$(cat /sys/class/power_supply/BAT0/capacity)
        bat_status=$(cat /sys/class/power_supply/BAT0/status)
        color=$([ "$bat_status" = "Charging" ] && echo "$GREEN" || ([ $bat_level -lt 20 ] && echo "$RED" || echo "$YELLOW"))
        echo -e "${YELLOW}► Battery: ${color}${bat_level}% ($bat_status)${NC}"
        
        if [ -f /sys/class/power_supply/BAT0/power_now ]; then
            power=$(($(cat /sys/class/power_supply/BAT0/power_now)/1000000))
            echo -e "${YELLOW}► Power Usage: ${GREEN}${power}W${NC}"
        fi
    else
        echo -e "${YELLOW}► No battery detected (desktop system)${NC}"
    fi
}

# Function to detect GPUs
detect_gpus() {
    echo -e "\n${CYAN}════════ GPU INFORMATION ════════${NC}"
    # NVIDIA
    if command -v nvidia-smi &>/dev/null; then
        nvidia_info=$(nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader | head -1)
        echo -e "${YELLOW}► NVIDIA GPU: ${GREEN}${nvidia_info}${NC}"
    fi
    
    # AMD
    if [ -f /sys/class/drm/card0/device/vendor ] && [ -f /sys/class/drm/card0/device/device ]; then
        amd_vendor=$(cat /sys/class/drm/card0/device/vendor)
        if [[ "$amd_vendor" == *"AMD"* ]]; then
            amd_name=$(cat /sys/class/drm/card0/device/device 2>/dev/null)
            echo -e "${YELLOW}► AMD GPU: ${GREEN}$amd_name${NC}"
        fi
    fi
    
    # Intel
    if command -v intel_gpu_top &>/dev/null; then
        intel_info=$(lspci | grep -i "VGA compatible controller" | grep -i "Intel")
        if [ -n "$intel_info" ]; then
            echo -e "${YELLOW}► Intel GPU: ${GREEN}$intel_info${NC}"
        fi
    fi
}

# Function to show network status
show_network() {
    echo -e "\n${CYAN}════════ NETWORK STATUS ════════${NC}"
    # Public IP
    public_ip=$(curl -s ifconfig.me)
    echo -e "${YELLOW}► Public IP: ${GREEN}$public_ip${NC}"
    
    # Local IP
    local_ip=$(hostname -I | awk '{print $1}')
    echo -e "${YELLOW}► Local IP: ${GREEN}$local_ip${NC}"
    
    # Bandwidth
    if command -v vnstat &>/dev/null; then
        bandwidth=$(vnstat --short)
        echo -e "${YELLOW}► Bandwidth Usage:${NC}\n${GREEN}$bandwidth${NC}"
    fi
}

# Function to show system status
show_system_status() {
    echo -e "\n${CYAN}════════ SYSTEM STATUS ════════${NC}"
    # CPU
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d':' -f2 | sed 's/^ *//')
    echo -e "${YELLOW}► CPU Usage: ${GREEN}$cpu_usage${NC}"
    echo -e "${YELLOW}► CPU Model: ${GREEN}$cpu_model${NC}"
    
    # Memory
    mem_total=$(free -h | grep "Mem:" | awk '{print $2}')
    mem_used=$(free -h | grep "Mem:" | awk '{print $3}')
    mem_percent=$(free | grep "Mem:" | awk '{printf("%.0f"), $3/$2*100}')
    color=$([ $mem_percent -gt 85 ] && echo "$RED" || echo "$GREEN")
    echo -e "${YELLOW}► Memory: ${color}${mem_used} used of ${mem_total} (${mem_percent}%)${NC}"
    
    # Swap
    swap_total=$(free -h | grep "Swap:" | awk '{print $2}')
    if [ "$swap_total" != "0B" ]; then
        swap_used=$(free -h | grep "Swap:" | awk '{print $3}')
        swap_percent=$(free | grep "Swap:" | awk '{printf("%.0f"), $3/$2*100}')
        color=$([ $swap_percent -gt 50 ] && echo "$RED" || echo "$GREEN")
        echo -e "${YELLOW}► Swap: ${color}${swap_used} used of ${swap_total} (${swap_percent}%)${NC}"
    fi
    
    # Load Average
    load=$(uptime | awk -F'load average: ' '{print $2}')
    cores=$(nproc)
    echo -e "${YELLOW}► Load Average: ${GREEN}$load${NC} (${cores} cores)"
}

# Enhanced storage analysis function
analyze_storage() {
    echo -e "\n${CYAN}════════ STORAGE ANALYSIS ════════${NC}"
    
    # Overall disk usage for all mounted filesystems
    echo -e "${YELLOW}► Disk Usage Overview:${NC}"
    df -h | awk -v y="$YELLOW" -v g="$GREEN" -v n="$NC" 'NR==1 {printf "  %-15s %-8s %-8s %-8s %-8s %s\n", y $1 n, y $2 n, y $3 n, y $4 n, y $5 n, y $6 n} NR>1 {printf "  %-15s %-8s %-8s %-8s %-8s %s\n", g $1 n, g $2 n, g $3 n, g $4 n, g $5 n, g $6 n}'
    
    # Show the largest volume (by size)
    largest_volume=$(df -h | grep -v "Filesystem" | sort -rh -k2 | head -1 | awk '{print $6 " (" $2 " total, " $5 " used)"}')
    echo -e "\n${YELLOW}► Largest Volume: ${GREEN}$largest_volume${NC}"
    
    # Detailed analysis of root filesystem
    root_usage=$(df -h / | tail -1 | awk '{print $3 " used of " $2 " (" $5 ")"}')
    echo -e "${YELLOW}► Root FS: ${GREEN}$root_usage${NC}"
    
    # Detailed analysis of home filesystem if different from root
    home_usage=$(df -h ~ | tail -1 | awk '{print $3 " used of " $2 " (" $5 ")"}')
    if [ "$(df -h / | tail -1 | awk '{print $6}')" != "$(df -h ~ | tail -1 | awk '{print $6}')" ]; then
        echo -e "${YELLOW}► Home FS: ${GREEN}$home_usage${NC}"
    fi
    
    # Largest directories in home (non-sudo)
    echo -e "\n${YELLOW}► Largest Directories in ~:${NC}"
    du -h --max-depth=1 ~ 2>/dev/null | sort -rh | head -n $SHOW_ITEMS | awk -v g="$GREEN" -v n="$NC" '{printf "  %-10s %s\n", g $1 n, g $2 n}'
    
    # Largest files in home (non-sudo)
    echo -e "\n${YELLOW}► Largest Files in ~ (may take a while):${NC}"
    find ~ -type f -size +$MIN_FILE_SIZE -exec du -h {} + 2>/dev/null | sort -rh | head -n $SHOW_ITEMS | awk -v g="$GREEN" -v n="$NC" '{printf "  %-10s %s\n", g $1 n, g $2 n}'
}

# Function to check docker containers
check_docker() {
    if command -v docker &>/dev/null; then
        echo -e "\n${CYAN}════════ DOCKER STATUS ════════${NC}"
        docker_stats=$(docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>/dev/null | head -n 5)
        
        if [ -n "$docker_stats" ]; then
            echo -e "${YELLOW}► Running Containers: ${GREEN}$(docker ps -q | wc -l)${NC}"
            echo -e "\n${CYAN}Top Container Stats:${NC}"
            echo "$docker_stats" | awk -v y="$YELLOW" -v g="$GREEN" -v n="$NC" 'NR==1 {printf "  %-20s %-10s %-15s %s\n", y $1 n, y $2 n, y $3 n, y $4 n} NR>1 {printf "  %-20s %-10s %-15s %s\n", g $1 n, g $2 n, g $3 n, g $4 n}'
        else
            echo -e "${YELLOW}► No running containers${NC}"
        fi
    fi
}

# Function to check systemd services
check_services() {
    echo -e "\n${CYAN}════════ CRITICAL SERVICES ════════${NC}"
    important_services=("sshd" "nginx" "apache2" "httpd" "mysql" "mariadb" "postgresql" "docker" "ufw" "fail2ban")
    
    for service in "${important_services[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}\."; then
            status=$(systemctl is-active "$service")
            color=$([ "$status" = "active" ] && echo "$GREEN" || echo "$RED")
            echo -e "${YELLOW}► $service: ${color}${status}${NC}"
        fi
    done
}

# Function to check security updates
check_updates() {
    echo -e "\n${CYAN}════════ SECURITY UPDATES ════════${NC}"
    if [ -x /usr/lib/update-notifier/apt-check ]; then
        updates=$(/usr/lib/update-notifier/apt-check 2>&1)
        regular=$(echo "$updates" | cut -d';' -f1)
        security=$(echo "$updates" | cut -d';' -f2)
        
        echo -e "${YELLOW}► Available Updates:${NC}"
        echo -e "  ${YELLOW}Regular:${NC} ${GREEN}$regular${NC}"
        echo -e "  ${YELLOW}Security:${NC} ${security} $([ "$security" -gt 0 ] && echo "$RED(Important!)" || echo "$GREEN(Good)")${NC}"
    elif command -v yum &>/dev/null; then
        security_updates=$(yum updateinfo list security 2>/dev/null | grep -c "RHSA")
        echo -e "${YELLOW}► Security Updates: ${GREEN}$security_updates${NC}"
    else
        echo -e "${YELLOW}► Update check not supported on this system${NC}"
    fi
}

# Function to check login history
check_logins() {
    echo -e "\n${CYAN}════════ LOGIN HISTORY ════════${NC}"
    echo -e "${YELLOW}► Recent Logins:${NC}"
    last -n 5 | grep -v "reboot" | awk '{printf "  %-12s %-10s %-15s %s\n", $1, $3, $4, $5}'
    
    if [ "$HAS_SUDO" = true ]; then
        echo -e "\n${YELLOW}► Failed Logins:${NC}"
        sudo grep "authentication failure" /var/log/auth.log 2>/dev/null | tail -n 3 | awk -F': ' '{print "  " $2}'
    fi
}

# Function to check kernel messages
check_kernel() {
    echo -e "\n${CYAN}════════ KERNEL MESSAGES ════════${NC}"
    dmesg -T | tail -n 5 | awk -v y="$YELLOW" -v n="$NC" '{print "  " y $1 n " " $2 " " $3 " " $4 " " $5 " " $6}'
}

# Function to check memory hogs
check_memory_hogs() {
    echo -e "\n${CYAN}════════ MEMORY HOGS ════════${NC}"
    ps -eo pid,user,%mem,command --sort=-%mem | head -n 6 | awk -v y="$YELLOW" -v g="$GREEN" -v n="$NC" 'NR==1 {printf "  %-8s %-12s %-8s %s\n", y $1 n, y $2 n, y $3 n, y $4 n} NR>1 {printf "  %-8s %-12s %-8s %s\n", g $1 n, g $2 n, g $3 n, g $4 n}'
}

# Function to check CPU hogs
check_cpu_hogs() {
    echo -e "\n${CYAN}════════ CPU HOGS ════════${NC}"
    ps -eo pid,user,%cpu,command --sort=-%cpu | head -n 6 | awk -v y="$YELLOW" -v g="$GREEN" -v n="$NC" 'NR==1 {printf "  %-8s %-12s %-8s %s\n", y $1 n, y $2 n, y $3 n, y $4 n} NR>1 {printf "  %-8s %-12s %-8s %s\n", g $1 n, g $2 n, g $3 n, g $4 n}'
}

# Function to check zombie processes
check_zombies() {
    zombies=$(ps aux | awk '{print $8}' | grep -c Z)
    if [ "$zombies" -gt 0 ]; then
        echo -e "\n${RED}════════ ZOMBIE PROCESSES DETECTED! ════════${NC}"
        ps aux | awk '$8=="Z" {print $0}' | head -n 3
    fi
}

# Function to check listening ports
check_listening_ports() {
    echo -e "\n${CYAN}════════ LISTENING PORTS ════════${NC}"
    ss -tulnp | awk -v y="$YELLOW" -v g="$GREEN" -v n="$NC" 'NR==1 {printf "  %-7s %-20s %-20s %s\n", y $1 n, y $4 n, y $5 n, y $6 n} NR>1 {printf "  %-7s %-20s %-20s %s\n", g $1 n, g $4 n, g $5 n, g $6 n}'
}

# Function to check system logs
check_system_logs() {
    echo -e "\n${CYAN}════════ SYSTEM LOGS ════════${NC}"
    if [ "$HAS_SUDO" = true ]; then
        echo -e "${YELLOW}► Recent System Errors:${NC}"
        sudo journalctl -p 3 -xb --no-pager | tail -n 3 | sed 's/^/  /'
    else
        echo -e "${YELLOW}► System logs require sudo privileges${NC}"
    fi
}

# Function to show quick commands
show_quick_commands() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════╗"
    echo -e "║ ${BLUE}🔧 QUICK COMMANDS - WHEN IN DOUBT, TRY THESE! ${CYAN}       ║"
    echo -e "╚════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}► ${GREEN}htop${NC}            Interactive process viewer"
    echo -e "${YELLOW}► ${GREEN}glances${NC}         All-in-one system monitor"
    echo -e "${YELLOW}► ${GREEN}nvitop${NC}          GPU + process monitoring"
    echo -e "${YELLOW}► ${GREEN}ncdu${NC}            Disk usage analyzer"
    echo -e "${YELLOW}► ${GREEN}iftop${NC}           Network traffic monitor"
    echo -e "${YELLOW}► ${GREEN}iotop${NC}           Disk I/O monitor"
    echo -e "${YELLOW}► ${GREEN}journalctl -xe${NC}  View system logs"
    echo -e "${YELLOW}► ${GREEN}dmesg -w${NC}        Watch kernel messages"
    echo -e "\n${PURPLE}$(date '+%Y-%m-%d %H:%M:%S')${NC} | ${CYAN}System Checker${NC} | ${RED}Developed by Duke Silver ⚙️ | Alpha Madness ☠️${NC}"
}

# Main execution
show_header
check_temps
check_battery
detect_gpus
show_network
show_system_status
analyze_storage
check_docker
check_services
check_updates
check_logins
check_kernel
check_memory_hogs
check_cpu_hogs
check_zombies
check_listening_ports
check_system_logs
show_quick_commands
