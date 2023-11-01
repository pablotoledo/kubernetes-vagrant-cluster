# Activity 7 - Prometheus Metrics

1. **Create a Namespace for Prometheus (Optional but Recommended):**
   You might want to isolate Prometheus into its own namespace.

   ```bash
   kubectl create namespace prometheus
   ```

2. **Install Prometheus Operator with Helm:**
   If you don't have Helm installed, follow the [official guide](https://helm.sh/docs/intro/install/) to get it set up.

   Add the Prometheus community Helm repository:

   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   ```

   Install the Prometheus operator:

   ```bash
   helm install prometheus prometheus-community/kube-prometheus-stack --namespace prometheus
   ```

3. **Verify Installation:**
   Check that the Prometheus pods are running:

   ```bash
   kubectl get pods --namespace prometheus
   ```