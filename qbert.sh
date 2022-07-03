#!/bin/bash

# Qbert is creating an overlay on / in order to install pacman packages over a read only filesystem
# this was born because I needed something to install softwares on my Steam Deck without unlocking the read only filesystem
# Qbert is using GPLv3 (c) Xargon 2022

workdir="${HOME}/.qbert/work"
upperdir="${HOME}/.qbert/upperdir"
merged="${HOME}/.qbert/merged"
version="0.2b"

print_help(){

echo "Qbert v""$version"
echo "
Usage:
qbert [ARGUMENTS]

Arguments:
    -h, --help          Print this help
    -v, --version       Print Qbert version
    --install-qbert     Installs Qbert in /usr/bin/qbert to be invoked as qbert
    --uninstall-qbert   Uninstalls Qbert
    --history           Shows all the qbert commands history
    --mount             Mount the overlay
    --umount            Unmount the overlay
    --delete-overlay    Destroys the overlay (you will lose all data)

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
}

mkdir -p "$workdir"
mkdir -p "$upperdir"
mkdir -p "$merged"

sudo mount -t overlay overlay -o lowerdir=/,upperdir=$upperdir,workdir="$workdir" $merged

# Arguments section

for i in $@; do
  case "$i" in
    -h*|--help*)
      print_help
      exit
      ;;
    --version*|-v*)
      echo "Qbert v""$version"
      exit
      ;;
    --install-qbert*)
      sudo cp qbert.sh /usr/bin/qbert
      sudo chmod +x /usr/bin/qbert
      echo -e "Qbert is installed in /usr/bin/qbert.\nInvoke it by wirting qbert.\nFeel free to delete qbert.sh"
      exit
      ;;
    --uninstall-qbert*)
      sudo rm -f /usr/bin/qbert
      echo -e "Qbert is uninstalled.\nFor completely remove its data run rm -rf ~/.qbert"
      exit
      ;;
    --history*)
      history | grep qbert
      exit
      ;;
    --mount*)
      echo -e "@#?%&#*\n(Overlay mounted)"
      exit
      ;;
    --umount*)
      sudo umount overlay
      echo -e "@#?%&#*\n(Overlay unmounted)"
      exit
      ;;
    --delete-overlay*)
      rm -rf "$workdir"
      exit
      ;;
    -*|--*|*)
      echo -e "@#?%&#*!\n(Overlay is mounted!)\n"
          if [ -x "$(command -v apk)" ];     then sudo apk "$@"
        elif [ -x "$(command -v apt)" ];     then sudo apt "$@"
        elif [ -x "$(command -v apt-get)" ]; then sudo apt-get "$@"
        elif [ -x "$(command -v dnf)" ];     then sudo dnf "$@"
        elif [ -x "$(command -v zypper)" ];  then sudo zypper "$@"
        elif [ -x "$(command -v pacman)" ];  then sudo pacman "$@"
        else echo -e '@#?%! \n(No package manager found!)'
        fi
      exit
      ;;
  esac
done

if [ -z "$@" ] # if argument is null
then
  print_help
  exit
fi