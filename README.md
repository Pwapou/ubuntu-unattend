# Unattended Ubuntu Desktop 

This simple script will create an unattended Ubuntu ISO from start to finish. 

This script creates a 100% original Ubuntu installation; the only additional software added is ```Remmina, Empathy and OpenVPN```. 

## Compatibility

The script supports the following Ubuntu editions out of the box:

* Ubuntu 14.04.3 Server LTS i386  - Trusty Tahr
* Ubuntu 16.04 (SOON)


## Usage

* From your command line, run the following commands:

```
git clone https://github.com/Pwapou/ubuntu-unattend.git
And start the script with root privilege : ./create-unattended-iso.sh
```

* Choose which version you would like to remaster:

```
  [1] Ubuntu 14.04.3 LTS Server i386  - Trusty Tahr
  [2] Ubuntu 16.04 SOON
```

* Enter your desired timezone;

```
 please enter your preferred timezone: Europe/Paris
```

* Enter your desired username; the default is *ubuntu*:

```
 please enter your preferred username: ubuntu
```

* Enter the password for your user account;

```
 please enter your preferred password:
```

* Confirm your password:

```
 confirm your preferred password:
```

* Just wait, your iso is coming :)

## What it does

This script remove useless package from unity, install a GUI, extra application (remmina, emapthy open-vpn client) and secure your system (apparmor, iptable, crypt your home directory, disable root and guest session, and disable bluetooth, usb ,sdcard...) :


### Once Ubuntu is installed ...

Just start the init.sh script in your user's home directory to complete the installation. 

```$ sudo ~/init.sh``` 
