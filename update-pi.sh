#!/bin/bash

# note that you still need to enable opengl manually, as well as
# download this manually via
# wget https://raw.githubusercontent.com/aforren1/rasppi-exp/master/update-pi.sh

# also, add user exp as super user (don't know if raspbian takes care of this,
# debian didn't)

# su
# adduser exp sudo
# exit
# (log out and in again)

# basic update
sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade

# download octave, ptb dependencies
sudo apt-get install -y git libportaudio-ocaml-dev subversion freeglut3 freeglut3-dev rhythmbox libusb-1.0 libdc1394-22-dev

sudo apt-get build-dep -y octave
wget ftp://ftp.gnu.org/gnu/octave/octave-4.0.1.tar.gz
tar xf octave-4.0.1.tar.gz
cd octave-4.0.1/
sudo ./configure
sudo make
sudo make install
cd ..
rm octave-4.0.1.tar.gz
rm -rf ~/Documents
rm -rf ~/Public
rm -rf ~/Templates
rm -rf ~/Videos
rm -rf ~/Music
mkdir ~/experiment

# get a modified version that won't ask permission
wget https://raw.githubusercontent.com/aforren1/rasppi-exp/master/ModifiedDownloadPsychtoolbox.m
mkdir ~/toolbox # until I figure out permissions

# use octave from command line
octave ModifiedDownloadPsychtoolbox.m
