# Activity 1 - Deploy a nginx pod

This `yaml` defines a nginx Pod:

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:alpine
```

## Running the nginx Pod

So we can create a file called `01-pod.yaml` and deploy it using `kubectl apply -f 01-pod.yaml`

But when you don't specify the nginx pod will be deployed in the `default` namespace, you can see that using `kubectl get pods -o wide`.

```
kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE     IP               NODE         NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          3m39s   192.168.140.65   k8s-node-2   <none>           <none>
```

## Running commands in the nginx Pod

At the moment we have the nginx pod running we can use the `exec` option as in docker in order to run commands from the container.

```bash
kubectl exec -it nginx -- sh
```

## Deleting the Pod

In order to remove the pod we just need to type:

`ginx`

As we have not defined `replicas`, k8s will not create a new Pod to guarantee the service.