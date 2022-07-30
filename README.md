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

