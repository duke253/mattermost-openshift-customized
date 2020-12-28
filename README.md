# Start

## create new project
oc new-project mattermost

## create service account
oc create serviceaccount mattermost

## put the mattermost service account in anyuid scc and adjust the uid range for the namespace to run with
oc adm policy add-scc-to-user anyuid system:serviceaccount:mattermost:mattermost
oc annotate namespace mattermost openshift.io/sa.scc.uid-range=2000/2000 --overwrite

# Keycloak

## create secret for Keyclaok Admin
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


# Mattermost

## create new secret for DB
oc create secret generic mattermost-database \
--from-literal=user=%username% \
--from-literal=password=%password%

## create new secret for Gitlab (AD)
oc create secret generic mattermost-gitlab \
--from-literal=user=%Client_ID% \
--from-literal=password=%Client_Secret%

## link secret to service account
oc secrets link mattermost mattermost-database
oc secrets link mattermost mattermost-gitlab

## create template
oc create --filename mattermost.yaml

## deploy new app from template
oc new-app --template=mattermost --labels=app=mattermost
