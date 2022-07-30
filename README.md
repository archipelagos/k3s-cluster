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

Controling cluster
------------------

At this moment your cluster should be fine. In order to communicate with the cluster retrieve the certificate from any of server nodes.

Save this content on your local machine in `~/.kube/<your config file>`.

```console
user@host:~$ cat /etc/rancher/k3s/k3s.yaml
```

Locate in the file your cluster and modify `server` section. It should point to any of your server machines.

Once the steps before are applied, you can execute the following script to load the Kubernetes config.

```console
user@host:~$ export KUBECONFIG=/.kube/<your config file>
```

Now you should be able to use the cluster.

Check this by executing the following command.

```console
user@host:~$ kubectl get nodes
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

