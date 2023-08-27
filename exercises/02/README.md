# Activity 2 - Deploy a nginx Pod with a deployment

## Deploying a Pod with more options

This yaml defines a nginx Pod:

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    env:
    - name: MI_VARIABLE
      value: "pelado"
    - name: MI_OTRA_VARIABLE
      value: "pelade"
    - name: DD_AGENT_HOST # Downward API
      valueFrom:
        fieldRef:
          fieldPath: status.hostIP
    resources:
      requests:
        memory: "64Mi"
        cpu: "200m"
      limits:
        memory: "128Mi"
        cpu: "500m"
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 20
    ports:
    - containerPort: 80
```

So we can create a file called `02-pod.yaml` and deploy it using `kubectl apply -f 02-pod.yaml`

When we want to see the yaml of a deployed resource we can use `kubectl get pod nginx -o yaml`

## Deploying a Pod with a deployment

This yaml defines a nginx Pod deployed with a deployment:

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        env:
        - name: MI_VARIABLE
          value: "pelado"
        - name: MI_OTRA_VARIABLE
          value: "pelade"
        - name: DD_AGENT_HOST
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
        resources:
          requests:
            memory: "64Mi"
            cpu: "200m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          tcpSocket:
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
        ports:
        - containerPort: 80
```

In order to deploy this pod we can create a file called `02-deployment.yaml` and deploy it using `kubectl apply -f 02-deployment.yaml`.

So if we list the pods we can see that we have 2 pods running:

```bash
kubectl get pods

NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5c7b5b7b4f-2q9q8   1/1     Running   0          2m
nginx-deployment-5c7b5b7b4f-9q9q8   1/1     Running   0          2m
```

If we remove the first one using `kubectl delete pod nginx-deployment-5c7b5b7b4f-2q9q8` we can see that the deployment will create a new one.

__Deployments are the recommended way to deploy pods in k8s.__

_If we want to deleted this deployment we just need to type `kubectl delete -f 02-deployment.yaml`_

## Deploy a nginx Pod with a daemonset

The main difference between a deployment and a daemonset is that a daemonset will deploy a pod in each node of the cluster. It's recomended in monitoring services like prometheus or datadog. A Daemonset is very similar to a deployment but without the `replicas` option.

This yaml defines a nginx Pod deployed with a daemonset:

``` yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        env:
        - name: MI_VARIABLE
          value: "pelado"
        - name: MI_OTRA_VARIABLE
          value: "pelade"
        - name: DD_AGENT_HOST
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
        resources:
          requests:
            memory: "64Mi"
            cpu: "200m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          tcpSocket:
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
        ports:
        - containerPort: 80
```

To deploy this Daemonset we can create a file called `02-daemonset.yaml` and deploy it using `kubectl apply -f 02-daemonset.yaml`.