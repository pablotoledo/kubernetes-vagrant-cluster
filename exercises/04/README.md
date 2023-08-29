# Activity 4 - K8s Networking - K8s Services: ClusterIP, NodePort and LoadBalancer

## K8s Networking

As is explained in the [YouTube video](https://www.youtube.com/watch?v=DCoBcpOA7W4), the K8s networking is based this main ideas:

* A K8s cluster runs a CNI (Container Network Interface) plugin. This plugin is responsible for setting up the network for the cluster. The most common CNI plugins are Calico, Flannel, Weave Net, Cilium, etc.
* The CNI is responsible to assign an IP address to each pod. This IP address is reachable from any other pod in the cluster.

![K8s Networking](./k8s-networking.png)

## K8s Services

K8s Services are managed by kube-proxy. The kube-proxy is a network proxy that runs on each node in the cluster. It maintains network rules on nodes. These network rules allow network communication to your Pods from network sessions inside or outside of your cluster.

There are 3 main types of Services:

* __ClusterIP__: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default ServiceType. You don't need to know the IP address of the Pod to communicate with it, and you know that the Service will always be reachable from the same IP address.
* __NodePort__: Exposes the Service on each Node's IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service, from outside the cluster, by requesting `<NodeIP>:<NodePort>`.
* __LoadBalancer__: Exposes the Service externally using a cloud provider's load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.