DESTDIR =
BINDIR = /usr/bin
SHAREDIR = /usr/share

VERSION = 1.0-rc2
NAME = boobstrap

all: boobstrap

boobstrap: boobstrap.in

.PHONY:	install clean

install: all
	install -D -m 0755 boobstrap.in $(DESTDIR)$(BINDIR)/boobstrap
	install -D -m 0755 qemu/qemu $(DESTDIR)$(SHAREDIR)/qemu/qemu
	install -D -m 0755 templates/default $(DESTDIR)$(SHAREDIR)/templates/default
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkbootstrap
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkinitramfs
	ln -sf boobstrap $(DESTDIR)$(BINDIR)/mkbootisofs

clean:
	rm -f boobstrap
