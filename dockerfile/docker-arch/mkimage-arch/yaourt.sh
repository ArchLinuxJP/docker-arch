#!/usr/bin/env bash
# Generate a minimal filesystem for archlinux and load it into the local
# docker as "archlinuxjp"
# requires root
set -e

hash pacstrap &>/dev/null || {
  echo "Could not find pacstrap. Run pacman -S arch-install-scripts"
  exit 1
}

hash expect &>/dev/null || {
  echo "Could not find expect. Run pacman -S expect"
  exit 1
}


export LANG="C.UTF-8"

ROOTFS=$(mktemp -d ${TMPDIR:-/var/tmp}/rootfs-archlinux-XXXXXXXXXX)
chmod 755 $ROOTFS

# packages to ignore for space savings
PKGIGNORE=(
    cryptsetup
    device-mapper
    dhcpcd
    iproute2
    jfsutils
    linux
    lvm2
    man-db
    man-pages
    mdadm
    nano
    netctl
    openresolv
    pciutils
    pcmciautils
    reiserfsprogs
    s-nail
    systemd-sysvcompat
    usbutils
    vi
    xfsprogs
)
IFS=','
PKGIGNORE="${PKGIGNORE[*]}"
unset IFS

PACMAN_CONF='./mkimage-arch-pacman.conf'
PACMAN_MIRRORLIST="Server = http://ftp.tsukuba.wide.ad.jp/Linux/archlinux/\$repo/os/\$arch\nServer = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/\$repo/os/\$arch"
YAOURT="[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/\$arch"
SUDO="Defaults env_keep += \"http_proxy\"\nDefaults env_keep += \"https_proxy\"\nDefaults env_keep += \"ftp_proxy\"\nyaourt ALL = (root) NOPASSWD: /usr/bin/pacman"
PACMAN_EXTRA_PKGS=''
EXPECT_TIMEOUT=200
ARCH_KEYRING=archlinux
DOCKER_IMAGE_NAME=archlinuxjp/archlinux-yaourt

export PACMAN_MIRRORLIST

expect <<EOF
  set send_slow {1 .1}
  proc send {ignore arg} {
    sleep .1
    exp_send -s -- \$arg
  }
  set timeout $EXPECT_TIMEOUT

  spawn pacstrap -C $PACMAN_CONF -c -d -G -i $ROOTFS base sudo yaourt haveged $PACMAN_EXTRA_PKGS --ignore $PKGIGNORE
  expect {
    -exact "anyway? \[Y/n\] " { send -- "n\r"; exp_continue }
    -exact "(default=all): " { send -- "\r"; exp_continue }
    -exact "installation? \[Y/n\]" { send -- "y\r"; exp_continue }
    -exact "delete it? \[Y/n\]" { send -- "y\r"; exp_continue }
  }
EOF

arch-chroot $ROOTFS /bin/sh -c 'rm -r /usr/share/man/*'
arch-chroot $ROOTFS /bin/sh -c "haveged -w 1024; pacman-key --init; pkill haveged; pacman -Rs --noconfirm haveged;pacman-key --populate $ARCH_KEYRING; pkill gpg-agent"
arch-chroot $ROOTFS /bin/sh -c "ln -s /usr/share/zoneinfo/JST /etc/localtime"
echo -e "en_US.UTF-8 UTF-8\nja_JP.UTF-8 UTF-8" > $ROOTFS/etc/locale.gen
arch-chroot $ROOTFS locale-gen
arch-chroot $ROOTFS /bin/sh -c 'echo -e $PACMAN_MIRRORLIST > /etc/pacman.d/mirrorlist'
arch-chroot $ROOTFS /bin/sh -c "echo -e \"$SUDO\" >> /etc/sudoers.d/yaourt"
arch-chroot $ROOTFS /bin/sh -c "groupadd -r yaourt
	useradd -r -g yaourt yaourt
	mkdir -p /tmp/yaourt
	mkdir -p /home/yaourt
	chown -R yaourt:yaourt /tmp/yaourt
	chown -R yaourt:yaourt /home/yaourt"

# udev doesn't work in containers, rebuild /dev
DEV=$ROOTFS/dev
rm -rf $DEV
mkdir -p $DEV
mknod -m 666 $DEV/null c 1 3
mknod -m 666 $DEV/zero c 1 5
mknod -m 666 $DEV/random c 1 8
mknod -m 666 $DEV/urandom c 1 9
mkdir -m 755 $DEV/pts
mkdir -m 1777 $DEV/shm
mknod -m 666 $DEV/tty c 5 0
mknod -m 600 $DEV/console c 5 1
mknod -m 666 $DEV/tty0 c 4 0
mknod -m 666 $DEV/full c 1 7
mknod -m 600 $DEV/initctl p
mknod -m 666 $DEV/ptmx c 5 2
ln -sf /proc/self/fd $DEV/fd

tar --numeric-owner --xattrs --acls -C $ROOTFS -c . | docker import - $DOCKER_IMAGE_NAME
docker run --rm -t $DOCKER_IMAGE_NAME echo Success.
rm -rf $ROOTFS
