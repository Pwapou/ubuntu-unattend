#!/usr/bin/env bash

# file names & paths
tmp="/tmp"  # destination folder to store the final iso file

# define spinner function for slow tasks
# courtesy of http://fitnr.com/showing-a-bash-spinner.html
spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    tput civis;

    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done

    printf "    \b\b\b\b"
    tput cnorm;
}

# define download function
# courtesy of http://fitnr.com/showing-file-download-progress-using-wget.html
download()
{
    local url=$1
    echo -n "    "
    wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo -ne "\b\b\b\b"
    echo " DONE"
}

# define function to check if program is installed
# courtesy of https://gist.github.com/JamieMason/4761049
function program_is_installed {
    # set to 1 initially
    local return_=1
    # set to 0 if not found
    type $1 >/dev/null 2>&1 || { local return_=0; }
    # return value
    echo $return_
}

# print a pretty header
echo 
echo " +---------------------------------------------------+"
echo " |            UNATTENDED UBUNTU ISO MAKER            |"
echo " +---------------------------------------------------+"
echo 

if [ ${UID} -ne 0 ]; then
    echo " [-] This script must be runned with root privileges."
    echo " [-] sudo ${0}"
    echo
    exit 1
fi

# ask whether to include vmware tools or not
while true; do
    echo " which ubuntu edition would you like to remaster:"
    echo
    echo "  [1] Ubuntu 14.04.4 LTS Server i386  - Trusty Tahr"
    echo
    read -p " please enter your preference: [1]: " ubver
    case $ubver in
        [1]* )  download_file="ubuntu-14.04.4-server-i386.iso"            # filename of the iso to be downloaded
                download_location="http://releases.ubuntu.com/14.04.4/"   # location of the file to be downloaded
                new_iso_name="ubuntu-14.04.4-server-i386-unattended.iso"  # filename of the new iso file to be created
                break;;
        * ) echo " please answer [1]";;
    esac
done

# ask the user questions about his/her preferences
if ! timezone=`cat /etc/timezone 2> /dev/null`; then
    timezone="Europe/Amsterdam"
fi
read -ep " please enter your preferred timezone  : " -i $timezone timezone
read -ep " please enter your preferred hostname  : " -i "ubuntu" hostname
read -ep " please enter your preferred username  : " -i "`logname`" username
read -ep " please enter lvm type (guided/(expert coming soon) : " -i "guided" lvmtype

# ask user with type of lvm to use
while true; do
	case ${lvmtype} in
		guided) seed_file="guided-lvm.seed" ; break ;;
		* ) echo " please enter only guided." ;;
	esac
done

# check if the passwords match to prevent headaches
while true; do
    read -sp " please enter your preferred password: " password
    printf "\n"
    read -sp " confirm your preferred password: " password2
    printf "\n"
    if [[ "$password" != "$password2" ]]; then
        echo " your passwords do not match; please try again"
        echo
    else
        break
    fi
done

read -p " autostart installation on boot (y/n)?" choice
case "$choice" in 
  y|Y ) autostart=true;;
  * ) autostart=false;;
esac

# download the ubunto iso
cd $tmp
if [[ ! -f $tmp/$download_file ]]; then
    echo -n " downloading $download_file: "
    download "$download_location$download_file"
fi

# download lvm seed file
if [[ ! -f $tmp/$seed_file ]]; then
    echo -n " downloading $seed_file: "
    download "https://raw.githubusercontent.com/Pwapou/ubuntu-unattend/master/$seed_file"
fi

# install required packages
echo " installing required packages"
if [ $(program_is_installed "mkpasswd") -eq 0 ] || [ $(program_is_installed "mkisofs") -eq 0 ]; then
    (apt-get -y update > /dev/null 2>&1) &
    spinner $!
    (apt-get -y install whois genisoimage > /dev/null 2>&1) &
    spinner $!
    
    # thanks to rroethof
    if [ -f /usr/bin/mkisofs ]; then
      ln -s /usr/bin/genisoimage /usr/bin/mkisofs
    fi
fi

# create working folders
echo " remastering your iso file"
mkdir -p $tmp
mkdir -p $tmp/iso_org
mkdir -p $tmp/iso_new

# mount the image
if grep -qs $tmp/iso_org /proc/mounts ; then
    echo " image is already mounted, continue"
else
    (mount -o loop $tmp/$download_file $tmp/iso_org > /dev/null 2>&1)
fi

# copy the iso contents to the working directory
(cp -rT $tmp/iso_org $tmp/iso_new > /dev/null 2>&1) &
spinner $!

# set the language for the installation menu
cd $tmp/iso_new
echo en > $tmp/iso_new/isolinux/lang

# set timeout to 1 decisecond to skip language & boot menu option selection.
if $autostart ; then
    sed -i "s/timeout 0/timeout 1/" $tmp/iso_new/isolinux/isolinux.cfg
fi

# set late command
late_command="chroot /target wget -O /home/$username/init.sh https://raw.githubusercontent.com/Pwapou/ubuntu-unattend/master/init.sh ;\
    chroot /target chmod +x /home/$username/init.sh ; echo "ubuntu ALL=(ALL) NOPASSWD: /home/ubuntu/init.sh" >> /etc/sudoers  ; "

# copy the netson seed file to the iso
cp -rT $tmp/$seed_file $tmp/iso_new/preseed/$seed_file

# include firstrun script
echo "
# setup firstrun script
d-i preseed/late_command                                    string      $late_command" >> $tmp/iso_new/preseed/$seed_file

# generate the password hash
pwhash=$(echo $password | mkpasswd -s -m sha-512)

# update the seed file to reflect the users' choices
# the normal separator for sed is /, but both the password and the timezone may contain it
# so instead, I am using @
sed -i "s@{{username}}@$username@g" $tmp/iso_new/preseed/$seed_file
sed -i "s@{{pwhash}}@$pwhash@g" $tmp/iso_new/preseed/$seed_file
sed -i "s@{{hostname}}@$hostname@g" $tmp/iso_new/preseed/$seed_file
sed -i "s@{{timezone}}@$timezone@g" $tmp/iso_new/preseed/$seed_file

# calculate checksum for seed file
seed_checksum=$(md5sum $tmp/iso_new/preseed/$seed_file)

# add the autoinstall option to the menu
sed -i "/label install/ilabel autoinstall\n\
  menu label ^Unattended Ubuntu Server Install\n\
  kernel /install/vmlinuz\n\
  append file=/cdrom/preseed/ubuntu-server-minimalvm.seed initrd=/install/initrd.gz auto=true priority=high preseed/file=/cdrom/preseed/${seed_file} preseed/file/checksum=$seed_checksum --" $tmp/iso_new/isolinux/txt.cfg

echo " creating the remastered iso"
cd $tmp/iso_new
(mkisofs -D -r -V "Ubuntu server" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $tmp/$new_iso_name . > /dev/null 2>&1) &
spinner $!

# cleanup
umount $tmp/iso_org
rm -rf $tmp/iso_new
rm -rf $tmp/iso_org

# print info to user  
echo " -----"
echo " finished remastering your ubuntu iso file"
echo " the new file is located at: $tmp/$new_iso_name"
echo " your username is: $username"
echo " your password is: $password"
echo " your hostname is: $hostname"
echo " your timezone is: $timezone"
echo

# unset vars
unset username
unset password
unset password2
unset hostname
unset timezone
unset pwhash
unset download_file
unset download_location
unset new_iso_name
unset tmp
unset seed_file
