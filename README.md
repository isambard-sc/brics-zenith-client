# brics-zenith-client
Deploy a Zenith client on a k8s or k3s to proxy a web app for Isambard platform.

For zenith client, please read [Zenith Client Documentation](https://github.com/azimuth-cloud/zenith/blob/main/docs/client.md)

## Prerequisites

- Docker: Required if you use the Docker-based initialization. Alternative, you can clone the source code from [Zenith Repo](https://github.com/isambard-sc/zenith)

- k3s or k8s cluster: running zenith client, alternatively, it can be run as a systemd service.

- kubectl: Required to interact with the K3s cluster.

- jq: Required for parsing JSON files within the scripts.

## Prepare Configuration 

1. Generate an SSH keypair (no passphrase) for use with the client:

```
ssh-keygen -t rsa -b 4096 -f test-key
```

2. Get subdomain.json file from Zenith Server setup

3. Set up enviornment file, for zenith init, following enviornment are required:

```
cp example.env development.env
```

Making sure all following variables are set in the file.

```
ZENITH_REGISTRAR_HOST="example.com"
SUBDOMAIN_FILE="/path/to/subdomain.json"
SSH_PRIKEY_FILE="/path/to/ssh_key"
```

## Zenith Client Initialisation

This is to upload SSH key to Zenith server

```
chmod +x init-zenith-docker.sh
./init-zenith-docker.sh development.env
```

## Deploy Zenith Client to Cluster

0. Switch to the context if needed
```
kubectl config get-contexts
kubectl config use-context <your-cluster>
kubectl config current-context
```

1. Create a namespace, which matches your variable set in the file

```
kubectl create namespace <your-zenith-workspace>
kubectl get namespaces
```
2. Make sure all variables are set in your enviornment file (development.env)

3. Set Default Namespace in your current context(Optional)
```
kubectl config set-context --current --namespace=<your-name-space>
```

4. Deploy zenith client to a k3s or k8s cluster
```
chmod +x deploy-zenith.sh
./deploy-zenith.sh development
```

## Useful command for troubleshooting

1. Check Helm Release Status
```
helm status zenith-client -n <your-name-space>
```

2. Check Kubernetes Pods
```
kubectl get pods -n <your-name-space>
```

3. Get Detailed Pod Information
```
kubectl describe pod <pod-name> -n <your-name-space>
```

4. Get Pod Logs
```
kubectl logs <pod-name> -n <your-name-space>
```

5. Scale Up or Down the Pods:
```
kubectl scale deployment zenith-client --replicas=0 -n <your-name-space>
```