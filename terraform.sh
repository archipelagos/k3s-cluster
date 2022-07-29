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

# INFO: Preshared cluster secret.
CLUSTER_SECRET=$(cat /proc/sys/kernel/random/uuid)

# INFO: Servers only (from remote nodes set). To run K3s in this mode, you must
#       have an odd number of server nodes. It is recommended to start with
#       three server nodes.
SERVERS="control-arch-linux-0 control-arch-linux-1"

# INFO: Workers only (from remote nodes set).
WORKERS="compute-arch-linux-0 compute-arch-linux-1"

# INFO: All nodes (servers and workers).
NODES="${SERVERS} ${WORKERS}"

#####################################################################
# INFO: Access section.
# TODO: Move it into another script.
#####################################################################

# INFO: Clean remote ssh directory.
#for host in ${NODES}
#do
#	echo \
#		rm \
#		-rf \
#		/home/${USER}/.ssh/*
#	ssh \
#		${host} \
#		rm \
#		-rf \
#		/home/${USER}/.ssh/*
#done

# INFO: Add only one authorized key.
#for host in ${NODES}
#do
# TODO: cat ~/.ssh/id_rsa.pub | ssh control-arch-linux-1 cat >> ./temp
#	echo \
#		scp \
#		/home/${USER}/.ssh/id_rsa.pub \
#		${host}:/home/${USER}/.ssh/authorized_keys
#	scp \
#		/home/${USER}/.ssh/id_rsa.pub \
#		${host}:/home/${USER}/.ssh/authorized_keys
#done

#####################################################################
# INFO: Cluster section.
#####################################################################

# INFO: Compute first server from set.
FIRST_SERVER=${SERVERS%% *}

# INFO: Add servers to cluster.
for server in ${SERVERS}
do
	if [ ${server} == ${FIRST_SERVER} ]
	then
		# INFO: Init new cluster.
		echo Init new cluster
		curl -sfL https://get.k3s.io | ssh \
			${USER}@${server} \
			K3S_TOKEN=${CLUSTER_SECRET} \
			sh -s - server \
			--cluster-init
	else
		# INFO: Connect new server to existing cluster.
		echo Connect new server to existing cluster
		curl -sfL https://get.k3s.io | ssh \
			${USER}@${server} \
			K3S_TOKEN=${CLUSTER_SECRET} \
			sh -s - server \
			--server \
			https://${FIRST_SERVER}:6443
	fi
done

# INFO: Get first server node token.
FIRST_SERVER_NODE_TOKEN=$(ssh \
	${USER}@${FIRST_SERVER} \
	sudo cat /var/lib/rancher/k3s/server/node-token)

# INFO: Add workers to cluster.
for worker in ${WORKERS}
do
	echo \
		Adding ${worker} to cluster
	curl -sfL https://get.k3s.io | ssh \
		${USER}@${worker} \
		sh -s - agent \
		--server \
		https://${FIRST_SERVER}:6443 \
		--token \
		${FIRST_SERVER_NODE_TOKEN}
done

