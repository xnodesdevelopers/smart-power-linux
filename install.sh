#!/bin/bash

echo "Starting Zero-Bloat Smart Power Profile Installation..."

# 1. Masking conflicting power daemons
echo "Disabling and masking power-profiles-daemon..."
sudo systemctl disable --now power-profiles-daemon 2>/dev/null
sudo systemctl mask power-profiles-daemon 2>/dev/null

# 2. Creating the automation script
echo "Creating the power management script at /usr/local/bin/smart-auto-profile..."
sudo tee /usr/local/bin/smart-auto-profile > /dev/null <<'EOF'
#!/bin/bash

PROFILE="/sys/firmware/acpi/platform_profile"
INTERVAL=5

if [ ! -w "$PROFILE" ]; then
    logger -t smart-auto-profile "ERROR: ACPI platform profile unavailable"
    exit 1
fi

current="quiet"

medium_time=0
high_time=0
low_time=0

set_profile() {
    local profile="$1"
    local actual
    actual=$(cat "$PROFILE" 2>/dev/null)

    if [ "$actual" != "$profile" ]; then
        if echo "$profile" > "$PROFILE"; then
            logger -t smart-auto-profile "Profile -> $profile"
        else
            logger -t smart-auto-profile "ERROR: Failed to set -> $profile"
            return 1
        fi
    fi
    current="$profile"
}

get_cpu_usage() {
    awk '/^cpu / {
        idle=$5+$6
        total=$2+$3+$4+$5+$6+$7+$8+$9
        print total, idle
        exit
    }' /proc/stat
}

set_profile quiet
read total1 idle1 < <(get_cpu_usage)
sleep "$INTERVAL"

while true; do
    read total2 idle2 < <(get_cpu_usage)
    total_diff=$((total2 - total1))
    idle_diff=$((idle2 - idle1))

    if [ "$total_diff" -gt 0 ]; then
        usage=$((100 * (total_diff - idle_diff) / total_diff))
    else
        usage=0
    fi

    total1=$total2
    idle1=$idle2

    case "$current" in
        quiet)
            if [ "$usage" -ge 35 ]; then medium_time=$((medium_time + INTERVAL)); else medium_time=0; fi
            if [ "$medium_time" -ge 30 ]; then
                current="balanced"; medium_time=0; high_time=0; low_time=0
            fi
            ;;
        balanced)
            if [ "$usage" -ge 70 ]; then high_time=$((high_time + INTERVAL)); else high_time=0; fi
            if [ "$usage" -lt 25 ]; then low_time=$((low_time + INTERVAL)); else low_time=0; fi
            
            if [ "$high_time" -ge 30 ]; then
                current="performance"; high_time=0; low_time=0; medium_time=0
            elif [ "$low_time" -ge 60 ]; then
                current="quiet"; high_time=0; low_time=0; medium_time=0
            fi
            ;;
        performance)
            if [ "$usage" -lt 55 ]; then low_time=$((low_time + INTERVAL)); else low_time=0; fi
            if [ "$low_time" -ge 60 ]; then
                current="balanced"; low_time=0; high_time=0; medium_time=0
            fi
            ;;
        *)
            current="quiet"; medium_time=0; high_time=0; low_time=0
            ;;
    esac

    set_profile "$current"
    sleep "$INTERVAL"
done
EOF

sudo chmod 755 /usr/local/bin/smart-auto-profile

# 3. Creating the systemd service
echo "Creating systemd service..."
sudo tee /etc/systemd/system/smart-auto-profile.service > /dev/null <<'EOF'
[Unit]
Description=Automatic Smart Quiet Balanced Performance profile
After=local-fs.target
Before=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/smart-auto-profile
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 4. Starting the service
echo "Reloading systemd and enabling the service..."
sudo systemctl daemon-reload
sudo systemctl enable --now smart-auto-profile.service

echo "Installation Complete! Let's check the status:"
echo "---------------------------------------------------"
sleep 2
systemctl status smart-auto-profile.service --no-pager
echo "---------------------------------------------------"
echo "Current Hardware Profile: $(cat /sys/firmware/acpi/platform_profile)"
echo "---------------------------------------------------"
echo "Engineered by Sanku (Tharindu Liyanage)"
echo ""
