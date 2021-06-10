OpenShift application template for Mattermost Team Edition.
Implements active-passive scheme for HA via two separate instances of Mattermost server and Nginx reverse proxy in front of them.
Integrated with Microsoft Active Directory via Keycloak.
Uses Minio (S3) as a file storage and Postgres as external databases for Mattermost and Keycloak.
Integration with Bitbucket is possible through the WebHook Bridge server.

### Step 0
Adjust parameters in *.yaml regarding your environment (e.g. DB host, DB port, DB name etc...). See parameters and configmap.

### Step 1
create new project
```
oc new-project mattermost
```

### Step 2 - Keycloak
create secret for Keycloak Admin account
```
oc create secret generic keycloak-secret \
--from-literal=user=%username% \
--from-literal=password=%password%
```
create secret for connecting to Keyclaok DB
```
oc create secret generic keycloak-database \
--from-literal=user=%username% \
--from-literal=password=%password%
```
create secret with SSL certificate and private key for keycloak web interface

**Note:** Place your certificate bundle and private key in ./kc-certs/ with names "tls.crt" and "tls.key".
In order to create certificate bundle run command like:

```
cat server.crt signing-ca.crt > tls.crt
```

```
cd ./keycloak
oc create secret generic keycloak-certs --from-file=./kc-certs
```
create template for Keycloak instance
```
oc create --filename keycloak-https.yaml
```
deploy Keycloak instance from template
```
oc new-app --template=keycloak-https -p NAMESPACE=mattermost
```

**Note:** see https://medium.com/@mrtcve/mattermost-teams-edition-replacing-gitlab-sso-with-keycloak-dabf13ebb99e for details about Keycloak configuration process.

### Step 3 - Mattermost
create secret for connecting to Mattermost DB
```
oc create secret generic mattermost-database \
--from-literal=user=%username% \
--from-literal=password=%password%
```
create secret for connecting to Gitlab (AD)
```
oc create secret generic mattermost-gitlab \
--from-literal=user=%Client_ID% \
--from-literal=password=%Client_Secret%
```
create secret for connecting to S3 (Minio) file storage
```
oc create secret generic mattermost-s3 \
--from-literal=user=%Access_Key_ID% \
--from-literal=password=%Secret_Access_Key%
```
create secret with SSL certificate for S3

**Note:** Place your root CA certificate for S3 in ./s3-cert.
```
cd ..
cd ./mattermost
oc create secret generic s3-certs --from-file=./s3-cert
```

create template for first Mattermost instance
```
oc create --filename mattermost-1.yaml
```

create template for second Mattermost instance
```
oc create --filename mattermost-2.yaml
```

deploy first Mattermost instance from template
```
oc new-app --template=mattermost-1 --labels=app=mattermost-1
```

deploy second Mattermost instance from template
```
oc new-app --template=mattermost-2 --labels=app=mattermost-2
```

### Step 4 - Nginx reverse proxy
create secret with SSL certificates and private key for Nginx

**Note:** Place your certificate bundle and private key in ./nginx-proxy/mm-cert with names "certificate_chained.crt" and "private.key"
In order to create certificate bundle run command like:

```
cat server.crt signing-ca.crt > certificate_chained.crt
```

```
cd ..
cd ./nginx-proxy
oc create secret generic nginx-certs --from-file=./mm-cert
```

create secret with CLIENT SSL certificates and private key for Nginx

**Note:** Place your server certificate, root CA certificate and private key in ./nginx-client-cert with names "client.pem", "trusted_ca_cert.crt" and "client.key"

```
oc create secret generic nginx-client-certs --from-file=./nginx-client-cert
```

create secret with configuration file for Nginx

**Note:** This configuration file based on official configuration example from https://docs.mattermost.com/install/config-proxy-nginx.html.
```
oc create secret generic nginx-config --from-file=./mm-proxy.conf
```

create template for Nginx reverse proxy
```
oc create --filename mm-nginx-proxy.yaml
```

deploy Nginx reverse proxy from template
```
oc new-app --template=nginx --labels=app=nginx
```

### Step 5 - WebHook Bridge server
create secret with configuration file for WebHook Bridge Server

**Note:** configuration manual is here - https://github.com/cvitter/mattermost-bitbucket-bridge
```
cd ..
cd ./bb-to-mm-webhook-bridge
oc create secret generic webhook-bridge-config --from-file=./config.json
```

create template for WebHook Bridge server
```
oc create --filename webhook-bridge.yaml
```

deploy WebHook Bridge server from template
```
oc new-app --template=webhook-bridge --labels=app=webhook-bridge
```

### Filebeat
Every pod in this deployment use filebeat container in order to send logs to logstash.
In order to use it you should point filebeat to your logstash address:
- edit the ./filebeat/filebeat.yml with your logstash address i.e. "hosts: ["your_logstash_address:your_logstash_port"]"
- build your own filebeat image using files in ./filebeat/filebeat.yml
- push it in any available image registry and edit other yaml-files in order to use your own filebeat image i.e. "image: quay.io/your_registry/your_filebeat_image:1.0"

### Useful links:
1. https://medium.com/@mrtcve/mattermost-teams-edition-replacing-gitlab-sso-with-keycloak-dabf13ebb99e
2. https://github.com/keycloak/keycloak-containers/tree/master/openshift-examples
3. https://github.com/tschwaerzl/mattermost-openshift
4. https://github.com/goern/mattermost-openshift
5. https://github.com/mattermost/mattermost-docker
6. https://docs.mattermost.com/install/config-proxy-nginx.html
7. https://developers.mattermost.com/contribute/mobile/
8. https://github.com/cvitter/mattermost-bitbucket-bridge
9. https://github.com/icelander/mattermost-teamcity-plugin

**Optional:** you can setup Nginx reverse proxy in front of OpenShift as a separate virtual machine. Pls, see example for Centos 7 in ./nginx-front-proxy-setup.txt

**Optional:** you can setup your own push-proxy server (MPNS) as a separate virtual machine. Pls, see example for Centos 7 in ./MPNS.txt.

**Note:** MPNS required bilding your own mobile apps, pls see - https://developers.mattermost.com/contribute/mobile/