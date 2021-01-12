#!/bin/sh

# Function to generate a random salt
generate_salt() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 48 | head -n 1
}

# Read environment variables or set default values
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
S3_BUCKET_DATA=${S3_BUCKET_DATA:-none}
S3_URL_DATA=${S3_URL_DATA:-none}

# Create passwd file for S3
echo "${S3_KEY}:${S3_SECRET}" > /opt/mattermost/.passwd-s3fs
chown mattermost:mattermost /opt/mattermost/.passwd-s3fs
chmod 600 /opt/mattermost/.passwd-s3fs

# Mount S3
s3fs "${S3_BUCKET_DATA}" /opt/mattermost/data -o passwd_file=/opt/mattermost/.passwd-s3fs -o url="${S3_URL_DATA}" -o use_path_request_style

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
	jq '.GitLabSettings.AuthEndpoint = "https://secure-keycloak-mattermost.apps.cluster1.piewitheye.com/auth/realms/mattermost/protocol/openid-connect/auth"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.GitLabSettings.TokenEndpoint = "https://secure-keycloak-mattermost.apps.cluster1.piewitheye.com/auth/realms/mattermost/protocol/openid-connect/token"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.GitLabSettings.UserApiEndpoint = "https://secure-keycloak-mattermost.apps.cluster1.piewitheye.com/auth/realms/mattermost/protocol/openid-connect/userinfo"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	jq '.ServiceSettings.EnableInsecureOutgoingConnections = "true"' "$MM_CONFIG" > "$MM_CONFIG.tmp" && mv "$MM_CONFIG.tmp" "$MM_CONFIG"
	
	echo "done"
else
	echo -ne "Using existing config: "$MM_CONFIG
fi

echo -ne "Switching to user mattermost..."
# Switch to user mattermost
exec su - mattermost -c "$*"
echo "done"

echo -ne "Starting mattermost server..."
# Start mattermost server
exec /opt/mattermost/bin/platform -c $MM_CONFIG
echo "done"