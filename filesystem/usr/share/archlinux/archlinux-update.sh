#!/bin/bash

##############################################################################
# INFO: Bash configuration section (for this script only).
##############################################################################

# INFO: Treat unset variables and parameters other than the special parameters
#       ‘@’ or ‘*’ as an error when performing parameter expansion. An error
#       message will be written to the standard error, and a non-interactive
#       shell will exit.
set \
        -u

# INFO: Exit immediately if a pipeline (see Pipelines), which may consist of a
#       single simple command, a list, or a compound command returns a
#       non-zero status. A trap on ERR, if set, is executed before the shell
#       exits.
set \
        -e

##############################################################################
# INFO: Script body.
##############################################################################

LOCALE=en_US.UTF-8

# INFO: Generate mirrorlist for pacman.
LANG=${LOCALE} rm -f /etc/pacman.d/mirrorlist
LANG=${LOCALE} reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# INFO: Sync and remove old packages from cache directory.
yes | LANG=${LOCALE} pacman -Sc

# INFO: OPTION 1: Init and populate the GNU PGP trustdb of pacman (the robust but long way).
LANG=${LOCALE} rm -rf /etc/pacman.d/gnupg
LANG=${LOCALE} pacman-key --init
LANG=${LOCALE} pacman-key --populate archlinux

# INFO: OPTION 2: Update the trustdb of pacman (if init and populate is not done).
#LANG=${LOCALE} pacman-key --updatedb

# INFO: Sync and download fresh package databases from the server.
yes | LANG=${LOCALE} pacman -Sy archlinux-keyring

# INFO: Sync, download fresh package databases from the server and upgrade
#       installed packages.
yes | LANG=${LOCALE} pacman -Syu

# INFO: Reboot.
systemctl reboot
