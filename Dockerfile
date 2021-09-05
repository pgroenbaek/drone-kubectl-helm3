FROM bitnami/kubectl:1.16

LABEL maintainer "Peter Grønbæk Andersen <peter@grnbk.io>"

COPY helm /opt/drone-helm3/bin/
COPY init-helm init-kubectl /opt/drone-helm3-init/bin/
COPY helm3 /opt/helm/bin/

USER root

RUN chmod +x /opt/helm/bin/helm3
RUN chmod +x /opt/drone-helm3/bin/helm
RUN chmod +x /opt/drone-helm3-init/bin/init-helm
RUN chmod +x /opt/drone-helm3-init/bin/init-kubectl

ENV PATH="/opt/drone-helm3/bin:$PATH"

ENTRYPOINT ["/bin/bash"]

CMD ["-c"]
