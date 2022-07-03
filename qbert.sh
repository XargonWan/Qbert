#!/bin/bash

# Qbert is creating an overlay on / in order to install pacman packages over a read only filesystem
# this was born because I needed something to install softwares on my Steam Deck without unlocking the read only filesystem
# Qbert is using GPLv3 (c) Xargon 2022

workdir="${HOME}/.qbert/work"
upperdir="${HOME}/.qbert/upperdir"
version="0.1b"

if [ ! -d "${HOME}/.qbert/" ]
then
    mkdir -p "$workdir"
    mkdir -p "$upperdir"
fi
sudo mount -t overlay overlay -o lowerdir=/,upperdir=$upperdir,workdir="$workdir" /merged

# Arguments section

for i in "$@"; do
  case $i in
    -h*|--help*)
      echo "Qbert v""$version"
      echo "
      Usage:
qbert [ARGUMENTS]

Arguments:
    -h, --help        Print this help
    -v, --version     Print Qbert version
    --install         Installs Qbert in /usr/bin/qbert to be invoked as qbert
    --history         Shows all the qbert commands history
    --umount          Unmount the overlay
    --delete-overlay  Destroys the overlay (you will lose all data)

Any other argument will be passed to your package manager, for example:

qbert -s retrodeck
equals to:
pacman -s retrodeck

qbert install retrodeck
equals to:
apt install retrodeck

But it will be done inside the overlay.

NOTE: RetroDECK is not available in pacman but as a flatpak, for more info:
https://retrodeck.net
"
      exit
      ;;
    --version*|-v*)
      echo "Qbert v""$version"
      exit
      ;;
    --install*)
      sudo cp qbert.sh /usr/bin/qbert
      chmod +x /usr/bin/qbert
      echo -e "Qbert is installed in /usr/bin/qbert.\nInvoke it by wirting qbert.\nFeel free to delete qbert.sh"
      shift # past argument with no value
      ;;
    --history*)
      history | grep qbert
      shift # past argument with no value
      ;;
    --umount*)
      sudo umount overlay
      shift # past argument with no value
      ;;
    --delete-overlay*)
      rm -rf "$workdir"
      shift # past argument with no value
      ;;
    -*|--*|*)
          if [ -x "$(command -v apk)" ];     then sudo apk $i
        elif [ -x "$(command -v apt)" ];     then sudo apt $i
        elif [ -x "$(command -v apt-get)" ]; then sudo apt-get $i
        elif [ -x "$(command -v dnf)" ];     then sudo dnf $i
        elif [ -x "$(command -v zypper)" ];  then sudo zypper $i
        elif [ -x "$(command -v pacman)" ];  then sudo pacman $i
        else echo -e '@#?%! \n(No package manager found!)'
        fi
      ;;
  esac
done