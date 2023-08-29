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

## Activities with K8s Services

The following activities will be using a Pod with Ubuntu in order to have the internal point of view of the cluster. The Pod will be created using the following yaml file, called `04-ubuntu-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu
spec:
  containers:
  - name: ubuntu
    image: nicolaka/netshoot
    args:
    - sleep
    - infinity
```

So we can create the Pod using `kubectl apply -f 04-ubuntu-pod.yaml` and check the status using `kubectl get pods`.

### ClusterIP

The ClusterIP is the default ServiceType. So, if we create a Service without specifying the ServiceType, the Service will be created as ClusterIP.

The following yaml file, called `04-svc-clusterip.yaml`, will create a Service with the default ServiceType (ClusterIP):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello
spec:
  replicas: 3
  selector:
    matchLabels:
      role: hello # this is important for the Service selector
  template:
    metadata:
      labels:
        role: hello # this is important for the Service selector
    spec:
      containers:
      - name: hello
        image: gcr.io/google-samples/hello-app:1.0
        ports:
        - containerPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: hello
spec:
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    role: hello
```

We can create the Service using `kubectl apply -f 04-svc-clusterip.yaml` and check the status using `kubectl get svc`.

```bash
[vagrant@k8s-master ~]$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
hello        ClusterIP   10.99.106.216   <none>        8080/TCP   75s
```bash