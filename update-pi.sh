#!/bin/bash

# note that you still need to enable opengl manually, as well as
# download this manually via
# wget https://raw.githubusercontent.com/aforren1/rasppi-exp/master/update-pi.sh
# also, make sure nonfree is uncommented in /etc/apt/sources.list, or the octave dependencies won't be grabbed

# make a swap space?

# basic update
sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade

# download octave, ptb dependencies
sudo apt-get install -y git portaudio19-dev libportaudio-ocaml-dev subversion freeglut3 freeglut3-dev rhythmbox libusb-1.0 libdc1394-22-dev

sudo apt-get build-dep -y octave
wget ftp://ftp.gnu.org/gnu/octave/octave-4.0.2.tar.gz
tar xf octave-4.0.2.tar.gz
cd octave-4.0.2/
sudo ./configure
sudo make
sudo make install
cd ..
rm octave-4.0.2.tar.gz
rm -rf ~/Documents
rm -rf ~/Public
rm -rf ~/Templates
rm -rf ~/Videos
rm -rf ~/Music

# download experiment
git clone https://github.com/aforren1/finger-5

# get a modified version that won't ask permission
wget https://raw.githubusercontent.com/aforren1/rasppi-exp/master/ModifiedDownloadPsychtoolbox.m
mkdir ~/toolbox # until I figure out permissions

# use octave from command line
octave ModifiedDownloadPsychtoolbox.m

# restart...
