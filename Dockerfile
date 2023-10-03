FROM quay.io/argoproj/argocd:v2.7.2
#Dockerfile
USER root
RUN apt-get update -y
RUN apt-get install -y \
        mysql-client \
        libcurl4 \
        curl \
        git \
        netcat \
        bind9 dnsutils \
        python3-pip \
        libcap2 \
        openssh-client  \
        openssl \
        perl \
        libssh-4 \
        libncurses5-dev libncursesw5-dev \
        libx11-dev
RUN pip install --upgrade pip
RUN pip3 install --no-cache-dir \
        awscli==1.29.10 \
        jq==1.6
RUN curl -Lo yq https://github.com/mikefarah/yq/releases/download/{v4.30.5}/yq/_{v4.30.5}_linux-amd64
RUN curl -Lo argocd-vault-plugin https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/{v1.14.0}/argocd-vault-plugin_{v1.14.0}_linux_amd64
RUN apt-get clean
RUN rm -rf /var/cache/yum
# Switch back to non-root user 
USER 999
