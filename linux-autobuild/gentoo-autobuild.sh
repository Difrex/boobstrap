#!/bin/bash

configure() {

	echo -e "toor\ntoor" | (passwd)

	cat > /etc/portage/make.conf <<"EOF"
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
COMMON_FLAGS="-O2 -march=x86-64 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# NOTE: This stage was built with the bindist Use flag enabled
PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C

MAKEOPTS="-j20"
EOF

	cat > /etc/portage/package.license <<"EOF"
sys-kernel/linux-firmware linux-fw-redistributable no-source-code
EOF

	emerge-webrsync

	emerge --deep --with-bdeps=y --changed-use --update @system @world

	emerge gentoo-kernel-bin
	emerge linux-firmware

	emerge vim

}

main() {
	local MIRROR_URL="http://mirror.yandex.ru/gentoo-distfiles"
	local AUTOBUILD_URL
	local WORKDIR

	WORKDIR=$(mktemp -d -p /mnt/tmp)

	mkdir $WORKDIR/chroot

	wget -P $WORKDIR $MIRROR_URL/releases/amd64/autobuilds/latest-stage3-amd64.txt

	AUTOBUILD_URL=$MIRROR_URL/releases/amd64/autobuilds/$(tail -n 1 $WORKDIR/latest-stage3-amd64.txt | cut -d ' ' -f 1)

	wget -P $WORKDIR $AUTOBUILD_URL
	tar -x -J -f $WORKDIR/${AUTOBUILD_URL##*/} -C $WORKDIR/chroot

	install -D -m 0755 "$0" $WORKDIR/chroot/configure
	install -D -m 0644 /etc/resolv.conf $WORKDIR/chroot/etc/resolv.conf
	mount -R /proc $WORKDIR/chroot/proc
	mount -R /sys $WORKDIR/chroot/sys
	mount -R /dev $WORKDIR/chroot/dev

	chroot $WORKDIR/chroot /bin/bash -c "/bin/su - -c /configure"

	umount -R $WORKDIR/chroot/proc
	umount -R $WORKDIR/chroot/sys
	umount -R $WORKDIR/chroot/dev

	mkdir $WORKDIR/bootimage
	mkdir $WORKDIR/bootimage/boot

	cp $WORKDIR/chroot/boot/vmlinuz-* $WORKDIR/bootimage/boot/vmlinuz

	mkdir $WORKDIR/initramfs

	mkinitramfs $WORKDIR/initramfs \
		--overlay $WORKDIR/chroot \
		--command "mksquashfs {source} {destination} -b 1048576 -comp xz -Xdict-size 100%" \
		--output $WORKDIR/initrd.img

	mv $WORKDIR/initrd.img $WORKDIR/bootimage/boot/initrd

	mkbootisofs $WORKDIR/bootimage > $WORKDIR/bootimage.iso
	
	scp $WORKDIR/bootimage.iso root@dl.voglea.com:/mnt/www/dist/gentoo_gnulinux/amd64/current/gentoo-amd64-userfriendly.iso

	# rm -rf $WORKDIR
}

case "${0##*/}" in
	"configure") configure ; exit 0 ;;
esac

main "$@"
