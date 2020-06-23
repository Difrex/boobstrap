DESTDIR =
BINDIR = /usr/bin
ETCDIR = /etc
SHAREDIR = /usr/share

VERSION = 1.1-rc2
NAME = boobstrap

# Packages directory
DISTRO_PACKAGES_DIR = ./packages

# Distro specific directories
ARCH_DIR = ArchLinux


all: boobstrap

boobstrap: boobstrap.in

.PHONY:	install clean arch-pkg

install: all
	install -D -m 0755 boobstrap.in $(DESTDIR)$(BINDIR)/boobstrap
	install -D -m 0644 boobstrap.conf $(DESTDIR)$(ETCDIR)/boobstrap/boobstrap.conf
	install -D -m 0644 boobstrap.conf $(DESTDIR)$(SHAREDIR)/boobstrap/boobstrap.conf.default
	install -D -m 0644 init.in $(DESTDIR)$(ETCDIR)/boobstrap/init
	install -D -m 0644 init.in $(DESTDIR)$(SHAREDIR)/boobstrap/init.default
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkbootstrap
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkinitramfs
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkbootisofs
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/exportroot
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/importroot
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkoverlayfs

clean:
	rm -f boobstrap

arch-pkg:
	cd $(DISTRO_PACKAGES_DIR)/$(ARCH_DIR) && makepkg -s
