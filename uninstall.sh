#!/bin/bash
# Smart Power Linux - Uninstaller

echo "Purging Smart Power Linux from system..."

sudo systemctl disable --now smart-auto-profile.service
sudo rm -f /usr/local/bin/smart-auto-profile
sudo rm -f /etc/systemd/system/smart-auto-profile.service
sudo systemctl daemon-reload

echo "Unmasking default daemons..."
sudo systemctl unmask power-profiles-daemon

echo "System restored to factory state."
