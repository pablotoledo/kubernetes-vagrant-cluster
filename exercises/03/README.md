# Activity 3 - Using StatefulSets and PersistentVolumes

The original activity is in [PeladoNerd repository](https://github.com/pablokbs/peladonerd/blob/master/kubernetes/35/05-statefulset.yaml) but is based in a context which is using DigitalOcean as a K8s provider.
In this repository the main idea is to reuse the same yaml but using a local cluster with an on-premise k8s cluster and using a NFS server as a storage provider. 

So, for that purpose the provision files `master.sh` and `node-nfs.sh` have been modified and creted in order to install a NFS server in the master node.

The current NFS mounted volume at nodes are in `/mnt/nfs/data`

## Setting up the PersistentVolume and PersistentVolumeClaim

The __PersistentVolume__ represents a piece of storage in the cluster that has been provisioned by an administrator. It is a resource in the cluster just like a node is a cluster resource. In this repository the NFS server is provided by the master node in the worker nodes at `/mnt/nfs/data` directory.

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
    path: "/mnt/nfs/data"

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

So, if we create a file called `pv-and-pvc.yaml` with the previous content and apply using `kubectl apply -f pv-and-pvc.yaml` we will have a PersistentVolume and a PersistentVolumeClaim created in our cluster.

We can check the status of the PersistentVolume using `kubectl get pv` and the status of the PersistentVolumeClaim using `kubectl get pvc`.

``` bash
[k8s-master ~]# kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS   REASON   AGE
my-nfs-pv   5Gi        RWO            Retain           Bound    default/my-nfs-pvc                           3m20s
[k8s-master ~]# kubectl get pvc
NAME         STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   AGE
my-nfs-pvc   Bound    my-nfs-pv   5Gi        RWO                           3m28s
```