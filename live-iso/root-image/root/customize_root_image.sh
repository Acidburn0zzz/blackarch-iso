#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

#useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh arch

chmod 750 /etc/sudoers.d
chmod 440 /etc/sudoers.d/g_wheel

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

systemctl enable pacman-init.service choose-mirror.service

### blackarch related ###

# create the user directory for live session
if [ ! -d /root ]
then
	mkdir /root && chown root /root
fi

# copy files over to home
su -c "cp -r /etc/skel/.* /root/" root

# setup repository, add pacman.conf entry and sync databse
su -c 'curl -s http://blackarch.org/strap.sh | sh' root
su -c "echo '[blackarch]' >> /etc/pacman.conf" root
su -c "echo 'Server = http://www.blackarch.org/blackarch/\$repo/os/\$arch' >> /etc/pacman.conf" root
su -c 'pacman -Syyu --noconfirm' root

# fix wrong permissions for blackarch-dwm
su -c 'chmod 755 /usr/bin/blackarch-dwm'

# blackarch-install (dev version)
su -c 'rm -rf /usr/share/blackarch-install-scripts' root
su -c 'cd /usr/share/; git clone https://github.com/BlackArch/blackarch-install-scripts' root
su -c 'cp /usr/share/doc/blackarch-install-scripts/blackarch-install.txt /root/' root
su -c 'rm -rf /root/install.txt' root

# sync pkgfile database
su -c 'pkgfile --update' root

# default shell
su -c 'usermod -s /bin/bash root' root

# disable pc speaker beep
su -c 'echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf' root

# download and install exploits
#su -c 'sploitctl -f 0 -n -v' root

# temporary fixes for ruby based tools
#su -c 'cd /usr/share/metasploit/ && bundle-1.9 install' root
#su -c 'cd /usr/share/arachni/ && bundle install' root
#su -c 'cd /usr/share/wpscan/ && bundle-1.9 install --without test development' root
#su -c 'cd /usr/share/smbexec/ && bundle install' root
