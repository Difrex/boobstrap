DESTDIR =
BINDIR = /usr/bin
SHAREDIR = /usr/share

VERSION = 1.0-rc2
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
	install -D -m 0755 qemu-helper/qemu $(DESTDIR)$(SHAREDIR)/qemu-helper/qemu
	install -D -m 0755 bootstrap-templates/default.bbuild $(DESTDIR)$(SHAREDIR)/bootstrap-templates/default.bbuild
	install -D -m 0755 bootstrap-templates/crux-netboot.bbuild $(DESTDIR)$(SHAREDIR)/bootstrap-templates/crux-netboot.bbuild
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkbootstrap
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkinitramfs
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkbootisofs

clean:
	rm -f boobstrap

arch-pkg:
	cd $(DISTRO_PACKAGES_DIR)/$(ARCH_DIR) && makepkg -s
