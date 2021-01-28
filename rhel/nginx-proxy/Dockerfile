FROM ubi8/nginx-116

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD cfg /tmp/src/
COPY mm-cert.pem /etc/nginx/cert/mm-cert.pem
COPY mm-cert-key.pem /etc/nginx/cert/mm-cert-key.pem
RUN chown -R 1001:0 /tmp/src
USER 1001

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run