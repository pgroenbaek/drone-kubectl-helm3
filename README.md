
# drone-kubectl-helm3
This [Drone CI](https://drone.io/) plugin allows you to use `kubectl` and `helm` in pipelines without setting up kubectl authentication in your pipeline commands.


## Usage

Create a [pipeline](https://docs.drone.io/pipeline/overview/) in Drone CI.

The following example shows how to configure a pipeline step to use this plugin from Docker Hub:

```yaml
kind: pipeline
name: check version

steps:
  - name: versions
    image: pgroenbaek/drone-kubectl-helm3
    settings:
      kubernetes_server:
        from_secret: k8s_server
      kubernetes_cert:
        from_secret: k8s_cert
      kubernetes_token:
        from_secret: k8s_token
    commands:
      - kubectl --version
      - helm --version

```

You need to create three secrets for the pipeline with the kubernetes credentials named `k8s_server`, `k8s_cert` and `k8s_token`.

If you don't know how to get these read the next section.


### How to get the kubernetes cluster credentials
You need to have a service account with proper privileges and a service account token so that your Drone CI pipeline can authenticate with the kubernetes cluster.

Create one using the following command:
```bash
kubectl create serviceaccount <NAME>
kubectl create clusterrolebinding <NAME> --clusterrole=cluster-admin --serviceaccount=default:<NAME>
```

After creating a service account, you can find your server url by using the command:
```bash
kubectl config view -o jsonpath='{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'
```

If the service account name is `deploy`, you would have a secret named `deploy-token-xxxx` (xxxx is some random characters).

You can get your token and certificate by using the following commands:

k8s_cert:
```bash
kubectl get secret deploy-token-xxxx -o jsonpath='{.data.ca\.crt}' && echo
```

k8s_token:
```bash
kubectl get secret deploy-token-xxxx -o jsonpath='{.data.token}' | base64 --decode && echo
```

### Using from a private container registry

If you would rather use the plugin from a private container registry, clone this repository, then build and push the created docker image to your private registry:

```bash
docker login -u <USERNAME> <REGISTRY_URL>
docker build -t >TAGNAME> . 
docker tag <TAGNAME> <REGISTRY_URL>/drone-kubectl-helm3
docker push <REGISTRY_URL>/drone-kubectl-helm3
```

Replace the `<USERNAME>`, `<TAGNAME>` and `<REGISTRY_URL>` parameters accordingly.

Now you can use the docker image you built as a drone plugin:

```yaml
kind: pipeline
name: check version

steps:
  - name: versions
    image: <REGISTRY_URL>/<USERNAME>/drone-kubectl-helm3:<TAGNAME>
    settings:
      kubernetes_server:
        from_secret: k8s_server
      kubernetes_cert:
        from_secret: k8s_cert
      kubernetes_token:
        from_secret: k8s_token
    commands:
      - kubectl --version
      - helm --version

image_pull_secrets:
- docker_config_json
```

Note the `image_pull_secrets` parameter at the bottom.

For Drone CI to know how to authenticate with your private container registry a secret named `docker_config_json` must be defined for the pipeline.

Add the following as a secret named `docker_config_json`:

```json
{"auths": {"<REGISTRY_URL>": {"auth": "<PASSWORD>"}}}
```
Replace the `<REGISTRY_URL>` and `<PASSWORD>` parameters accordingly.

## License

This drone plugin was created by Peter Grønbæk Andersen based on [drone-kubectl](https://github.com/sinlead/drone-kubectl) and is licensed under [GNU GPL v3](./LICENSE).

