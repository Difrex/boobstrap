DESTDIR =
BINDIR = /usr/bin
ETCDIR = /etc
SHAREDIR = /usr/share

VERSION = 1.0
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
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkbootstrap
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkinitramfs
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkbootisofs

clean:
	rm -f boobstrap

arch-pkg:
	cd $(DISTRO_PACKAGES_DIR)/$(ARCH_DIR) && makepkg -s
