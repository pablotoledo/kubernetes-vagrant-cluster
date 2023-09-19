# Activity 5 - Using ConfigMaps and Secrets

A ConfigMap is an object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume.

A Secret is an object used to store confidential data in key-value pairs. Pods can consume secrets as environment variables, command-line arguments, or as configuration files in a volume.

## Consuming ConfigMaps and Secrets as environment variables

__Explanation:__ 

- __ConfigMaps:__ You can use a ConfigMap in a environment variables by referencing the data stored in the ConfigMap under the specific key you want to use.
- __Secrets:__ Similarly, you can use a Secre in environment variables. However, the stored data is base64-encoded and will be automatically decoded by Kubernetes when you consume it in a pod

__Example:__

This is an example of a ConfigMap and a Secret, we can create a file called `app-config.yaml` with the following content and apply using `kubectl apply -f app-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_MODE: "production"

---

apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  APP_SECRET: c2VjcmV0cGFzc3dvcmQ=  # 'secretpassword' encoded in base64

```

Now, we can create a file called `app-pod.yaml` with the following content and apply using `kubectl apply -f app-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-container
    image: nginx:latest
    env:
    - name: APP_MODE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_MODE
    - name: APP_SECRET
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: APP_SECRET
```

## Consuming ConfigMaps and Secrets as command-line arguments

## Consuming ConfigMaps and Secrets as configuration files in a volume

