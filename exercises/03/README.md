# Activity 3 - Using StatefulSets and PersistentVolumes

The original activity is in [PeladoNerd repository](https://github.com/pablokbs/peladonerd/blob/master/kubernetes/35/05-statefulset.yaml) but is based in a context which is using DigitalOcean as a K8s provider.
In this repository the main idea is to reuse the same yaml but using a local cluster with an on-premise k8s cluster and using a NFS server as a storage provider. 

So, for that purpose the provision files `master.sh` and `node-nfs.sh` have been modified and creted in order to install a NFS server in the master node.

The current NFS mounted volume at nodes are in `/mnt/nfs/data`

## Setting up the PersistentVolume and PersistentVolumeClaim

The __PersistentVolume__ represents a piece of storage in the cluster that has been provisioned by an administrator. It is a resource in the cluster just like a node is a cluster resource. In this repository the NFS server is provided by the master node at `/nfs/data` and the PersistentVolume will be created using this path (_masterIP:/nfs/data_).

The __PersistentVolumeClaim__ is a request for storage by a user. It is similar to a pod. Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes (e.g., can be mounted once read/write or many times read-only).

This is the yaml file for the PersistentVolume and PersistentVolumeClaim adapted to our K8s cluster:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-nfs-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.0.70 # <NFS_SERVER_IP> take care of this
    path: "/nfs/data"

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-nfs-pvc
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  volumeName: my-nfs-pv

```

So, if we create a file called `03-pv-and-pvc.yaml` with the previous content and apply using `kubectl apply -f 03-pv-and-pvc.yaml` we will have a PersistentVolume and a PersistentVolumeClaim created in our cluster.

We can check the status of the PersistentVolume using `kubectl get pv` and the status of the PersistentVolumeClaim using `kubectl get pvc`.

``` bash
[k8s-master ~]# kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS   REASON   AGE
my-nfs-pv   5Gi        RWO            Retain           Bound    default/my-nfs-pvc                           3m20s
[k8s-master ~]# kubectl get pvc
NAME         STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   AGE
my-nfs-pvc   Bound    my-nfs-pv   5Gi        RWO                           3m28s
```

So, we need to remove PersistentVolume and PersistentVolumeClaim in order to continue with the activity, so we can use `kubectl delete -f 03-pv-and-pvc.yaml` to remove both resources.

## Setting up the StatefulSet

All the previuos steps were necessary in order to introduce the StatefulSet.

A __StatefulSet__ in Kubernetes is similar to a Deployment, but each Pod created by a StatefulSet is guaranteed to have a unique identity and a persistent disk attached to it. This is useful for stateful applications like databases, where each instance needs to have its own identity and data.

The adaptation of the original yaml file is the following:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-nfs-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.0.70 # <NFS_SERVER_IP> take care of this
    path: "/nfs/data"
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: my-csi-app-set
spec:
  selector:
    matchLabels:
      app: mypod
  serviceName: "my-frontend"
  replicas: 1
  template:
    metadata:
      labels:
        app: mypod
    spec:
      containers:
      - name: my-frontend
        image: busybox
        args:
        - sleep
        - infinity
        volumeMounts:
        - mountPath: "/data"
          name: my-nfs-storage
  volumeClaimTemplates:
  - metadata:
      name: my-nfs-storage
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 5Gi
      storageClassName: ""
      volumeName: my-nfs-pv
```

So, if we create a file called `03-statefulset.yaml` with the previous content and apply using `kubectl apply -f 03-statefulset.yaml` we will have a StatefulSet created in our cluster.

In order to understand the events during the creation of the StatefulSet we can use `kubectl describe statefulset my-csi-app-set`, and in the last lines we can see the following:

```bash

[k8s-master ~]# kubectl describe statefulset my-csi-app-set
...
Events:
  Type    Reason            Age    From                    Message
  ----    ------            ----   ----                    -------
  Normal  SuccessfulCreate  2m47s  statefulset-controller  create Claim my-nfs-storage-my-csi-app-set-0 Pod my-csi-app-set-0 in StatefulSet my-csi-app-set success
  Normal  SuccessfulCreate  2m47s  statefulset-controller  create Pod my-csi-app-set-0 in StatefulSet my-csi-app-set successful
```

