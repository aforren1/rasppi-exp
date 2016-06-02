#!/bin/bash

# note that you still need to enable opengl manually, as well as
# download this manually via `wget ...`

# basic update
sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade

# download octave, ptb dependencies
sudo apt-get install -y git libportaudio-ocaml-dev subversion freeglut3 freeglut3-dev rhythmbox libusb-1.0 libdc1394-22-dev

sudo apt-get build-dep octave
wget ftp://ftp.gnu.org/gnu/octave/octave-4.0.1.tar.gz
tar xf octave-4.0.1.tar.gz
cd octave-4.0.1/
./configure
make 
sudo make install
cd ..

