#!/bin/bash

##############################################################################
# INFO: Bash configuration section.
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
# INFO: Script configuration section.
##############################################################################

# INFO: User on remote nodes.
USER=sova

#####################################################################
# INFO: User input section.
#####################################################################

# INFO: Check arguments.
if [ $# -ne 2 ]
then
	echo $(basename ${0}) host_dns_name_or_ip new_hostname
	exit 1
fi

# INFO: Get user arguments.
HOST=${1}
HOSTNAME=${2}

#####################################################################
# INFO: Sanity check section.
#####################################################################

# INFO: Check connection to node.
ssh \
	${USER}@${HOST} \
	echo Connection to ${HOST} as user ${USER} ok!

#####################################################################
# INFO: Access section.
#####################################################################

# INFO: Clean remote ssh directory.
ssh \
	${USER}@${HOST} \
	rm \
	-rf \
	/home/${USER}/.ssh/*

# INFO: Add only one authorized key.
scp \
	/home/${USER}/.ssh/id_rsa.pub \
	${USER}@${HOST}:/home/${USER}/.ssh/authorized_keys

#####################################################################
# INFO: Hostname section.
#####################################################################

# INFO: Set hostname.
ssh \
	${USER}@${HOST} \
	sudo \
	sh \
	-c \
	\"echo\ ${HOSTNAME}\ \>\ /etc/hostname\"

#####################################################################
# INFO: Machine id section.
#####################################################################

# INFO: Generate uniq machine id.
ssh \
	${USER}@${HOST} \
	sudo \
	sh \
	-c \
	\"cat\ /proc/sys/kernel/random/uuid\ \>\ /etc/machine-id\"

#####################################################################
# INFO: Fingerprint section.
#####################################################################

# INFO: Regenerate DSA fingerprint.
ssh \
	${USER}@${HOST} \
	LANG=us_EN.UTF-8 \
	sudo ssh-keygen \
	-t \
	dsa \
	-f \
	/etc/ssh/ssh_host_dsa_key

# INFO: Regenerate ECDSA fingerprint.
ssh \
	${USER}@${HOST} \
	sudo ssh-keygen \
	-t \
	ecdsa \
	-f \
	/etc/ssh/ssh_host_ecdsa_key

# INFO: Regenerate RSA fingerprint.
ssh \
	${USER}@${HOST} \
	sudo ssh-keygen \
	-t \
	rsa \
	-f \
	/etc/ssh/ssh_host_rsa_key

# INFO: Regenerate ED25519 fingerprint.
ssh \
	${USER}@${HOST} \
	sudo ssh-keygen \
	-t \
	ed25519 \
	-f \
	/etc/ssh/ssh_host_ed25519_key

