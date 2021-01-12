#!/bin/sh

# Switch to user mattermost
exec sudo -iu mattermost

# Start mattermost server
exec /opt/mattermost/bin/platform -c $MM_CONFIG