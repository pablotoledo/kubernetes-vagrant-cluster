# Activity 6 - Using Kustomizations

A __Kustomization__ file in Kubernetes is a way to customize resource configurations without having to directly modify the original YAML. This is useful in a workflow where YAML templates are reused across different environments or scenarios. Kustomization uses a file, usually named kustomization.yaml, to describe modifications or customizations that should be applied to existing resources.

We have in this folder the following files:
- `secret.yaml`: A Secret object that contains a base64-encoded password
- `pod-secret.yaml`: A Pod that consumes the Secret as an environment variable

We can create a file called `kustomization.yaml` with the following content:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

commonLabels:
  app: ejemplo

resources:
- 15-pod-secret.yaml

secretGenerator:
- name: db-credentials
  literals:
  - username=admin
  - password=secr3tpassw0rd!

images:
- name: nginx
  newTag: latest
```

In this case the `kustomization.yaml` file performs the following actions:

- __commonLabels:__ Adds a common label `app: ejemplo` to all specified resources.

- __resources:__ Specifies that the file `15-pod-secret.yaml` is a resource that should be customized and applied.

- __secretGenerator:__ Generates a Secret resource named `db-credentials` with the literals `username=admin` and `password=secr3tpassw0rd!``.

- __images:__ Alters the tag of nginx images in the resources to use the latest tag.

## How to apply a Kustomization

To apply a Kustomization, we can use the following command:

```bash
kubectl apply -k .
```

The `-k` flag tells `kubectl` to use Kustomization to apply the resources. Kubernetes will process the `kustomization.yaml` file, apply all the transformations, and then apply the resulting resources to the cluster.