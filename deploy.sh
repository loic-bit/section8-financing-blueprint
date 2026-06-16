#!/usr/bin/env bash
# Deploy section8-financing-blueprint to Railway
# Usage: ./deploy.sh "optional commit message"

set -e

ENV_FILE="$(cd "$(dirname "$0")/../../.." && pwd)/CTRL/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: CTRL/.env not found"
  exit 1
fi
GITHUB_TOKEN=$(grep '^GITHUB_TOKEN=' "$ENV_FILE" | cut -d '=' -f2-)
RAILWAY_TOKEN=$(grep '^RAILWAY_TOKEN=' "$ENV_FILE" | cut -d '=' -f2-)

COMMIT_MSG="${1:-update financing blueprint}"

git add index.html
git diff --cached --quiet && echo "Nothing to commit." && exit 0
git commit -m "$COMMIT_MSG"
git push "https://${GITHUB_TOKEN}@github.com/loic-bit/section8-financing-blueprint.git" main

# IDs filled in after initial deploy
SVC_ID="cd1a8c9b-1880-41a8-bdc8-3abbd5437ab9"
ENV_ID="57c93bc4-7ce9-4df2-831f-456bc1e0e6b6"

curl -s -X POST https://backboard.railway.app/graphql/v2 \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"query\":\"mutation{serviceInstanceDeploy(serviceId:\\\"$SVC_ID\\\",environmentId:\\\"$ENV_ID\\\")}\"}" > /dev/null

echo ""
echo "Deployed. Live at: https://investingsection8-financing-production.up.railway.app/"
echo "(Usually live within 60 seconds.)"
