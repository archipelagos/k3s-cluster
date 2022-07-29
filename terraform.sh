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

# INFO: Init cluster.
curl -sfL https://get.k3s.io | ssh \
	${USER}@${FIRST_SERVER} \
	sh -s - server \
	--cluster-init

# INFO: Get cluster secret.
SECRET=$(ssh \
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
		${SECRET}
done

#curl -sfL https://get.k3s.io | K3S_TOKEN=K10ba9e35c3121e59030dcb77c8f06d5870d6a9e37905ee04c26e82b12f61bb2724::server:ada733fdb5009287ac72d01b23509345 sh -s - server --server https://control-arch-linux-0:6443

#curl -sfL https://get.k3s.io | K3S_URL=https://control-arch-linux-0:6443 K3S_TOKEN=K10ba9e35c3121e59030dcb77c8f06d5870d6a9e37905ee04c26e82b12f61bb2724::server:ada733fdb5009287ac72d01b23509345 sh -

#sudo k3s kubectl get nodes

#####################################################################
# INFO: control-arch-linux-0 - działa poprawnie (rekomendowana)
#####################################################################

#[sova@control-arch-linux-0 ~]$ curl -sfL https://get.k3s.io | sh -s - server --cluster-init

#[sova@control-arch-linux-0 ~]$ sudo cat /var/lib/rancher/k3s/server/node-token
#K105663297391eef07713d2a00f68e0ee914e39bc8fa04a49aeb4158ca3e6093e48::server:576efcd14da8ec00a2373dc26d1a87f0

#####################################################################
# INFO: compute-arch-linux-0 - działa poprawnie (wersja długa)
#####################################################################

#[sova@compute-arch-linux-0 ~]$ curl -sfL https://get.k3s.io | sh -
#[sova@compute-arch-linux-0 ~]$ sudo systemctl stop k3s.service
#[sova@compute-arch-linux-0 ~]$ sudo k3s agent --server https://control-arch-linux-0:6443 --token K107141caa5e2580f99170d389cbf03a964c7cc4c1ee9277d06cb91a38baadb8f10::server:3eb3a15048f04727229346b63e80d621

#####################################################################
# INFO: compute-arch-linux-0 - działa poprawnie (rekomendowana)
#####################################################################

#[sova@compute-arch-linux-0 ~]$ curl -sfL https://get.k3s.io | sh -s - agent --server https://control-arch-linux-0:6443 --token K105b40e4adf5f323d02e97b7893e601710f2551805585ca93f744adf82bc2d6f9e::server:0dd27e194c117ba414b85e239cf3b6a3

