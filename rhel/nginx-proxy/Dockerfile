FROM nginx:1.18

# deploy specific nginx configuration file
COPY mm-proxy.conf /etc/nginx/conf.d/mm-proxy.conf

# support running as arbitrary user which belogs to the root group
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx  && chmod -R g+w /etc/nginx

RUN rm /etc/nginx/conf.d/default.conf
RUN ln -s /etc/nginx/conf.d/mattermost /etc/nginx/conf.d/default.conf

# output port
EXPOSE 8080

USER 2000