# create new project
oc new-project mattermost

# create new secret for DB
oc create secret generic mattermost-database --from-literal=user=%db_user% --from-literal=password=%db_password%

# create service account
oc create serviceaccount mattermost

# link secret to service account
oc secrets link mattermost mattermost-database

# put the mattermost service account in anyuid scc and adjust the uid range for the namespace to run with
oc adm policy add-scc-to-user anyuid system:serviceaccount:mattermost:mattermost
oc annotate namespace mattermost openshift.io/sa.scc.uid-range=2000/2000 --overwrite

#create template
oc create --filename mattermost.yaml

# deploy new app from template
oc new-app --template=mattermost --labels=app=mattermost
