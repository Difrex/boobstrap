#!/bin/bash

configure() {

	cat > /etc/portage/make.conf <<"EOF"
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
COMMON_FLAGS="-O2 -march=x86-64 -pipe"
CFLAGS="\${COMMON_FLAGS}"
CXXFLAGS="\${COMMON_FLAGS}"
FCFLAGS="\${COMMON_FLAGS}"
FFLAGS="\${COMMON_FLAGS}"

# NOTE: This stage was built with the bindist Use flag enabled
PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C

MAKEOPTS="-j\$(nproc)"
EOF

	emerge-webrsync

	emerge --deep --with-bdeps=y --changed-use --update @system @world

	emerge sys-kernel/gentoo-sources sys-kernel/linux-firmware

	emerge vim

}

main() {
	local MIRROR_URL="http://mirror.yandex.ru/gentoo-distfiles"
	local WORKDIR
	local AUTOBUILD_URL

	WORKDIR=$(mktemp -d -p /mnt/tmp)

	mkdir $WORKDIR/chroot

	wget -P $WORKDIR $MIRROR_URL/releases/amd64/autobuilds/latest-stage3-amd64.txt

	AUTOBUILD_URL=$MIRROR_URL/releases/amd64/autobuilds/$(tail -n 1 $WORKDIR/latest-stage3-amd64.txt | cut -d ' ' -f 1)

	wget -q -O - $AUTOBUILD_URL | tar -x -J -C $WORKDIR/chroot

	install -D -m 0644 /etc/resolv.conf $WORKDIR/chroot/etc/resolv.conf
	mount -R /proc $WORKDIR/chroot/proc
	mount -R /dev $WORKDIR/chroot/dev
	mount -R /sys $WORKDIR/chroot/sys

	install -D -m 0755 "$0" $WORKDIR/chroot/configure

	chroot $WORKDIR/chroot /bin/bash -c "/bin/su - -c /configure"

	mkdir $WORKDIR/initramfs

	mkinitramfs $WORKDIR/initramfs \
		--overlay $WORKDIR/chroot \
		--command "mksquashfs {source} {destination} -b 1048576 -comp xz -Xdict-size 100%" \
		--output $WORKDIR/initrd.img

	mkdir $WORKDIR/bootimage
	mkdir $WORKDIR/bootimage/boot

	cp $WORKDIR/chroot/boot/vmlinuz-* $WORKDIR/bootimage/boot/vmlinuz
	mv $WORKDIR/initrd.img $WORKDIR/bootimage/boot/initrd.img

	mkbootisofs $WORKDIR/bootimage > $WORKDIR/bootimage.iso
	
	install -D $WORKDIR/bootimage.iso /mnt/www/dist/gentoo_gnulinux/amd64/current/gentoo-amd64-userfriendly.iso

	# rm -rf $WORKDIR
}

case "${0##*/}" in
	"configure") configure ; exit 0 ;;
esac

main "$@"
