#!/bin/bash
set -e

REGION="${region}"
PROJECT="${project}"

# Attend que le master ecrive le token dans SSM
MAX_RETRY=40
RETRY=0
TOKEN=""

while [ -z "$TOKEN" ] && [ $RETRY -lt $MAX_RETRY ]; do
  TOKEN=$(aws ssm get-parameter \
    --name "/$PROJECT/k3s-token" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text \
    --region $REGION 2>/dev/null || echo "")

  if [ -z "$TOKEN" ]; then
    echo "Waiting for master token in SSM... ($RETRY/$MAX_RETRY)"
    sleep 30
    RETRY=$((RETRY + 1))
  fi
done

if [ -z "$TOKEN" ]; then
  echo "ERROR: Could not get k3s token from SSM after $MAX_RETRY retries"
  exit 1
fi

MASTER_IP=$(aws ssm get-parameter \
  --name "/$PROJECT/k3s-master-ip" \
  --query "Parameter.Value" \
  --output text \
  --region $REGION)

# Rejoint le cluster
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN sh -

echo "Worker joined the k3s cluster at $MASTER_IP"
