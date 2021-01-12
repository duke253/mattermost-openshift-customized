#!/bin/sh

echo -ne "Starting launch script..."
MM_CONFIG=${MM_CONFIG:-/opt/mattermost/config.json}
echo "done"

echo -ne "Switching to user mattermost..."
# Switch to user mattermost
exec sudo -iu mattermost
echo "done"

echo -ne "Starting mattermost server..."
# Start mattermost server
exec /opt/mattermost/bin/platform -c $MM_CONFIG
echo "done"