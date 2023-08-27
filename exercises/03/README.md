# Activity 3 - Using StatefulSets and PersistentVolumes

The original activity is in [PeladoNerd repository](https://github.com/pablokbs/peladonerd/blob/master/kubernetes/35/05-statefulset.yaml) but is based in a context which is using DigitalOcean as a K8s provider.
In this repository the main idea is to reuse the same yaml but using a local cluster with an on-premise k8s cluster and using a NFS server as a storage provider. 

So, for that purpose the provision files `master.sh` and `node-nfs.sh` have been modified and creted in order to install a NFS server in the master node.

The current NFS mounted volume at nodes are in `/mnt/nfs/data`