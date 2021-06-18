FROM nginx:1.18

# remove default configuration files
RUN rm /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/nginx.conf

# deploy specific nginx configuration file
COPY whb-proxy.conf /etc/nginx/conf.d/mm-proxy.conf
COPY nginx.conf /etc/nginx/nginx.conf

# copy certificates
RUN mkdir /etc/nginx/cert
COPY mm-cert.pem /etc/nginx/cert/mm-cert.pem
COPY mm-cert-key.pem /etc/nginx/cert/mm-cert-key.pem

# support running as arbitrary user which belogs to the root group
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx  && chmod -R g+w /etc/nginx

# output port
EXPOSE 8080
EXPOSE 8443

# swith user
USER 2000

# start nginx
CMD ["/bin/sh", "-c", "exec nginx -g 'daemon off;';"]