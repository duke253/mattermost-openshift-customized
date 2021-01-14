OpenShift application template for Mattermost Team Edition.
Integrated with Microsoft Active Directory via Keycloak.
Uses Minio (S3) as a file storage and Postgres as external databases for Mattermost and Keycloak.

Note^ Latest files in ./rhel

# Step 0

Adjust parameters in mattermost.yaml and keycloak-https.yaml regarding your environment (e.g. DB host, DB port, DB name etc...). See parameters and configmap.

# Step 1

## create new project
oc new-project mattermost

## create service account
oc create serviceaccount mattermost

## put the mattermost service account in anyuid scc and adjust the uid range for the namespace to run with
oc adm policy add-scc-to-user anyuid system:serviceaccount:mattermost:mattermost
oc annotate namespace mattermost openshift.io/sa.scc.uid-range=2000/2000 --overwrite

# Step 2 - Keycloak

## create secret for Keycloak Admin
oc create secret generic keycloak-secret \
--from-literal=user=%username% \
--from-literal=password=%password%

## create secret for Keyclaok DB
oc create secret generic keycloak-database \
--from-literal=user=%username% \
--from-literal=password=%password%

## create template
oc create --filename keycloak-https.yaml

## deploy new app from template
oc new-app --template=keycloak-https -p NAMESPACE=mattermost

# Note: see https://medium.com/@mrtcve/mattermost-teams-edition-replacing-gitlab-sso-with-keycloak-dabf13ebb99e for details about Keycloak configuration process

# Step 3 - Mattermost

## create new secret for DB
oc create secret generic mattermost-database \
--from-literal=user=%username% \
--from-literal=password=%password%

## create new secret for Gitlab (AD)
oc create secret generic mattermost-gitlab \
--from-literal=user=%Client_ID% \
--from-literal=password=%Client_Secret%

## create new secret for Minio (S3)
oc create secret generic mattermost-s3 \
--from-literal=user=%Access_Key_ID% \
--from-literal=password=%Secret_Access_Key%

## link secret to service account
oc secrets link mattermost mattermost-database
oc secrets link mattermost mattermost-gitlab
oc secrets link mattermost mattermost-s3

## create template
oc create --filename mattermost.yaml

## deploy new app from template
oc new-app --template=mattermost --labels=app=mattermost

# Useful links:
1. https://medium.com/@mrtcve/mattermost-teams-edition-replacing-gitlab-sso-with-keycloak-dabf13ebb99e
2. https://github.com/keycloak/keycloak-containers/tree/master/openshift-examples
3. https://github.com/tschwaerzl/mattermost-openshift
4. https://github.com/goern/mattermost-openshift
5. https://github.com/mattermost/mattermost-docker
