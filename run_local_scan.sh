#!/usr/bin/env bash
set -e

echo "Starting local relay scan..."
cd utils/tor-relay-scanner/
bash start.sh

echo "Updating templates..."
cd ../../
bash update_templates.sh

echo "Restarting multitor2 to apply fresh relays..."
docker restart multitor2

echo "Done!"
