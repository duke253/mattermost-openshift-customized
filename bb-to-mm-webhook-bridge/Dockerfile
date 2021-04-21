FROM python:3

RUN mkdir -p /opt/webhook-bridge /opt/webhook-bridge/config

COPY bitbucket.py /opt/webhook-bridge
ADD helpers.py /opt/webhook-bridge
ADD config.json /opt/webhook-bridge/config

RUN chgrp -R 0 /opt/webhook-bridge && \
    chmod -R g=u /opt/webhook-bridge &&

RUN pip install flask
RUN pip install requests

WORKDIR /opt/webhook-bridge

CMD [ "python", "/opt/webhook-bridge/bitbucket.py" ]
