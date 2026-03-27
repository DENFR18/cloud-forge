#!/bin/bash

REGION="${region}"
PROJECT="${project}"
MASTER_PUBLIC_IP="${master_ip}"

exec > /var/log/k3s-setup.log 2>&1

echo "=== k3s setup started at $(date) ==="
echo "EIP: $MASTER_PUBLIC_IP"

# Attend que le reseau soit disponible
sleep 15

# Installe k3s
echo "=== Installing k3s ==="
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --tls-san $MASTER_PUBLIC_IP --node-external-ip $MASTER_PUBLIC_IP" sh -

if [ $? -ne 0 ]; then
  echo "ERROR: k3s install failed"
  exit 1
fi

echo "=== k3s installed, waiting for node to be ready ==="
for i in $(seq 1 30); do
  if kubectl get nodes 2>/dev/null | grep -q "Ready"; then
    echo "k3s node is Ready"
    break
  fi
  echo "Waiting for k3s node... ($i/30)"
  sleep 10
done

TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
KUBECONFIG_CONTENT=$(cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/$MASTER_PUBLIC_IP/g")

echo "=== Writing to SSM ==="

for i in 1 2 3; do
  aws ssm put-parameter \
    --name "/$PROJECT/k3s-token" \
    --value "$TOKEN" \
    --type SecureString \
    --overwrite \
    --region $REGION && break
  echo "SSM retry $i..."
  sleep 10
done

for i in 1 2 3; do
  aws ssm put-parameter \
    --name "/$PROJECT/k3s-master-ip" \
    --value "$MASTER_PUBLIC_IP" \
    --type String \
    --overwrite \
    --region $REGION && break
  echo "SSM retry $i..."
  sleep 10
done

for i in 1 2 3; do
  aws ssm put-parameter \
    --name "/$PROJECT/k3s-kubeconfig" \
    --value "$KUBECONFIG_CONTENT" \
    --type SecureString \
    --overwrite \
    --region $REGION && break
  echo "SSM retry $i..."
  sleep 10
done

echo "=== k3s master ready at $(date) ==="
