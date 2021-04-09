#!/bin/sh

# Function to generate a random salt
echo -ne "Create function to generate a random salt..."
generate_salt() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 48 | head -n 1
}
echo "done"

# Read environment variables or set default values
echo -ne "Read environment variables..."
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
DB_USERNAME=${DB_USERNAME:-mm_user}
DB_PASSWORD=${DB_PASSWORD:-mm_pass}
DB_DATABASE=${DB_DATABASE:-mm_db}
MM_GITLAB_SECRET=${MM_GITLAB_SECRET:-mm_gitlab_secret}
MM_GITLAB_ID=${MM_GITLAB_ID:-mm_gitlab_id}
MM_CONFIG=${MM_CONFIG:-/opt/mattermost/config.json}
S3_KEY=${S3_KEY:-none}
S3_SECRET=${S3_SECRET:-none}
S3_BUCKET=${S3_BUCKET:-none}
S3_URL=${S3_URL:-none}
GITLAB_AUTHENDPOINT=${GITLAB_AUTHENDPOINT:-none}
GITLAB_TOKENENDPOINT=${GITLAB_TOKENENDPOINT:-none}
GITLAB_USERAPIENAPOINT=${GITLAB_USERAPIENAPOINT:-none}
MPNS_URL=${MPNS_URL:-none}
PUSH_CONTENT_MODE=${PUSH_CONTENT_MODE:-none}
TEAMCITY_AUTH_TOKEN={$TEAMCITY_AUTH_TOKEN}
TEAMCITY_URL={$TEAMCITY_URL}

echo $DB_HOST
echo $DB_PORT
echo $DB_DATABASE
echo $DB_USERNAME
echo $DB_PASSWORD
echo $MM_GITLAB_ID
echo $MM_GITLAB_SECRET
echo $MM_CONFIG
echo $S3_KEY
echo $S3_SECRET
echo $S3_BUCKET
echo $S3_URL
echo $GITLAB_AUTHENDPOINT
echo $GITLAB_TOKENENDPOINT
echo $GITLAB_USERAPIENAPOINT
echo $MPNS_URL
echo $PUSH_CONTENT_MODE
echo $TEAMCITY_AUTH_TOKEN
echo $TEAMCITY_URL

if [ ! -f $MM_CONFIG ]; then
	echo -ne "Configure new config.json..."
	cp /opt/mattermost/config/config.json $MM_CONFIG
	jq '.SqlSettings.DataSource = "postgres://'$DB_USERNAME':'$DB_PASSWORD'@'$DB_HOST':'$DB_PORT'/'$DB_DATABASE'?sslmode=disable&connect_timeout=10"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.SqlSettings.AtRestEncryptKey = "'$(generate_salt)'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.PublicLinkSalt = "'$(generate_salt)'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.EmailSettings.InviteSalt = "'$(generate_salt)'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
    jq '.EmailSettings.PasswordResetSalt = "'$(generate_salt)'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.GitLabSettings.Enable = "true"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.GitLabSettings.Secret = "'$MM_GITLAB_SECRET'"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.GitLabSettings.Id = "'$MM_GITLAB_ID'"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.GitLabSettings.AuthEndpoint = "'$GITLAB_AUTHENDPOINT'"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.GitLabSettings.TokenEndpoint = "'$GITLAB_TOKENENDPOINT'"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.GitLabSettings.UserApiEndpoint = "'$GITLAB_USERAPIENAPOINT'"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.ServiceSettings.EnableInsecureOutgoingConnections = "true"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.FileSettings.DriverName = "amazons3"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3AccessKeyId = "'$S3_KEY'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3SecretAccessKey = "'$S3_SECRET'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3Bucket = "'$S3_BUCKET'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3PathPrefix = ""' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3Region = ""' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3Endpoint = "'$S3_URL'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3SSL = "true"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3SignV2 = "false"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3SSE = "false"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.FileSettings.AmazonS3Trace = "false"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.EmailSettings.EnableSignUpWithEmail = "false"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.EmailSettings.EnableSignInWithEmail = "false"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.EmailSettings.EnableSignInWithUsername = "false"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.EmailSettings.SendPushNotifications = "true"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.EmailSettings.PushNotificationServer = "'$MPNS_URL'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.EmailSettings.PushNotificationContents = "'$PUSH_CONTENT_MODE'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.TeamSettings.TeammateNameDisplay = "full_name"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.PluginSettings.EnableUploads = "false"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.PluginSettings.PluginStates += {"mattermost-teamcity-plugin": {"Enable": "true"}}' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.PluginSettings.Plugins += {"mattermost-teamcity-plugin": {"teamcitymaxbuilds": "5", "teamcitytoken": "", "teamcityurl": ""}}' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.PluginSettings.Plugins.mattermost-teamcity-plugin.teamcitytoken = "'$TEAMCITY_AUTH_TOKEN'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG
	jq '.PluginSettings.Plugins.mattermost-teamcity-plugin.teamcityurl = "'$TEAMCITY_URL'"' $MM_CONFIG > $MM_CONFIG.tmp && mv $MM_CONFIG.tmp $MM_CONFIG

	echo "done"
else
	echo -ne "Using existing config: "$MM_CONFIG
fi

# Start mattermost server
echo -ne "Start mattermost server..."
exec /opt/mattermost/bin/mattermost -c $MM_CONFIG