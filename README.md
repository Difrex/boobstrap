# Boobstrap

GL HF

BOOBSTRAP is a scripts complex for creating bootable GNU/Linux images.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Boobstrap](#boobstrap)
    - [Installation](#installation)
    - [Quick start](#quick-start)
    - [Utilities](#utilities)
        - [mkbootstrap](#mkbootstrap)
        - [exportroot/importroot](#exportrootimportroot)
        - [mkinitramfs](#mkinitramfs)
        - [mkbootisofs](#mkbootisofs)
    - [Use cases](#use-cases)
    - [Friendly Asked Questions](#friendly-asked-questions)

<!-- markdown-toc end -->


So what BOOBSTRAP can do?

1. Installs "chroots" into the directory, it have native CRUX GNU/Linux
support but for other distros BOOBSTRAP just switching to using external
bootstrap-wrappers like pacstrap, debootstrap, so you need to have it
installed. For CRUX GNU/Linux its a simple pkgadd implementation using "tar"
and my pkgadd can only installing packages to the "chroot", nothing else.

2. Creates INITRD images for boot using the host-system environment or can
using standalone directory as INITRD "chroot". INITRD images can including the
full(!!!) system as directory, SquashFS-compressed image and so on... Then you
can share INITRD image via PXE or put it in your "/boot". Also INITRD can
boots to plain SHMFS (TMPFS, RAMFS) or just using Overlay FS with SquashFS.
BOOBSTRAP no uses busybox so if you want a full system in initramfs just use
"--standalone" for creating INITRD from installed "chroot" directory.

For really good INITRD do this step-by-step:

* [ Download official CRUX GNU/Linux ISO ]
* [ Mount it to ./cruxmedia ]

Then run:

* `./boobstrap/bootstrap-templates/crux_gnulinux-embedded/crux_gnulinux-embedded.bbuild`

And now you have "crux_gnulinux-embedded.rootfs" with ~160MB++ size.

* `./boobstrap/bootstrap-templates/crux_gnulinux-initrd/crux_gnulinux-initrd.bbuild`

And now you have "crux_gnulinux-initrd.rootfs" with ~160MB++ size.
Its a ready to boot INITRD image, but 160MB...

* `xz --check=crc32 --keep --threads=0 --best --verbose crux_gnulinux-initrd.rootfs`

And now you have "crux_gnulinux-initrd.rootfs.xz" with 32MB size!
CRUX GNU/Linux as initramfs with OpenSSH included!
Boot and run "ssh root@host-ip" to login into initramfs! Enjoy!

See bootstrap-templates/ and bootstrap-systems/ for more examples.

Aaaaaand...

3. Creating BIOS and UEFI compatible bootable ISO images. Including created INITRD.
Thats it. Simple.

So...

Just take 3 (three) simple steps and you'll get own bootable GNU/Linux distro!
And then you will be able to boot it via a network (PXE) or CDROM / USB (bootable ISO).

**Written in the pure POSIX shell. Confirmed by "Dash".**

Personally, I am living in tmpfs forever. All my "enterprises" are living in tmpfs.
For example, personally, I use GNU/Linux on my home PC-router with 2GB of RAM.
Yes, my "enterprise" is a PC-router with 2GB RAM running in tmpfs. HA-HA.

* That's cool -- your system is in the tmpfs.
* That's fast -- tmpfs means RAM.
* That's smart -- set up only once, use forever.
* That's secure -- if your system breaks, just push the "RESET" button.
* That's NO backups -- back up only your data, not the system.

Don't be afraid to use "root".

Don't be afraid to break the system.

Don't be afraid to run shell-exploits.

Don't be afraid to do "rm -rf /".

When my system breaks I push the "RESET" button and the system boots again.
-- via PXE or from a USB-flash (ISO).

Software included:

* mkbootstrap -- Install "chroot" with any distro.
* mkinitramfs -- Create an initrd / initramfs image.
* mkbootisofs -- Create a bootable ISO from a directory.
* exportroot -- Creates archive from the "chroot" directory.
* importroot -- Restores "chroot" directory from the archive.

Software dependencies:

* cpio
* grub
* grub-efi
* dosfstools
* squashfs-tools (optional)
* xorriso

Also if you want to use SquashFS / OverlayFS, enable the following in your kernel:

	CONFIG_OVERLAY_FS=y

and

	CONFIG_SQUASHFS=y
	CONFIG_SQUASHFS_XZ=y

But. You can just use tmpfs if you have enough RAM for your system.


## Installation

Generic GNU/Linux
```sh
git clone https://github.com/sp00f1ng/boobstrap.git
cd boobstrap
make install
```

ArchLinux
```sh
git clone https://github.com/sp00f1ng/boobstrap.git
cd boobstrap
make arch-pkg
pacman -U packages/ArchLinux/boobstrap-git-*.pkg.tar.xz
```

## Quick start

Quick Start (just a run test):

```sh
# boobstrap/tests/crux_gnulinux-download-and-build
# qemu-system-x86_64 -enable-kvm -m 1G -cdrom tmp.*/install.iso
```

## Utilities

Now, let's talk about framework utilities.

### mkbootstrap

First, mkbootstrap.

```
# mkbootstrap <system> <directory> [options] [packages]
```

This command installs a "chroot" with the specified distro into a directory.

Where <system> can be:

* crux\_gnulinux (internal)
* archlinux\_gnulinux (external!!!)
* manjaro\_gnulinux (external!!!)
* debian\_gnulinux (external!!!)

> !!! Note: I wrote only crux_gnulinux wrapper, for other distros you must have
> pacstrap, basestrap, debootstrap, and other *straps installed.

crux_gnulinux options:

```
--ports-dir <directory> -- specify directory for search CRUX packages.

[any packages] -- specify packages to install.
```

Example:

1. Download a CRUX iso.
2. Mount it to the "./cruxmedia/"

"./cruxmedia/" contains directories with packages:

"./cruxmedia/crux/core"
"./cruxmedia/crux/opt"
"./cruxmedia/crux/xorg"

Let's install a full "core".

```
# mkbootstrap crux_gnulinux $(mktemp -d) \
    --ports-dir "./cruxmedia/crux/core"
```

Or install only some packages from the specified directories:

```sh
# mkbootstrap crux_gnulinux `mktemp -d`	\
    --ports-dir "./cruxmedia/crux/core"	\
    --ports-dir "./cruxmedia/crux/opt"	\
    "linux" "bash" "iputils"
```

Filenames are allowed:

```sh
# mkbootstrap crux_gnulinux `mktemp -d`	\
    "./linux#5x-1.pkg.tar.xz"			\
    "./cruxmedia/crux/core/bash#5.1-1.pkg.tar.xz"
```

If you choose another distro like debian_gnulinux, you must use "debootstrap"
options. mkbootstrap just switches to use the "debootstrap", nothing else.

### exportroot/importroot

For saving and loading features you can run "exportroot" and "importroot".

You have installed a "chroot" and you want to save the state for future use, run:

```sh
# exportroot "chroot/" > "vanilla-chroot.rootfs"
```

And then, when you want to setup another system from this "chroot/", run:

```sh
# importroot "just-another-chroot/" < "vanilla-chroot.rootfs"
```

It's usable when you only have one system state and many configurations.

Go next.

### mkinitramfs

Second, mkinitramfs.

```sh
# mkinitramfs <directory> [options]
```

This command creates an initrd / initramfs image from the directory.
You can add overlays as well as directories or SquashFS images.

* `--output` "filename" -- filename to output the image. Can output to a STDOUT.
* `--standalone` -- create an initramfs image from the the directory "as is".
* `--overlay` "directory" -- add an overlay from the directory.
  can be used so many times as you want.
* `--command` "command" -- filter what to do with every overlay.
  {SOURCE} -- source directory
  {DESTINATION} -- target directory or image.
  by default: cp -a ${SOURCE} ${DESTINATION}
* `--squashfs-xz` -- apply SquashFS + XZ filter for every overlay.

Example:

Well, we have installed a distro into "chroot/", let's make it bootable into a tmpfs.

```sh
# mkinitramfs $(mktemp -d) \
    --overlay "chroot/"	  \
    --output "initrd"
```

This way the mkinitramfs compiles a "chroot/" directory into an "initrd" image "as is".
After booting it you will get a working "chroot/" in a tmpfs over OverlayFS.

```sh
# mkinitramfs $(mktemp -d) \
    --overlay "chroot/"	   \
    --squashfs-xz		   \
    --output "initrd"
```

This way the mkinitramfs compiles a "chroot/" directory as a SquashFS image.
After booting it you will get a working "chroot/" as a SquashFS with an OverlayFS.
All changes you will do in that system are stored in a tmpfs because the SquashFS is read-only.

You can also specify as many overlays as you want. For example, you can have an overlay
with the system, an overlay with the configuration, an overlay with your home-data, and so on.

```sh
# mkinitramfs $(mktemp -d) \
    --overlay "chroot/"    \
    --overlay "changes/"   \
    --overlay "/home"      \
    --squashfs-xz          \
    --output "initrd"
```

Every overlay will be compressed into a SquashFS image. Without --squash-xz it's
stored as directories, by default mkinitramfs runs the "cp -a" command.
If you want it to use plain tmpfs (my personal preference), - you are welcome.

As an output, you have "initrd" image now. At this moment you can boot it via PXE.
Yes. Boot your full system via PXE up and running in a tmpfs by one initrd. Awesome.

And finally, you can create a bootable ISO image.

### mkbootisofs

Third, mkbootisofs.

mkbootisofs have no options for this usage, just creating a BIOS / UEFI bootable ISO
from the specified directory. You must create it manually, then put a kernel and
an initrd into it.

```sh
# mkdir ./ISO/
# mkdir ./ISO/boot
# cp /boot/vmlinuz ./ISO/boot/vmlinuz
# cp ./initrd ./ISO/boot/initrd
# mkbootisofs ISO/ > bootable.iso
```

Now you can using "dd" to burn it on a USB-flash.

```sh
# dd if=./bootable.iso of=/dev/sdX status=progress
```

I hope you like it!

For more examples how I use this look at the directories:

* bootstrap-templates/
* bootstrap-systems/

Templates - scripts for chroots creation and saving, nothing else.

Systems -- scripts for production-ready images configuration and creation.

For example, run a template script:

```sh
# ./boobstrap/bootstrap-templates/crux_gnulinux-embedded.bbuild
```

You will get a "crux_gnulinux-embedded.rootfs" as a lightweight system for embedded use.
Now you can use this template to configure all your embedded systems, adding
some packages, setting up config files, and so on.

So then, run a system script:

```sh
# ./boobstrap/bootstrap-systems/default/crux_gnulinux.bbuild
```

And now you will get a "production-ready" install.iso.

## Use cases

1. Create a configuration once. Save it as a script. Use forever.

   1. Living in tmpfs.
   2. Just reboot upon system breaks.

2. Update; just put a new vmlinuz and initrd to the production server and run:

   # kexec -l /vmlinuz --initrd=/initrd && kexec -e

   to reload new confgiuration "on-the-fly".

   1. Edit it locally.
   2. Reconfigure by one command or a script.
   3. Test on a local QEMU or Bare-Metal.
   4. Upload it to the remote server.
   5. Do a kexec.

3. Upgrade, from an existing GNU/Linux to the same but running in tmpfs.

   1. Create your configuration by one command or a script.
   2. Upload to the remote server (VDS or something).
   3. # kexec -l /vmlinuz --initrd=/initrd
   4. # systemctl kexec (a Debian-like way)
   5. Create your own bootable ISO, upload it via the hoster's control panel.
   6. Boot it every time from your own ISO with your configuration!
   7. Format any existing /dev/vda disks, they are no more needed!
   8. Use the full disk-space as encrypt-data storage, without any OS.

4. Create your own portable GNU/Linux distro! Nuff said.

## Friendly Asked Questions

Q: Why boobstrap?
A: I am a white heterosexual man and love women. But they don't love me. =(

GG