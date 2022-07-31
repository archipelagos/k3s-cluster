Lightweight K3S cluster
=======================

What is K3S
-----------

Lightweight Kubernetes.  Production ready, easy to install, half the memory, all in a binary less than 100 MB.

Great for:

* Edge
* IoT
* CI
* Development
* ARM
* Embedding k8s
* Situations where a PhD in k8s clusterology is infeasible

K3s is a [fully conformant](https://github.com/cncf/k8s-conformance/pulls?q=is%3Apr+k3s) production-ready Kubernetes distribution with the following changes:

1. It is packaged as a single binary.
1. It adds support for sqlite3 as the default storage backend. Etcd3, MySQL, and Postgres are also supported.
1. It wraps Kubernetes and other components in a single, simple launcher.
1. It is secure by default with reasonable defaults for lightweight environments.
1. It has minimal to no OS dependencies (just a sane kernel and cgroup mounts needed).
1. It eliminates the need to expose a port on Kubernetes worker nodes for the kubelet API by exposing this API to the Kubernetes control plane nodes over a websocket tunnel.

Cluster outlook
---------------

Cluster is launched on VMs available on [ProxMox node](https://waw.ddns.net:8006). Cluster consist of server nodes working in HA and worker nodes as listed below:

1. control-arch-linux-0
1. control-arch-linux-1
1. control-arch-linux-2
1. compute-arch-linux-0
1. compute-arch-linux-1
1. compute-arch-linux-2

Preparation
-----------

Prepare a minimal Arch Linux installation on each node according to [this steps](https://wiki.archlinux.org/title/Installation_guide_(Polski)).

Next ensure that each node is initialized. Use ready script as presented below.
First argument is dns host name or IP address, second is hostname, which will
be used in `/etc/hostname` on node you are initializing.

For server node no 1:

```console
user@host:~$ ./init_node.sh control-arch-linux-0_net_addr control-arch-linux-0
```

For server node no 2:

```console
user@host:~$ ./init_node.sh control-arch-linux-1_net_addr control-arch-linux-1
```

For server node no 3:

```console
user@host:~$ ./init_node.sh control-arch-linux-2_net_addr control-arch-linux-2
```

For worker node no 1:

```console
user@host:~$ ./init_node.sh compute-arch-linux-0_net_addr compute-arch-linux-0
```

For worker node no 2:

```console
user@host:~$ ./init_node.sh compute-arch-linux-1_net_addr compute-arch-linux-1
```

For worker node no 3:

```console
user@host:~$ ./init_node.sh compute-arch-linux-2_net_addr compute-arch-linux-2
```

At this point, each node:

1. Proved its stable network connection.
1. Initialzed its `.ssh` directory of user used.
1. Installed one SSH authorized key.
1. Have unique host name in its `/etc/hostname` directory.
1. Have unique machine ID in its `/etc/machine-id` directory.
1. Have fresh DSA host key in `/etc/ssh/ssh_host_dsa_key`.
1. Have fresh ECDSA host key in `/etc/ssh/ssh_host_ecdsa_key`.
1. Have fresh RSA host key in `/etc/ssh/ssh_host_rsa_key`.
1. Have fresh ED25519 host key in `/etc/ssh/ssh_host_ed25519_key`.

Installation
------------

Now you can proceed with further atomatic installation process when you are sure, that your nodes are properly initialized and ready to be used. Just launch script.

```console
user@host:~$ ./terraform.sh
```

Troubleshooting
---------------

Sometimes installation can fail. If any of nodes did not start K3S properly and automated script was terminated in the middle of execution, manual steps need to be proceeded. Make sure, that you uninstall K3S from each node. Then just restart each node and start automated script again.

To uninstall K3S from server node, execute command:

```console
user@host:~$ ssh control-arch-linux-0_net_addr k3s-uninstall.sh
```

To uninstall K3S from worker node, execute command:

```console
user@host:~$ ssh control-arch-linux-0_net_addr k3s-agent-uninstall.sh
```

To restart node, execute command:

```console
user@host:~$ ssh control-arch-linux-0_net_addr sudo systemctl reboot
```

Controling cluster
------------------

At this moment your cluster should be fine. In order to communicate with the cluster retrieve the certificate from any of server nodes.

Save this content on your local machine in `~/.kube/<your config file>`.

```console
user@host:~$ ssh control-arch-linux-0_net_addr sudo cat /etc/rancher/k3s/k3s.yaml
```

Locate in the file your cluster and modify `server` section. It should point to any of your server machines.

Once the steps before are applied, you can execute the following script to load the Kubernetes config.

```console
user@host:~$ export KUBECONFIG=/.kube/<your config file>
```

Now you should be able to use the cluster. Check this by executing the following command.

```console
user@host:~$ kubectl get nodes
```

You do not have to export configuration file, you can embed parameter pointing to configuration file directly in your command.

```console
user@host:~$ kubectl --kubeconfig ~/.kube/k3s.yaml get nodes
```

The result is a list of the available nodes.

```console
user@host:~$ kubectl get nodes
NAME                   STATUS   ROLES                       AGE   VERSION
compute-arch-linux-0   Ready    <none>                      22h   v1.24.3+k3s1
compute-arch-linux-1   Ready    <none>                      22h   v1.24.3+k3s1
compute-arch-linux-2   Ready    <none>                      22h   v1.24.3+k3s1
control-arch-linux-0   Ready    control-plane,etcd,master   22h   v1.24.3+k3s1
control-arch-linux-1   Ready    control-plane,etcd,master   22h   v1.24.3+k3s1
control-arch-linux-2   Ready    control-plane,etcd,master   22h   v1.24.3+k3s1
```

Check existing namespaces.

```console
[user@host cluster]$ kubectl --kubeconfig ~/.kube/k3s.yaml get namespaces
NAME              STATUS   AGE
default           Active   11m
kube-node-lease   Active   11m
kube-public       Active   11m
kube-system       Active   11m
```

Check existing pods in all namespaes.

```console
[user@host cluster]$ kubectl --kubeconfig ~/.kube/k3s.yaml get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   coredns-b96499967-5mg7z                   1/1     Running     0          13m
kube-system   helm-install-traefik-5dp7w                0/1     Completed   3          13m
kube-system   helm-install-traefik-crd-4b4cl            0/1     Completed   0          13m
kube-system   local-path-provisioner-7b7dc8d6f5-7zkh9   1/1     Running     0          13m
kube-system   metrics-server-668d979685-t8nnp           1/1     Running     0          13m
kube-system   svclb-traefik-b5140ada-cnhn9              2/2     Running     0          11m
kube-system   svclb-traefik-b5140ada-nxzlw              2/2     Running     0          11m
kube-system   svclb-traefik-b5140ada-p8k5f              2/2     Running     0          11m
kube-system   svclb-traefik-b5140ada-q6vqx              2/2     Running     0          10m
kube-system   svclb-traefik-b5140ada-wnxzp              2/2     Running     0          11m
kube-system   svclb-traefik-b5140ada-wtn9s              2/2     Running     0          11m
kube-system   traefik-7cd4fcff68-pnwh5                  1/1     Running     0          11m
```

Check also helm command with fixed configuration.


```console
[user@host cluster]$ helm --kubeconfig ~/.kube/k3s.yaml ls --all-namespaces
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/sova/.kube/k3s.yaml
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/sova/.kube/k3s.yaml
NAME       	NAMESPACE  	REVISION	UPDATED                                	STATUS  	CHART                	APP VERSION
traefik    	kube-system	1       	2022-07-31 12:13:12.337007411 +0000 UTC	deployed	traefik-10.19.300    	2.6.2      
traefik-crd	kube-system	1       	2022-07-31 12:12:25.036720473 +0000 UTC	deployed	traefik-crd-10.19.300
```

Example application
-------------------

Create the namespace (only dev)

```console
[user@host cluster]$ ssh control-arch-linux-0_net_addr sudo kubectl create namespace retail-project-dev
namespace/retail-project-dev created
```

Check new namespace.

```console
[user@host cluster]$ ssh control-arch-linux-0_net_addr sudo kubectl get namespaces
NAME                 STATUS   AGE
default              Active   16m
kube-node-lease      Active   16m
kube-public          Active   16m
kube-system          Active   16m
retail-project-dev   Active   13s
```

