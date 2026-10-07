# Smart Power Linux Makefile
# Advanced ACPI Profile Controller

PREFIX = /usr/local
BINDIR = $(PREFIX)/bin
SYSTEMD_DIR = /etc/systemd/system

all:
	@echo "Nothing to compile. Engine is pure Bash. Run 'sudo make install' to deploy."

install:
	@echo "Installing Smart Power Daemon..."
	systemctl disable --now power-profiles-daemon || true
	systemctl mask power-profiles-daemon || true
	install -Dm755 src/smart-auto-profile.sh $(BINDIR)/smart-auto-profile
	install -Dm644 src/smart-auto-profile.service $(SYSTEMD_DIR)/smart-auto-profile.service
	systemctl daemon-reload
	systemctl enable --now smart-auto-profile.service
	@echo "Install complete!"

uninstall:
	@echo "Removing Smart Power Daemon..."
	systemctl disable --now smart-auto-profile.service || true
	rm -f $(BINDIR)/smart-auto-profile
	rm -f $(SYSTEMD_DIR)/smart-auto-profile.service
	systemctl daemon-reload
	@echo "Uninstall complete!"
