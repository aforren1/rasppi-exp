#!/bin/bash

# turn on opengl from raspi-config and restart

mkdir ~/toolbox
wget https://raw.githubusercontent.com/Psychtoolbox-3/Psychtoolbox-3/1b9fd92290a789c80aa95e0af7c9b7bb4920b607/Psychtoolbox/DownloadPsychtoolbox.m

echo "deb-src http://archive.raspbian.org/raspbian/ jessie main contrib non-free rpi" | sudo tee -a /etc/apt/sources.list

sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade

# download octave, ptb dependencies
sudo apt-get install -y --force-yes git portaudio19-dev subversion freeglut3 freeglut3-dev rhythmbox libusb-1.0 libdc1394-22-dev
# install octave 3 first (to use the liboctinterp.so that makes it happy)
sudo apt-get install -y octave liboctave-dev

# try a newer version of octave (~4.0.2)
#echo "deb http://httpredir.debian.org/debian jessie-backports main contrib non-free" | sudo tee -a /etc/apt/sources.list
#sudo aptitude install debian-keyring debian-archive-keyring
#gpg --keyserver pgpkeys.mit.edu --recv-key 46925553      
#gpg -a --export 46925553 | sudo apt-key add -
#gpg --keyserver pgpkeys.mit.edu --recv-key  2B90D010
#gpg -a --export 2B90D010 | sudo apt-key add -
#sudo apt-get update
#sudo apt-get -s install -t jessie-backports octave

# if compiling octave, try making a swap space (I got one error that
# could apparently be due to lack of RAM during make)
#sudo dd if=/dev/zero of=/mnt/1GB.swap bs=1024 count=1048576
#sudo chmod 600 /mnt/1GB.swap
#sudo mkswap /mnt/1GB.swap
#sudo swapon /mnt/1GB.swap
#echo "/mnt/1GB.swap  none  swap  sw 0  0" | sudo tee -a /etc/fstab
#sudo apt-get build-dep -y octave
#wget ftp://ftp.gnu.org/gnu/octave/octave-4.0.2.tar.gz
#tar xf octave-4.0.2.tar.gz
#cd octave-4.0.2/
#sudo ./configure
#sudo make
#sudo make install
#cd ~

# octave --no-gui
# DownloadPsychtoolbox('/home/pi/toolbox', 'beta');

# below is probably unnecessary -- it looks like the PTB folks don't use waffle anymore
# for raspberry pi
#sudo mv ~/toolbox/Psychtoolbox/PsychContributed/ArmArch/libwaffle-1.so.0.2.75_glxegl /usr/lib/libwaffle-1.so.0
