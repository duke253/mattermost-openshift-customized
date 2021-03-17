FROM ubi7/ubi:7.9

ENV MATTERMOST_VERSION 5.29.0
ENV MATTERMOST_VERSION_SHORT 5290
ARG PUID=2000
ARG PGID=2000

# Labels could be consumed by OpenShift
LABEL io.k8s.description="Mattermost is an open source, self-hosted Slack-alternative" \
      io.k8s.display-name="Mattermost {$MATTERMOST_VERSION}" \
      io.openshift.expose-services="8065:mattermost" \
      io.openshift.tags="mattermost,slack"

# Install some needed packages for MM
RUN cd /opt &&\
	yum -y install wget &&\
	wget https://dl.fedoraproject.org/pub/epel/7Server/x86_64/Packages/o/oniguruma-6.8.2-1.el7.x86_64.rpm &&\
	wget https://dl.fedoraproject.org/pub/epel/7Server/x86_64/Packages/j/jq-1.6-2.el7.x86_64.rpm &&\
	rpm -ihv oniguruma-6.8.2-1.el7.x86_64.rpm &&\
	rpm -ihv jq-1.6-2.el7.x86_64.rpm &&\
	yum -y install kernel-headers &&\
	yum -y install mailcap &&\
	yum -y install nmap-ncat &&\
	yum -y install xmlsec1 &&\
	yum clean all -y &&\
	rm -rf /opt/*

RUN cd /opt && \
    curl -LO -v https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    tar xf mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz &&\
    rm mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz

# S3 certificate
COPY public.crt /etc/pki/ca-trust/source/anchors
RUN update-ca-trust
RUN update-ca-trust enabled
RUN update-ca-trust extract

COPY config.json /opt/mattermost/config/config.json

# customized web app
RUN rm -rf /opt/mattermost/client/*
COPY dist.tar /opt/mattermost/client
RUN tar -xvf /opt/mattermost/client/dist.tar -C /opt/mattermost/client
RUN rm -rf /opt/mattermost/client/dist.tar

COPY entrypoint.sh /opt/mattermost/bin/entrypoint.sh

RUN chmod +x /opt/mattermost/bin/entrypoint.sh

RUN mkdir -p /opt/mattermost/data /opt/mattermost/plugins /opt/mattermost/client/plugins

RUN groupadd -g ${PGID} mattermost \
    && useradd -u ${PUID} -g mattermost -b /opt mattermost \
	&& chown -R mattermost:mattermost /opt/mattermost \
	&& setcap cap_net_bind_service=+ep /opt/mattermost/bin/mattermost

EXPOSE 8065

WORKDIR /opt/mattermost

USER 2000

ENTRYPOINT [ "/opt/mattermost/bin/entrypoint.sh" ]