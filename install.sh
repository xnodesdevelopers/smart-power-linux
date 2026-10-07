#!/bin/bash
# Smart Power Linux - Enterprise Grade Zero-Bloat Installer
# Engineered by Sanku

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}"
cat << "EOF"
  ____                       _     ____                           
 / ___| _ __ ___   __ _ _ __| |_  |  _ \ _____      _____ _ __    
 \___ \| '_ ` _ \ / _` | '__| __| | |_) / _ \ \ /\ / / _ \ '__|   
  ___) | | | | | | (_| | |  | |_  |  __/ (_) \ V  V /  __/ |      
 |____/|_| |_| |_|\__,_|_|   \__| |_|   \___/ \_/\_/ \___|_|      
                                                                  
        [ Advanced ACPI Hysteresis Polling Engine ]               
EOF
echo -e "${NC}"
echo -e "${GREEN}>>> Initializing deployment sequence...${NC}\n"
sleep 1

# Pre-flight check
echo -e "[*] Running ACPI hardware compatibility check..."
if [ ! -w "/sys/firmware/acpi/platform_profile" ]; then
    echo -e "${RED}[!] FATAL: Hardware not supported or missing root privileges.${NC}"
    exit 1
fi
echo -e "${GREEN}[+] Hardware validated.${NC}"
sleep 1

echo -e "[*] Isolating conflicting power daemons (power-profiles-daemon)..."
sudo systemctl disable --now power-profiles-daemon >/dev/null 2>&1
sudo systemctl mask power-profiles-daemon >/dev/null 2>&1
echo -e "${GREEN}[+] Daemons neutralized.${NC}"
sleep 1

echo -e "[*] Compiling zero-bloat engine pathways..."
sudo cp src/smart-auto-profile.sh /usr/local/bin/smart-auto-profile
sudo chmod 755 /usr/local/bin/smart-auto-profile
echo -e "${GREEN}[+] Binary installed to /usr/local/bin/.${NC}"
sleep 1

echo -e "[*] Registering systemd telemetry service..."
sudo cp src/smart-auto-profile.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now smart-auto-profile.service >/dev/null 2>&1
echo -e "${GREEN}[+] Service injected into init system.${NC}"
sleep 1

echo -e "\n${CYAN}====================================================${NC}"
echo -e "${GREEN}✔ Deployment Successful!${NC}"
echo -e "Current Enforced Profile: $(cat /sys/firmware/acpi/platform_profile)"
echo -e "Engineered with deep truth by Sanku (Tharindu Liyanage)"
echo -e "${CYAN}====================================================${NC}\n"
