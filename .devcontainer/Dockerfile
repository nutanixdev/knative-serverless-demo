FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG TARGETARCH
ARG KUBECTL_VERSION
ARG KN_VERSION
ARG FUNC_VERSION
ARG PACK_VERSION
ARG K9S_VERSION
ARG AWS_IAM_AUTHENTICATOR_VERSION

USER root

RUN apt-get update && apt-get install -y \
    curl wget unzip jq ca-certificates gnupg lsb-release zsh make tree vim git \
    && rm -rf /var/lib/apt/lists/*

# pack CLI
RUN curl -L -o /tmp/pack.tgz \
    "https://github.com/buildpacks/pack/releases/download/v${PACK_VERSION}/pack-v${PACK_VERSION}-linux.tgz" \
    && tar -xzf /tmp/pack.tgz -C /usr/local/bin pack \
    && rm -f /tmp/pack.tgz

# kubectl
RUN curl -L -o /usr/local/bin/kubectl \
    "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
    && chmod +x /usr/local/bin/kubectl

# kn CLI
RUN curl -L -o /usr/local/bin/kn \
    "https://github.com/knative/client/releases/download/knative-v${KN_VERSION}/kn-linux-${TARGETARCH}" \
    && chmod +x /usr/local/bin/kn

# kn func plugin
RUN curl -L -o /usr/local/bin/kn-func \
    "https://github.com/knative/func/releases/download/knative-v${FUNC_VERSION}/func_linux_${TARGETARCH}" \
    && chmod +x /usr/local/bin/kn-func

# aws-iam-authenticator
RUN curl -L -o /usr/local/bin/aws-iam-authenticator \
    "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_${TARGETARCH}" \
    && chmod +x /usr/local/bin/aws-iam-authenticator

# kubectx
RUN curl -L -o /usr/local/bin/kubectx \
    "https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx" \
    && chmod +x /usr/local/bin/kubectx

# kubens
RUN curl -L -o /usr/local/bin/kubens \
    "https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens" \
    && chmod +x /usr/local/bin/kubens

# k9s
RUN curl -L -o /tmp/k9s.tar.gz \
    "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz" \
    && tar -xzf /tmp/k9s.tar.gz -C /usr/local/bin k9s \
    && rm -f /tmp/k9s.tar.gz

USER vscode