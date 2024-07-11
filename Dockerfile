ARG ARGOCD_VERSION=v2.11.4
ARG ALPINE_VERSION=3.18.4

FROM quay.io/argoproj/argocd:${ARGOCD_VERSION} AS ARGOCD
FROM alpine:${ALPINE_VERSION} AS base

COPY --from=ARGOCD /usr/local/bin/argocd /usr/local/bin/argocd
COPY --from=ARGOCD /usr/local/bin/kustomize /usr/local/bin/kustomize
COPY --from=ARGOCD /usr/local/bin/helm /usr/local/bin/helm

#Dockerfile
ARG PYTHON_VERSION=3.12.4
ARG KUBECTL_VERSION=v1.26.0
ARG AVP_VERSION=1.16.2
ARG JQ_VERSION=1.6
ARG YQ_VERSION=v4.35.2
ARG K8SGPT_VERSION=v0.3.18
ARG MYSQL_VERSION=10.11.6-r0
#ARG GIT_VERSION=2.45.2
ARG KYVERNO_VERSION=v1.9.1


USER root

# System modules
RUN apk update && apk upgrade
RUN apk add bash
RUN apk add openssl 
RUN apk add  sudo 
RUN apk add openssh-client 
RUN apk add curl 
RUN apk add perl 
RUN apk add mariadb 
RUN apk add sqlite 
#RUN apk add git=${GIT_VERSION} 
RUN apk add mysql-client=${MYSQL_VERSION} 
RUN apk add bind-tools 
RUN apk add net-tools 
RUN apk add coreutils 
RUN apk add python3=${PYTHON_VERSION} 
RUN apk add py3-pip

# Python libraries
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir \
    awscli==1.29.10
   

# Additional binaries
RUN curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl
RUN curl -Lo /usr/local/bin/argocd-vault-plugin https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_amd64 \
    && chmod +x /usr/local/bin/argocd-vault-plugin
RUN curl -Lo /usr/local/bin/jq https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 \
    && chmod +x /usr/local/bin/jq
RUN curl -Lo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq
RUN mkdir kyverno \
    && curl -Lo kyverno/kyverno.tar.gz https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/kyverno-cli_${KYVERNO_VERSION}_linux_x86_64.tar.gz \
    && tar -xvf kyverno/kyverno.tar.gz -C kyverno/ \
    && cp kyverno/kyverno /usr/local/bin/ \
    && rm -rf kyverno \
    && chmod +x /usr/local/bin/kyverno

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
