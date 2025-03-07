
# drone-kubectl-helm3

[![Docker Hub release (latest by date)](https://img.shields.io/docker/v/pgroenbaek/drone-kubectl-helm3?style=flat&label=Latest%20Version&sort=semver)](https://hub.docker.com/r/pgroenbaek/drone-kubectl-helm3/tags)
[![Drone CI](https://img.shields.io/badge/Drone%20CI-gray?style=flat&logo=drone&logoColor=white)](https://www.drone.io/)
[![Helm 3.16.3](https://img.shields.io/badge/version-3.16.3-darkblue?style=flat&logo=helm&logoColor=%23ffffff&label=Helm&color=%230F1689)](https://helm.sh/)
[![Kubectl 1.31](https://img.shields.io/badge/version-1.31-grayblue?style=flat&logo=kubernetes&logoColor=%23ffffff&label=Kubectl&color=%23326CE5)](https://kubernetes.io/docs/reference/kubectl/)
[![License GNU GPL v3](https://img.shields.io/badge/License-%20%20GNU%20GPL%20v3%20-lightgrey?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA2NDAgNTEyIj4KICA8IS0tIEZvbnQgQXdlc29tZSBGcmVlIDYuNy4yIGJ5IEBmb250YXdlc29tZSAtIGh0dHBzOi8vZm9udGF3ZXNvbWUuY29tIExpY2Vuc2UgLSBodHRwczovL2ZvbnRhd2Vzb21lLmNvbS9saWNlbnNlL2ZyZWUgQ29weXJpZ2h0IDIwMjUgRm9udGljb25zLCBJbmMuIC0tPgogIDxwYXRoIGZpbGw9IndoaXRlIiBkPSJNMzg0IDMybDEyOCAwYzE3LjcgMCAzMiAxNC4zIDMyIDMycy0xNC4zIDMyLTMyIDMyTDM5OC40IDk2Yy01LjIgMjUuOC0yMi45IDQ3LjEtNDYuNCA1Ny4zTDM1MiA0NDhsMTYwIDBjMTcuNyAwIDMyIDE0LjMgMzIgMzJzLTE0LjMgMzItMzIgMzJsLTE5MiAwLTE5MiAwYy0xNy43IDAtMzItMTQuMy0zMi0zMnMxNC4zLTMyIDMyLTMybDE2MCAwIDAtMjk0LjdjLTIzLjUtMTAuMy00MS4yLTMxLjYtNDYuNC01Ny4zTDEyOCA5NmMtMTcuNyAwLTMyLTE0LjMtMzItMzJzMTQuMy0zMiAzMi0zMmwxMjggMGMxNC42LTE5LjQgMzcuOC0zMiA2NC0zMnM0OS40IDEyLjYgNjQgMzJ6bTU1LjYgMjg4bDE0NC45IDBMNTEyIDE5NS44IDQzOS42IDMyMHpNNTEyIDQxNmMtNjIuOSAwLTExNS4yLTM0LTEyNi03OC45Yy0yLjYtMTEgMS0yMi4zIDYuNy0zMi4xbDk1LjItMTYzLjJjNS04LjYgMTQuMi0xMy44IDI0LjEtMTMuOHMxOS4xIDUuMyAyNC4xIDEzLjhsOTUuMiAxNjMuMmM1LjcgOS44IDkuMyAyMS4xIDYuNyAzMi4xQzYyNy4yIDM4MiA1NzQuOSA0MTYgNTEyIDQxNnpNMTI2LjggMTk1LjhMNTQuNCAzMjBsMTQ0LjkgMEwxMjYuOCAxOTUuOHpNLjkgMzM3LjFjLTIuNi0xMSAxLTIyLjMgNi43LTMyLjFsOTUuMi0xNjMuMmM1LTguNiAxNC4yLTEzLjggMjQuMS0xMy44czE5LjEgNS4zIDI0LjEgMTMuOGw5NS4yIDE2My4yYzUuNyA5LjggOS4zIDIxLjEgNi43IDMyLjFDMjQyIDM4MiAxODkuNyA0MTYgMTI2LjggNDE2UzExLjcgMzgyIC45IDMzNy4xeiIvPgo8L3N2Zz4=&logoColor=%23ffffff)](/LICENSE)

This [Drone CI](https://drone.io/) plugin allows you to use `kubectl` and `helm` in pipelines without setting up kubectl authentication manually as pipeline commands.

## Usage

The following example shows how to configure a pipeline step to use the plugin via Docker Hub:

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

You need to define `k8s_cert` and `k8s_token` as pipeline secrets. You also need to specify the kubernetes service account name and server url.

Read the next section if you don't know how to get these.

## Getting the kubernetes cluster credentials
There is a slight variation in how to create the credentials depending on the kubernetes version.

Kubernetes versions 1.23 and older will automatically create a token for you when creating the service account, while you manually need to create one in kubernetes versions 1.24 and newer.

### Kubernetes 1.24 and newer
First create a service account in the kubernetes cluster. This service account allows the pipeline to perform work on the cluster.
```bash
kubectl create serviceaccount <SERVICE_ACCOUNT_NAME>
kubectl create clusterrolebinding <SERVICE_ACCOUNT_NAME> --clusterrole=cluster-admin --serviceaccount=default:<SERVICE_ACCOUNT_NAME>
```

Create the kubernetes auth token:
```bash
kubectl create token <SERVICE_ACCOUNT_NAME> -n default --duration=8760h
```

**NOTE:** The token created with the above command will last for one year, change `8760h` if needed.

You can find your server url by using this command:
```bash
kubectl config view -o jsonpath='{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'
```

You can find the certificate by using this command:
```bash
kubectl get configmap -n kube-system kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' | base64 -w 0
```

### Kubernetes 1.23 and older
First create a service account in the kubernetes cluster. This service account allows the pipeline to perform work on the cluster.
```bash
kubectl create serviceaccount <SERVICE_ACCOUNT_NAME>
kubectl create clusterrolebinding <SERVICE_ACCOUNT_NAME> --clusterrole=cluster-admin --serviceaccount=default:<SERVICE_ACCOUNT_NAME>
```

You can find your server url by using this command:
```bash
kubectl config view -o jsonpath='{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'
```

If the service account name is `deploy`, you would now have a secret named `deploy-token-xxxx` (xxxx is some random characters).

You can find the token by using this command:
```bash
kubectl get secret deploy-token-xxxx -o jsonpath='{.data.token}' | base64 --decode && echo
```

You can find the certificate by using this command:
```bash
kubectl get secret deploy-token-xxxx -o jsonpath='{.data.ca\.crt}' && echo
```


## Using a private container registry

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
      kubernetes_cert:
        from_secret: k8s_cert
      kubernetes_token:
        from_secret: k8s_token
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

