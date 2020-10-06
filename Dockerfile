FROM alpine


ENV KUBE_CTL_VERSION="v1.18.6"
ENV LC_ALL=en_US.UTF-8

# install base  tools
RUN apk update \
    && apk -Uuv add make gcc groff less musl-dev libffi-dev openssl-dev python2-dev py-pip \
    && apk add ca-certificates bash git yarn curl python3

RUN  apk add alpine-sdk python3-dev postgresql-dev

# install npm
RUN apk add npm

#install docker & docker-compose
RUN apk add docker docker-compose

#install kubectl 
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_CTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

#install kubeval
RUN wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
RUN tar xf kubeval-linux-amd64.tar.gz
RUN cp kubeval /usr/local/bin

# install aws cli v2
ENV GLIBC_VER=2.31-r0
RUN curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/* \
    && aws --version

# install sops
RUN ([ -f /usr/bin/sops ] || (wget -q -O /usr/bin/sops https://github.com/mozilla/sops/releases/download/v3.5.0/sops-v3.5.0.linux && chmod +x /usr/bin/sops))

# install lerna
RUN yarn global add lerna

RUN npm install -g @commitlint/cli @commitlint/config-conventional

# shell functions
RUN git clone https://github.com/sharkdp/shell-functools /tmp/shell-functools

# change default bash
RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

RUN apk add jq

RUN apk --purge -v del py-pip \
    && rm -rf /var/cache/*/* \
    && echo "" > /root/.ash_history

CMD [ "/bin/bash"]