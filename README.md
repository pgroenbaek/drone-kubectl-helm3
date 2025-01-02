
# drone-kubectl-helm3
This [Drone CI](https://drone.io/) plugin allows you to use `kubectl` and `helm` in pipelines without setting up kubectl authentication manually as pipeline commands.

## Usage

### Kubernetes 1.24 or newer
First create a service account in the kubernetes cluster. This service account allows the pipeline to perform work on the cluster.
```bash
kubectl create serviceaccount <SERVICE_ACCOUNT_NAME>
kubectl create clusterrolebinding <SERVICE_ACCOUNT_NAME> --clusterrole=cluster-admin --serviceaccount=default:<SERVICE_ACCOUNT_NAME>
kubectl create token <SERVICE_ACCOUNT_NAME> -n default --duration=8760h
```

*NOTE:* The token created with the above command will last for one year, change `8760h` if needed.

You can find your server url by using this command:
```bash
kubectl config view -o jsonpath='{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'
```

You can find the certificate by using this command:
```bash
kubectl get configmap -n kube-system kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' | base64 -w 0
```

The following example shows how to configure a pipeline step to use the plugin from Docker Hub for Kubernetes 1.24 or newer:

```yaml
kind: pipeline
name: check version

steps:
  - name: versions
    image: pgroenbaek/drone-kubectl-helm3
    settings:
      kubernetes_user: <SERVICE_ACCOUNT_NAME>
      kubernetes_server: <SERVER_URL>
      kubernetes_cert:
        from_secret: k8s_cert
      kubernetes_token:
        from_secret: k8s_token
    commands:
      - kubectl version
      - helm version
```

Define `k8s_cert` and `k8s_token` as pipeline secrets with the cert and token values you just created.

### Kubernetes 1.23 or older
First create a service account in the kubernetes cluster. This service account allows the pipeline to perform work on the cluster.
```bash
kubectl create serviceaccount <SERVICE_ACCOUNT_NAME>
kubectl create clusterrolebinding <SERVICE_ACCOUNT_NAME> --clusterrole=cluster-admin --serviceaccount=default:<SERVICE_ACCOUNT_NAME>
```

After creating a service account, you can find your server url by using the command:
```bash
kubectl config view -o jsonpath='{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'
```

If the service account name is `deploy`, you would now have a secret named `deploy-token-xxxx` (xxxx is some random characters).

You can get your token and certificate by using the following commands:

k8s_cert:
```bash
kubectl get secret deploy-token-xxxx -o jsonpath='{.data.ca\.crt}' && echo
```

k8s_token:
```bash
kubectl get secret deploy-token-xxxx -o jsonpath='{.data.token}' | base64 --decode && echo
```

The following example shows how to configure a pipeline step to use the plugin from Docker Hub for Kubernetes 1.23 or older:

```yaml
kind: pipeline
name: check version

steps:
  - name: versions
    image: pgroenbaek/drone-kubectl-helm3
    settings:
      kubernetes_user: <SERVICE_ACCOUNT_NAME>
      kubernetes_server: <SERVER_URL>
      kubernetes_cert:
        from_secret: k8s_cert
      kubernetes_token:
        from_secret: k8s_token
    commands:
      - kubectl version
      - helm version

```

Define `k8s_cert` and `k8s_token` as pipeline secrets with the cert and token values you just created.

### Using a private container registry

If you would rather use the plugin from a private container registry, clone this repository, then build and push the created docker image to your private registry:

```bash
docker login -u <USERNAME> <REGISTRY_URL>
docker build -t drone-kubectl-helm3 . 
docker tag drone-kubectl-helm3 <REGISTRY_URL>/drone-kubectl-helm3:<TAGNAME>
docker push <REGISTRY_URL>/drone-kubectl-helm3:<TAGNAME>
```

Replace the `<USERNAME>`, `<TAGNAME>` and `<REGISTRY_URL>` parameters with your values.

Now you can use the docker image you built as a drone plugin:

```yaml
kind: pipeline
name: check version

steps:
  - name: versions
    image: <REGISTRY_URL>/drone-kubectl-helm3:<TAGNAME>
    settings:
      kubernetes_user: <SERVICE_ACCOUNT_NAME>
      kubernetes_server: <SERVER_URL>
    commands:
      - kubectl version
      - helm version

image_pull_secrets:
- docker_config_json
```

Note the `image_pull_secrets` parameter at the bottom.

For Drone CI to know how to authenticate with your private container registry a secret named `docker_config_json` must be defined for the pipeline.

Add the following as a secret named `docker_config_json`:

```json
{"auths": {"<REGISTRY_URL>": {"auth": "<PASSWORD>"}}}
```
Replace the `<REGISTRY_URL>` and `<PASSWORD>` parameters with your values.

## License

This drone plugin was created by Peter Grønbæk Andersen based on [drone-kubectl](https://github.com/sinlead/drone-kubectl) and is licensed under [GNU GPL v3](./LICENSE).

