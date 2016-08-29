#!/bin/bash

mkdir ~/toolbox
wget https://raw.githubusercontent.com/Psychtoolbox-3/Psychtoolbox-3/master/Psychtoolbox/DownloadPsychtoolbox.m

echo "deb-src http://archive.raspbian.org/raspbian/ jessie main contrib non-free rpi" | sudo tee -a /etc/apt/sources.list
echo "deb http://httpredir.debian.org/debian stretch main contrib non-free" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://httpredir.debian.org/debian stretch main contrib non-free" | sudo tee -a /etc/apt/sources.list
sudo aptitude -y install debian-keyring debian-archive-keyring
gpg --keyserver pgpkeys.mit.edu --recv-key 46925553
gpg -a --export 46925553 | sudo apt-key add -
gpg --keyserver pgpkeys.mit.edu --recv-key  2B90D010
gpg -a --export 2B90D010 | sudo apt-key add -
sudo apt-get update
sudo apt-get -y --force-yes upgrade

# download ptb dependencies and octave (probably some redundancies)
sudo apt-get install -y --force-yes portaudio19-dev subversion freeglut3-dev rhythmbox libusb-1.0 libdc1394-22-dev libgl1-mesa-dri octave liboctave-dev mesa-utils
# clean up accumulated waste
sudo apt-get autoremove -y

# turn on opengl from raspi-config, bump up video RAM to 256, and restart
echo "gpu_mem_1024=256" | sudo tee -a /boot/config.txt
# see https://github.com/RPi-Distro/raspi-config/blob/master/raspi-config#L1054 for
# enabling via script
# check that opengl is working with `glxgears` (from mesa-demos)

# octave --no-gui
# DownloadPsychtoolbox('/home/pi/toolbox', 'beta');
