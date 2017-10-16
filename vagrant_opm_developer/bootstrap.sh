#!/usr/bin/env bash

# This script installs all OPM packages

#Make sure that script exits on failure, and that all commands are printed
set -e
set -x

# Make sure we have updated URLs to packages etc.
sudo apt-get update -y

# Packages needed for add-apt-repository
sudo apt-get install -y python-software-properties software-properties-common

# Add PPA for the OPM packages
sudo add-apt-repository -y ppa:opm/ppa

# Update package list again
sudo apt-get update -y

# DUNE packages
sudo apt-get install -y mpi-default-bin
sudo apt-get install -y libdune-istl-dev libdune-grid-dev

# OPM packages
# sudo apt-get install -y libopm-simulators-bin

# Packages needed for OPM source install
sudo apt-get install -y cmake
sudo apt-get install -y libboost-all-dev libblas-dev liblapack-dev libsuitesparse-dev

# Other utilities that are required by tutorials etc.
sudo apt-get install unzip -y

# Latex
# sudo apt-get install -y texlive-latex-base ghostscript gnuplot
