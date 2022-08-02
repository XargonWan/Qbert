## NOTICE
Something is broken atm, Qbert is not creating a correct overlay so basically the software is not working as intended.

# Qbert

[![GitHub license](https://img.shields.io/github/license/XargonWan/Qbert)](https://github.com/XargonWan/Qbert/blob/main/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/XargonWan/Qbert)](https://github.com/XargonWan/Qbert/issues)

Qbert generates a root overlay where you can install whatever software you need without messing your filesystem.

This project was born because I needed some easy way to install pacman stuff on my Steam Deck, so I decided to create a script to make it easier.
As you may know, in the SteamOS 3 (but not only there) the filesystem is readonly and itś reset at every update pushed by Valve.
As it'possible to install flatpaks and appimages, sometime installing a pacman package is needed.

Qbert is creating an overlay of the root folder so you can safely toy around with your packages and even preserve them in case of fs reset or mutation.
If you mess up just umount/delete the overlay and everything will be as new.

## Why the name Qbert
[Q*Bert](https://en.wikipedia.org/wiki/Q*bert) is an old arcade video game character, similarly to Pacman.
In the beginning was qbert was born to manage pacman packages on Steam Deck only, then I decided to expand the initial idea to all the packages manager.

## Installation
- Download qbert.sh
- Install it with `./qbert.sh --install-qbert`

## Uninstallation
`qbert --uninstall-qbert`

## Usage
After the installation you can run it by simply typing:

```
qbert [ARGUMENTS]

Arguments:
    -h, --help          Print this help
    -v, --version       Print Qbert version
    --install-qbert     Installs Qbert in /usr/bin/qbert to be invoked as qbert
    --uninstall-qbert   Uninstalls Qbert
    --history           Shows all the qbert commands history
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
```
NOTE: RetroDECK is not available in pacman but as a flatpak, for more info:
https://retrodeck.net


## Supported package managers
At the moment the following package managers are supported, if your favorite is missing please open an issue and I can add it.
```bash
apk
apt
apt-get
dnf
zypper
pacman
```
