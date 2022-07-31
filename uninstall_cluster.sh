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

# INFO: Servers only (from remote nodes set). To run K3s in this mode, you must
#       have an odd number of server nodes. It is recommended to start with
#       three server nodes.
SERVERS="control-arch-linux-0 control-arch-linux-1 control-arch-linux-2"

# INFO: Workers only (from remote nodes set).
WORKERS="compute-arch-linux-0 compute-arch-linux-1 compute-arch-linux-2"

# INFO: All nodes (servers and workers).
NODES="${SERVERS} ${WORKERS}"

#####################################################################
# INFO: Sanity check section.
#####################################################################

# INFO: Check connection to each node.
for host in ${NODES}
do
	ssh \
		${USER}@${host} \
		echo Connection to ${host} as user ${USER} ok!
done

#####################################################################
# INFO: Cluster section.
#####################################################################

# INFO: Uninstall and reboot servers.
for server in ${SERVERS}
do
	ssh \
		${USER}@${server} \
		k3s-uninstall.sh || true
	ssh \
		${USER}@${server} \
		sudo systemctl reboot || true
done

# INFO: Uninstall and reboot workers.
for worker in ${WORKERS}
do
	ssh \
		${USER}@${worker} \
		k3s-agent-uninstall.sh || true
	ssh \
		${USER}@${worker} \
		sudo systemctl reboot || true
done

