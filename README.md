# brics-zenith-client

Deploy a Zenith client on a k8s or k3s to proxy a web app for Isambard platform.

For zenith client, please read [Zenith Client Documentation](https://github.com/azimuth-cloud/zenith/blob/main/docs/client.md)

## Prerequisites

- Docker/Podman: Required to use the Docker/Podman-based initialization script. Alternatively, you can clone the source code from [Zenith Repo](https://github.com/isambard-sc/zenith)

- k3s or k8s cluster: running zenith client, alternatively, it can be run as a systemd service.

- kubectl: Required to interact with the K3s cluster.

- helm: Required to deploy the Helm chart to the K3s cluster.

- jq: Required for parsing JSON files within the scripts.

## Prepare Configuration

1. Generate an SSH keypair (no passphrase) for use with the client:

   ```shell
   ssh-keygen -t rsa -b 4096 -f test-key
   ```

2. Get `subdomain.json` file from Zenith Server setup

3. Set up environment file, for zenith init, following environment are required:

   ```shell
   cp example.env development.env
   ```

   Making sure all following variables are set in the file.

   ```shell
   ZENITH_REGISTRAR_HOST="example.com"
   SUBDOMAIN_FILE="/path/to/subdomain.json"
   SSH_PRIKEY_FILE="/path/to/ssh_key"
   ```

## Zenith Client Initialisation

This is to upload SSH key to Zenith server

```shell
chmod +x init-zenith-docker.sh
./init-zenith-docker.sh development.env
```

> [!NOTE]
> If you are using `podman`, use the `init-zenith-podman.sh` script. This invokes `podman run` with `--security-opt label=disable` to avoid issues with bind mounting host files caused by SELinux labelling. This may be useful in Linux distributions where SELinux is used, such as RHEL and derivatives.

## Deploy Zenith Client to Cluster

0. Switch to the context if needed

   ```shell
   kubectl config get-contexts
   kubectl config use-context <your-cluster>
   kubectl config current-context
   ```

1. Make sure all variables are set in your environment file (`development.env`)

2. Set the default namespace in your current context (optional)

   ```shell
   kubectl config set-context --current --namespace=<your-name-space>
   ```

3. Deploy zenith client to a k3s or k8s cluster

   ```shell
   chmod +x deploy-zenith-client.sh
   ./deploy-zenith-client.sh development.env
   ```

   > [!TIP]
   > Additional command line arguments after the environment file will be passed to `helm upgrade`. This is useful to add options for debugging the chart, e.g. for a dry-run with debug output
   >
   > ```shell
   > ./deploy-zenith-client.sh development.env --debug --dry-run
   > ```

> [!NOTE]
> If the service to be proxied is listening on the host where Zenith client is running and outside of the Kubernetes cluster (e.g. listening on a host loopback address, `127.0.0.1` or `::1`), then the chart will need to have Zenith client pod's `hostNetwork` setting set to `true`. This can be done by passing an extra argument to set the `podHostNetwork` chart value to `./deploy-zenith-client.sh`:
>
> ```shell
> ./deploy-zenith-client.sh development.env --set podHostNetwork=true
> ```

## Useful commands for troubleshooting

- Check Helm Release Status

  ```shell
  helm status zenith-client -n <your-name-space>
  ```

- List all Helm releases and their statuses

  ```shell
  helm list --all-namespaces --all
  ```

- Remove a Helm release (e.g. after failed deployment)

  ```shell
  helm uninstall -n <your-name-space> <release-name>
  ```

- Check Kubernetes Pods

  ```shell
  kubectl get pods -n <your-name-space>
  ```

- Get Detailed Pod Information

  ```shell
  kubectl describe pod <pod-name> -n <your-name-space>
  ```

- Get Pod Logs

  ```shell
  kubectl logs <pod-name> -n <your-name-space>
  ```

  ```shell
  kubectl logs -n <your-name-space> -l app=zenith-client --follow
  ```

- View Kubernetes events, useful if pod logs are unavailable

  ```shell
  kubectl events -n <your-name-space>
  ```

- Start an interactive bash shell inside a container in a pod

  ```shell
  kubectl exec -n <your-name-space> -it <pod-name> -- bash
  ```

- Scale Up or Down the Pods:

  ```shell
  kubectl scale deployment zenith-client --replicas=0 -n <your-name-space>
  ```
