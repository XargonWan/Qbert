#!/bin/bash

# Qbert is creating an overlay on root in order to install pacman (and other) packages over a read only (or even rw) filesystem
# this was born because I needed something to install softwares on my Steam Deck without unlocking the read only filesystem
# Qbert is using GPLv3 (c) Xargon 2022

basedir="${HOME}/.qbert"
workdir="$basedir/work"
upperdir="$basedir/upperdir"
merged="$basedir/merged"
version="0.5b"

mountpoints=( "/lib" "/lib32" "/lib64" "/libx32" "/opt" "/root" "/sbin" "/srv" "/sys" "/usr" "/var" "/bin" )

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
    --umount, --unmount Unmount the overlay
    --delete-overlay    Destroys the overlay (you will lose all data)
    --run <command>     Execute the specified command in the mounted environment

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

qmount() {
  for m in "${mountpoints[@]}"
  do
    check="grep -qs ${m} /proc/mounts"
    if [ -z "$check" ]
    then
      :
      echo "Mount point $m not found"
    else
      mkdir -p "$upperdir$m"
      mkdir -p "$workdir$m"
      mkdir -p "$merged$m"
      noslash="${m##*/}"
      mname="overlay-"$noslash
      sudo mount -t overlay "$mname" -o lowerdir="$m",upperdir="$upperdir$m",workdir="$workdir$m" "$merged$m"
      sudo mount --rbind /dev $merged/dev
      sudo mount --rbind /sys $merged/sys
      sudo mount --rbind /proc $merged/proc
    fi
  done
}

qumount() {
  for m in "${mountpoints[@]}"
  do
    check="grep -qs ${m} /proc/mounts"
    if [ -z "$check" ]
    then
      noslash="${m##*/}"
      mname="overlay-"$noslash
      sudo umount "$merged$m"
    fi
  done
}

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
      qmount
      echo -e "@#?%&#*\n(Overlay mounted)"
      exit
      ;;
    --umount*|--unmount*)
      qumount
      echo -e "@#?%&#*\n(Overlay unmounted)"
      exit
      ;;
    --delete-overlay*)
      qumount
      sudo rm -rf "$basedir"
      exit
      ;;
    --pacman-keyring-init*)
      # TODO
      # add it to the help
      exit
      ;;
    --run*)
      # TODO check if it's already mounted
      qmount
      chroot "$merged" "$@"
      exit
      ;;
    -*|--*|*)
      qmount
          if [ -x "$(command -v apk)" ];     then chroot "$merged" sudo apk "$@"
        elif [ -x "$(command -v apt)" ];     then chroot "$merged" sudo apt "$@"
        elif [ -x "$(command -v apt-get)" ]; then chroot "$merged" sudo apt-get "$@"
        elif [ -x "$(command -v dnf)" ];     then chroot "$merged" sudo dnf "$@"
        elif [ -x "$(command -v zypper)" ];  then chroot "$merged" sudo zypper "$@"
        elif [ -x "$(command -v pacman)" ];  then chroot "$merged" sudo pacman "$@"
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
