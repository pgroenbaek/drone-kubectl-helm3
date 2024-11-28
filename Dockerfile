FROM bitnami/kubectl:1.31

LABEL maintainer "Peter Grønbæk Andersen <peter@grnbk.io>"

USER root

ADD https://get.helm.sh/helm-v3.16.3-linux-amd64.tar.gz /tmp/helm-v3.16.3-linux-amd64.tar.gz

RUN cd /tmp && tar -xvzf helm-v3.16.3-linux-amd64.tar.gz
RUN mkdir -p /opt/helm/bin/
RUN cp /tmp/linux-amd64/helm /opt/helm/bin/
RUN rm /tmp/helm-v3.16.3-linux-amd64.tar.gz
RUN rm -r /tmp/linux-amd64

COPY helm /opt/drone-kubectl-helm3-init/bin/
COPY kubectl /opt/drone-kubectl-helm3-init/bin/
COPY init-kubectl /opt/drone-kubectl-helm3-init/bin/

RUN chmod +x /opt/helm/bin/helm
RUN chmod +x /opt/drone-kubectl-helm3-init/bin/helm
RUN chmod +x /opt/drone-kubectl-helm3-init/bin/kubectl
RUN chmod +x /opt/drone-kubectl-helm3-init/bin/init-kubectl

ENV PATH="/opt/drone-kubectl-helm3/bin:$PATH"

ENTRYPOINT ["/bin/bash"]

CMD ["-c"]
