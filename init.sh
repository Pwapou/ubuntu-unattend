#!/bin/bash
#description : install GUI for ubuntu server 14.04 (unity) and remove useless package. this script improve the security with some additionnal package
#You must start the script with root privilege after the installation on your system

set -e

spinner()
{
	local pid=$1
	local delay=0.175
	local spinstr='|/-\'
	local infotext=$2
	tput civis;

	while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
		local temp=${spinstr#?}
		printf " [%c] %s" "$spinstr" "$infotext"
		local spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b\b"

		for i in $(seq 1 ${#infotext}); do
			printf "\b"
		done
	
	done

	printf " \b\b\b\b"
	tput cnorm;
}
PACKAGES_TO_REMOVE="account-plugin-aim account-plugin-facebook account-plugin-flickr account-plugin-google account-plugin-jabber account-plugin-salut account-plugin-twitter account-plugin-windows-live account-plugin-yahoo aisleriot avahi-daemon bluez bluez-alsa bluez-cups brasero brasero-cdrkit brasero-common brltty cheese cheese-common cups cups-browsed cups-bsd cups-client cups-common cups-core-drivers cups-daemon cups-filters cups-filters-core-drivers cups-pk-helper cups-ppdc cups-server-common deja-dup deja-dup-backend-gvfs duplicity dvd+rw-tools empathy empathy-common evince firefox firefox-locale-fr folks-common friends-facebook friends-twitter gcc ghostscript ghostscript-x gir1.2-gnomebluetooth-1.0 gir1.2-gnomekeyring-1.0 gir1.2-rb-3.0 gir1.2-secret-1 gir1.2-totem-1.0 gir1.2-totem-plparser-1.0 gir1.2-udisks-2.0 gnome-bluetooth gnome-contacts gnome-mahjongg gnome-mines gnome-orca gnome-sudoku gnome-user-share gnome-video-effects gnomine growisofs gstreamer0.10-nice gstreamer0.10-plugins-good gstreamer0.10-x gstreamer1.0-clutter gstreamer1.0-nice guile-2.0-libs gvfs-backends hplip indicator-bluetooth indicator-printers landscape-client-ui-install libavahi-gobject0 libbluetooth3 libbrasero-media3-1 libburn4 libc-dev-bin libc6-dev libcdr-0.0-0 libcheese-gtk23 libcheese7 libclutter-1.0-0 libclutter-1.0-common libclutter-gst-2.0-0 libclutter-gtk-1.0-0 libcogl-common libcogl-pango15 libcogl15 libcrypt-passwdmd5-perl libcupscgi1 libcupsfilters1 libcupsimage2 libcupsmime1 libcupsppdc1 libdmapsharing-3.0-2 libevdocument3-4 libevview3-3 libevent-2.0-5 libexiv2-12 libfarstream-0.1-0 libfarstream-0.2-2 libfolks-eds25 libfolks-telepathy25 libfolks25 libgail-common libgail18 libgc1c2 libgexiv2-2 libgmime-2.6-0 libgnome-control-center1 libgpod-common libgpod4 libgs9 libgupnp-igd-1.0-4 libisofs6 libjte1 liblircclient0 liblouis-data liblouis2 libmeanwhile1 libminiupnpc8 libmission-control-plugins0 libmspub-0.0-0 libnatpmp1 libnice10 liborcus-0.6-0 liboxideqt-qmlplugin liboxideqtcore0 liboxideqtquick0 libpurple-bin libpurple0 libqpdf13 libqt5webkit5-qmlwebkitplugin libraw9 libreoffice-avmedia-backend-gstreamer libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-gnome libreoffice-gtk libreoffice-help-fr libreoffice-impress libreoffice-l10n-fr libreoffice-math libreoffice-ogltrans libreoffice-pdfimport libreoffice-presentation-minimizer libreoffice-style-human libreoffice-writer librhythmbox-core8 librsync1 libsgutils2-2 libspectre1 libtelepathy-farstream3 libtelepathy-logger3 libtotem-plparser18 libtotem0 libufe-xidgetter0 libunity-webapps0 libvisio-0.0-0 libvncserver0 libwpd-0.9-9 libwpg-0.2-2 libwps-0.2-2 libzephyr4 make mcp-account-manager-uoa media-player-info modemmanager mythes-fr nautilus-sendto-empathy obex-data-server obexd-client oxideqt-codecs printer-driver-c2esp printer-driver-foo2zjs printer-driver-gutenprint printer-driver-hpcups printer-driver-pnm2ppa printer-driver-postscript-hp printer-driver-ptouch printer-driver-pxljr printer-driver-sag-gdi printer-driver-splix pulseaudio-module-bluetooth python-cups python-cupshelpers python-lockfile python-requests python-urllib3 python3-brlapi python3-louis python3-mako python3-markupsafe python3-pyatspi python3-speechd python3-uno qpdf qtdeclarative5-accounts-plugin qtdeclarative5-dialogs-plugin qtdeclarative5-privatewidgets-plugin qtdeclarative5-ubuntu-ui-extras-browser-plugin qtdeclarative5-ubuntu-ui-extras-browser-plugin-assets remmina-plugin-vnc rhythmbox rhythmbox-data rhythmbox-mozilla rhythmbox-plugin-cdrecorder rhythmbox-plugin-magnatune rhythmbox-plugin-zeitgeist rhythmbox-plugins shotwell shotwell-common signon-plugin-password simple-scan software-center software-center-aptdaemon-plugins system-config-printer-common system-config-printer-gnome system-config-printer-udev telepathy-gabble telepathy-haze telepathy-logger telepathy-mission-control-5 telepathy-salut thunderbird thunderbird-gnome-support thunderbird-locale-fr totem totem-mozilla totem-plugins transmission-common transmission-gtk unity-control-center unity-control-center-signon unity-lens-friends unity-lens-music unity-lens-photos unity-lens-video unity-scope-audacious unity-scope-calculator unity-scope-chromiumbookmarks unity-scope-clementine unity-scope-colourlovers unity-scope-devhelp unity-scope-firefoxbookmarks unity-scope-gdrive unity-scope-gmusicbrowser unity-scope-gourmet unity-scope-guayadeque unity-scope-manpages unity-scope-musicstores unity-scope-musique unity-scope-openclipart unity-scope-texdoc unity-scope-tomboy unity-scope-video-remote unity-scope-virtualbox unity-scope-yelp unity-scope-zotero unity-webapps-common unity-webapps-qml unity-webapps-service usb-creator-common usb-creator-gtk vino webaccounts-extension-common webapp-container webbrowser-app xdiagnose xterm xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration"

# set defaults
default_hostname="$(hostname)"
default_domain="local"
default_user=$(id 1000 | cut -d"(" -f2 | cut -d")" -f1)
tmp=$(pwd)

clear

# check for root privilege
if [ "$(id -u)" != "0" ]; then
	echo " this script must be run as root" 1>&2
	echo
	exit 1
fi

# determine ubuntu version
ubuntu_version=$(lsb_release -cs)

# check for interactive shell
if ! grep -q "noninteractive" /proc/cmdline ; then
	stty sane

	# ask questions
	read -ep " please enter your hostname (first letter of your first name and your full last name) : " -i "$default_hostname" hostname
	read -ep " please enter your bytel domain: " -i "$default_domain" domain
	read -ep " please enter your username: " -i "$default_user" username
	read -ep " please enter your secure password: " -i "$default_password" password
fi

# print status message
echo " preparing your server; this may take a few minutes ..."
(apt-get -y install whois > /dev/null 2>&1) & spinner $! "installing whois..."
echo
# set fqdn
fqdn="$hostname.$domain"

# update hostname
echo "$hostname" > /etc/hostname
sed -i "s@ubuntu.ubuntu@$fqdn@g" /etc/hosts
sed -i "s@ubuntu@$hostname@g" /etc/hosts
hostname "$hostname"
#create user
useradd -p `mkpasswd "$password"` -d /home/"$username" -m -g users -s /bin/bash "$username"
# update repos
(apt-get -y update > /dev/null 2>&1) & spinner $! "updating apt repository ..."
echo
(apt-get -y upgrade > /dev/null 2>&1) & spinner $! "upgrade ubuntu os ..."
echo
(apt-get -y dist-upgrade > /dev/null 2>&1) & spinner $! "dist-upgrade ubuntu os ..."
echo
(apt-get -y install openvpn > /dev/null 2>&1) & spinner $! "installing openvpn..."
echo
(apt-get -y install ubuntu-desktop > /dev/null 2>&1) & spinner $! "installing ubuntu ..."
echo
(apt-get -y purge $PACKAGES_TO_REMOVE > /dev/null 2>&1) & spinner $! "remove extra ..."
echo
apt-get autoremove -y
(apt-get -y install remmina empathy > /dev/null 2>&1) & spinner $! "installing extra software ..."
echo
(apt-get -y autoremove > /dev/null 2>&1) & spinner $! "removing old kernels and packages ..."
echo
(apt-get -y purge > /dev/null 2>&1) & spinner $! "purging removed packages ..."
echo

#disable usb,bluetooth and sd card
echo "disable usb,bluetooth and sd card"
echo "blacklist bluetooth" > /etc/modprobe.d/bluetooth.conf
echo "blacklist bnep" > /etc/modprobe.d/bnep.conf
echo "blacklist btusb" > /etc/modprobe.d/btusb.conf
echo "blacklist rfcomm" > /etc/modprobe.d/rfcomm.conf
echo "blacklist sdhci_acpi" > /etc/modprobe.d/sdhci_acpi.conf
echo "blacklist sdhci" > /etc/modprobe.d/sdhci.conf
echo "blacklist sdhci_pci" > /etc/modprobe.d/sdhci_pci.conf
echo "blacklist uas" > /etc/modprobe.d/uas.conf
echo "blacklist usb_storage" > /etc/modprobe.d/usb_storage.conf
#secure desktop
echo "secure desktop"
(apt-get install -y apparmor-profiles apparmor-utils > /dev/null 2>&1) & spinner $! " Apparmor-Profiles configuration..."
echo
chmod 0640 /var/log/lastlog
chmod 0640 /var/log/faillog
chmod o-w /var/crash
chmod o-w /var/metrics
chmod o-w /var/tmp
#lock shared memory
echo "Block shared memory"
if ! grep -q "/run/shm" /etc/fstab; then
  echo "none	/run/shm	tmpfs	defaults,ro	0	0" >> /etc/fstab
fi

# configuration apparmor
aa-enforce /etc/apparmor.d/bin.ping
aa-enforce /etc/apparmor.d/sbin.dhclient
aa-enforce /etc/apparmor.d/usr.sbin.dnsmasq
aa-enforce /etc/apparmor.d/usr.sbin.rsyslogd

#disable guest session
echo "disable guest session"
echo "[SeatDefaults]
allow-guest=false
" > /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf
sed -i 's/hidden-users=/hidden-users=installer /g' /etc/lightdm/users.conf

#configuring openvpn
echo "configuring openvpn"
wget -O /etc/openvpn/client.conf https://raw.githubusercontent.com/Pwapou/ubuntu-unattend/master/client.ovpn


# remove /dev/mapper/vg0-tmp to give free space to volume group: vg0
if [ -b /dev/mapper/vg0-tmp ]; then
	lvremove -f /dev/mapper/vg0-tmp
fi
#disable shell for new user
echo "disable shell for new user"
sed -ie '/^SHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/default/useradd
sed -ie '/^DSHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/adduser.conf

#configuration IPV4 firewall
(apt-get install -y iptables-persistent > /dev/null 2>&1) & spinner $! "Iptable configuration..."
echo
mkdir /etc/iptables
echo "*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
-A OUTPUT -d 176.135.254.196 --dport 80 -j ACCEPT
-A OUTPUT -d 176.135.254.196 --dport 1194 -j ACCEPT
-A OUTPUT -o tun0 -j ACCEPT
COMMIT" > /etc/iptables/rules.v4

service iptables-persistent start
#encrypt home folder
#disable root
echo "disable root "
sudo passwd -l root
sudo deluser --remove-home ubuntu
# remove myself to prevent any unintended changes at a later stage
rm $0
# finish
echo " DONE; rebooting ... "
# reboot
shutdown -r now
