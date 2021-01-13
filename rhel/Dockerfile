FROM ubi7/ubi:latest

ENV MATTERMOST_VERSION 5.29.0
ENV MATTERMOST_VERSION_SHORT 5290
# ENV S3_BUCKET_DATA mm-data
# ENV S3_URL_DATA http://84.201.166.183:9000
ARG PUID=2000
ARG PGID=2000

# Labels could be consumed by OpenShift
LABEL io.k8s.description="Mattermost is an open source, self-hosted Slack-alternative" \
      io.k8s.display-name="Mattermost {$MATTERMOST_VERSION}" \
      io.openshift.expose-services="8065:mattermost" \
      io.openshift.tags="mattermost,slack"

# Install fuse & s3fs packages
RUN yum -y install automake gcc-c++ git libcurl-devel libxml2-devel make openssl-devel wget &&\
	yum clean all -y &&\
	cd /usr/local/src &&\
	wget https://github.com/libfuse/libfuse/releases/download/fuse-2.9.7/fuse-2.9.7.tar.gz &&\
	tar -xzvf fuse-2.9.7.tar.gz &&\
	rm -f fuse-2.9.7.tar.gz &&\
	mv fuse-2.9.7 fuse &&\
	cd fuse/ &&\
	./configure --prefix=/usr &&\
	make &&\
	make install &&\
	export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig/ &&\
	ldconfig &&\
	cd /usr/local/src &&\
	git clone https://github.com/s3fs-fuse/s3fs-fuse.git &&\
	cd s3fs-fuse &&\
	./autogen.sh &&\
	./configure &&\
	make &&\
	make install

# Install some needed packages for MM
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &&\
	yum -y install jq &&\
	yum -y install kernel-headers &&\
	yum -y install mailcap &&\
	yum -y install nmap-ncat &&\
	yum -y install xmlsec1 &&\
	yum clean all -y

RUN cd /opt && \
    curl -LO -v https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    tar xf mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz &&\
    rm mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz

COPY fstab /etc/fstab

COPY config.json /opt/mattermost/config/config.json

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
