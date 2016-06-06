#!/bin/bash

# note that you still need to enable opengl manually, as well as
# download this manually via
# wget https://raw.githubusercontent.com/aforren1/rasppi-exp/master/update-pi.sh
# also, make sure nonfree is uncommented in /etc/apt/sources.list, or the octave dependencies won't be grabbed

# make a swap space? Might help (only if we do compilation of octave though)
sudo dd if=/dev/zero of=/mnt/1GB.swap bs=1024 count=1048576
chmod 600 /mnt/1GB.swap
sudo mkswap /mnt/1GB.swap
sudo swapon /mnt/1GB.swap
# didn't work
#sudo printf '%s\n' '/mnt/1GB.swap  none  swap  sw 0  0' >> /etc/fstab
# reboot here?

# basic update
# add the unstable debian distro plus key
# deb http://ftp.us.debian.org/debian sid main
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553
#sudo printf '%s\n' 'deb http://ftp.us.debian.org/debian sid main' >> /etc/apt/sources.list

sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade

# download octave, ptb dependencies
sudo apt-get install -y --force-yes git portaudio19-dev libportaudio-ocaml-dev subversion freeglut3 freeglut3-dev rhythmbox libusb-1.0 libdc1394-22-dev

sudo apt-get install -y octave liboctave-dev
# get a modified version that won't ask permission
wget https://raw.githubusercontent.com/aforren1/rasppi-exp/master/ModifiedDownloadPsychtoolbox.m
mkdir ~/toolbox # until I figure out permissions

# use octave from command line
octave ModifiedDownloadPsychtoolbox.m

# option: build from source (haven't gotten it to run PTB yet, but seems to work)
sudo apt-get build-dep -y octave
wget ftp://ftp.gnu.org/gnu/octave/octave-4.0.2.tar.gz
tar xf octave-4.0.2.tar.gz
cd octave-4.0.2/
sudo ./configure
sudo make
sudo make install
cd ~
rm octave-4.0.2.tar.gz
rm -rf ~/Documents
rm -rf ~/Public
rm -rf ~/Templates
rm -rf ~/Videos
rm -rf ~/Music

# download experiment
git clone https://github.com/aforren1/finger-5

# restart...
