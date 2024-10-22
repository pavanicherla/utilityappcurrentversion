ARG ARGOCD_VER=v2.12.6
ARG ALPINE_VER=3.20.3

FROM quay.io/argoproj/argocd:${ARGOCD_VER} AS argocd
FROM alpine:${ALPINE_VER}

COPY --from=argocd /usr/local/bin/argocd /usr/local/bin/argocd
COPY --from=argocd /usr/local/bin/kustomize /usr/local/bin/kustomize
COPY --from=argocd /usr/local/bin/helm /usr/local/bin/helm

#Dockerfile
ARG KUBECTL_VER=v1.27.0
ARG AVP_VER=1.18.1
ARG JQ_VER=1.7.1
ARG YQ_VER=v4.44.3
ARG K8SGPT_VER=v0.3.18
ARG MYSQL_VER=11.4.3-r1
ARG GIT_VER=2.46.2-r0
ARG KYVERNO_VER=v1.12.2-rc.2
ARG KUBECONFORM_VER=v0.6.7
ARG KUBELINTER_VER=v0.6.8
ARG OC_VER=4.16.9
ARG PYPI_AWSCLI_VER=1.29.10
ARG PYPI_PYYAML_VER=6.0.1
ARG BUTANE_VER=v0.22.0-1

USER root

# System modules
RUN apk update && apk upgrade
RUN apk add --no-cache \
    bash \
    sudo \
    openssh-client \
    curl \
    git \
    mysql-client \
    bind-tools \
    net-tools \
    python3 \
    postgresql-client \
    py3-pip \
    ansible \
    gcompat
  
# ENV PATH="$PATH:/root/.local/bin"

# Python libraries
RUN pip3 install --no-cache-dir --break-system-packages \
    awscli==${PYPI_AWSCLI_VER} \
    pyyaml==${PYPI_PYYAML_VER} \
    openapi2jsonschema
# RUN pipx install \
#     awscli==${PYPI_AWSCLI_VER} \
#     openapi2jsonschema

# Additional binaries
# RUN curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl \
#     && chmod +x /usr/local/bin/kubectl
RUN mkdir oc \    
    && curl -Lo oc/oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VER}/openshift-client-linux.tar.gz \
    && tar -xvf oc/oc.tar.gz -C oc/ \
    && mv oc/oc /usr/local/bin/ \
    && chmod +x /usr/local/bin/oc \
    && mv oc/kubectl /usr/local/bin/ \
    && chmod +x /usr/local/bin/kubectl
RUN curl -Lo oc/oc-install.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VER}/openshift-install-linux-4.16.9.tar.gz \
    && tar -xvf oc/oc-install.tar.gz -C oc/ \
    && mv oc/openshift-install /usr/local/bin/ \
    && chmod +x /usr/local/bin/openshift-install \
    && rm -rf oc
RUN curl -Lo /usr/local/bin/argocd-vault-plugin https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VER}/argocd-vault-plugin_${AVP_VER}_linux_amd64 \
    && chmod +x /usr/local/bin/argocd-vault-plugin
RUN curl -Lo /usr/local/bin/jq https://github.com/jqlang/jq/releases/download/jq-${JQ_VER}/jq-linux64 \
    && chmod +x /usr/local/bin/jq
RUN curl -Lo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VER}/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq
RUN mkdir kubeconform \
    && curl -Lo kubeconform/kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/${KUBECONFORM_VER}/kubeconform-linux-amd64.tar.gz \
    && tar -xvf kubeconform/kubeconform.tar.gz -C kubeconform/ \
    && mv kubeconform/kubeconform /usr/local/bin/ \
    && chmod +x /usr/local/bin/kubeconform \
    && rm -rf kubeconform 
RUN curl -Lo /usr/local/bin/butane https://mirror.openshift.com/pub/openshift-v4/clients/butane/${BUTANE_VER}/butane-amd64 \
    && chmod +x /usr/local/bin/butane
RUN mkdir nmstate \
    && curl -Lo nmstate/nmstatectl-linux-x64.zip https://github.com/nmstate/nmstate/releases/download/v2.2.37/nmstatectl-linux-x64.zip \
    && unzip nmstate/nmstatectl-linux-x64.zip -d nmstate/ \
    && mv nmstate/nmstatectl /usr/local/bin/ \
    && chmod +x /usr/local/bin/nmstatectl \
    && rm -rf nmstate

# RUN mkdir kube-linter \
#     && curl -Lo kube-linter/kube-linter.tar.gz https://github.com/stackrox/kube-linter/releases/download/${KUBELINTER_VER}/kube-linter-linux.tar.gz \
#     && tar -xvf kube-linter/kube-linter.tar.gz -C kube-linter/ \
#     && mv kube-linter/kube-linter /usr/local/bin/ \
#     && chmod +x /usr/local/bin/kube-linter \
#     && rm -rf kube-linter
# RUN mkdir kyverno \
#     && curl -Lo kyverno/kyverno.tar.gz https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VER}/kyverno-cli_${KYVERNO_VER}_linux_x86_64.tar.gz \
#     && tar -xvf kyverno/kyverno.tar.gz -C kyverno/ \
#     && cp kyverno/kyverno /usr/local/bin/ \
#     && rm -rf kyverno \
#     && chmod +x /usr/local/bin/kyverno

# Create user
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Singapore /etc/localtime

RUN adduser -D -u 2001 adak8s wheel
RUN echo "" >> /etc/sudoers
RUN echo "### Removing sudo password for adak8s" >> /etc/sudoers
RUN echo "adak8s ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Change user
USER adak8s
WORKDIR /home/adak8s