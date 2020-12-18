oc new-project mattermost

oc create secret generic mattermost-database --from-literal=user=username --from-literal=password=secret

oc create serviceaccount mattermost

oc secrets link mattermost mattermost-database

oc adm policy add-scc-to-user anyuid system:serviceaccount:mattermost:mattermost

oc create --filename mattermost.yaml

oc new-app --template=mattermost --labels=app=mattermostmattermost-openshift-customized
