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

# INFO: Sync and remove old packages from cache directory.
yes | LANG=${LOCALE} pacman -Sc

# INFO: Update the trustdb of pacman.
LANG=${LOCALE} pacman-key --updatedb

# INFO: Sync and download fresh package databases from the server.
yes | LANG=${LOCALE} pacman -Sy archlinux-keyring

# INFO: Sync, download fresh package databases from the server and upgrade
#       installed packages.
yes | LANG=${LOCALE} pacman -Syu

# INFO: Reboot.
systemctl reboot

