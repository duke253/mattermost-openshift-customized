# creating new project
oc new-project mattermost

# creating new secret for DB
oc create secret generic mattermost-database --from-literal=user=username --from-literal=password=secret

# creatin service account
oc create serviceaccount mattermost

# 
oc secrets link mattermost mattermost-database

# 
oc adm policy add-scc-to-user anyuid system:serviceaccount:mattermost:mattermost

#creating template
oc create --filename mattermost.yaml

# deploing new app from template
oc new-app --template=mattermost --labels=app=mattermostmattermost-openshift-customized
