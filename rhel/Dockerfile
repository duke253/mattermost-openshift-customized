FROM ubi7/ubi:latest

ENV MATTERMOST_VERSION 5.29.0
ENV MATTERMOST_VERSION_SHORT 5290
ENV S3_KEY none
ENV S3_SECRET none
ENV S3_BUCKET_DATA none
ENV S3_URL_DATA none
ARG PUID=2000
ARG PGID=2000

# Labels consumed by Red Hat build service
LABEL Component="mattermost" \
      name="alpine/mattermost-${MATTERMOST_VERSION_SHORT}-ubi7" \
      vendor=Community \
      Version="${MATTERMOST_VERSION}" \
      Release="1"

# Labels could be consumed by OpenShift
LABEL io.k8s.description="Mattermost is an open source, self-hosted Slack-alternative" \
      io.k8s.display-name="Mattermost {$MATTERMOST_VERSION}" \
      io.openshift.expose-services="8065:mattermost" \
      io.openshift.tags="mattermost,slack"

# Install some needed packages
RUN yum -y install yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &&\
	yum -y install jq &&\
	yum -y install kernel-headers &&\
	yum -y install mailcap &&\
	yum -y install nmap-ncat &&\
	yum -y install xmlsec1 &&\
	yum -y install s3fs-fuse &&\
	yum clean all -y

RUN cd /opt && \
    curl -LO -v https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    tar xf mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz &&\
    rm mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz

COPY config.json /opt/mattermost/config/config.json

COPY mattermost-launch.sh /opt/mattermost/bin/mattermost-launch.sh
RUN chmod +x /opt/mattermost/bin/mattermost-launch.sh
ENTRYPOINT [ "/opt/mattermost/bin/mattermost-launch.sh" ]

RUN mkdir -p /opt/mattermost/data /opt/mattermost/plugins /opt/mattermost/client/plugins

RUN groupadd -g ${PGID} mattermost \
    && useradd -u ${PUID} -g mattermost -b /opt mattermost \
	&& chown -R mattermost:mattermost /opt/mattermost \
	&& setcap cap_net_bind_service=+ep /opt/mattermost/bin/mattermost

USER 2000

EXPOSE 8065

WORKDIR /opt/mattermost

CMD [ "/opt/mattermost/bin/mattermost-launch.sh" ]
