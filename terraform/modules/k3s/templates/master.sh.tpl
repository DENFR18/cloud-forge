#!/bin/bash
set -e

REGION="${region}"
PROJECT="${project}"
MASTER_PUBLIC_IP="${master_eip}"

# Installe k3s server avec TLS SAN pour l'IP publique
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --tls-san $MASTER_PUBLIC_IP --node-external-ip $MASTER_PUBLIC_IP" sh -

# Attend que k3s soit pret
until kubectl get nodes 2>/dev/null; do
  echo "Waiting for k3s to be ready..."
  sleep 5
done

# Recupere le token
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)

# Stocke dans SSM
aws ssm put-parameter --name "/$PROJECT/k3s-token" --value "$TOKEN" --type SecureString --overwrite --region $REGION
aws ssm put-parameter --name "/$PROJECT/k3s-master-ip" --value "$MASTER_PUBLIC_IP" --type String --overwrite --region $REGION

# Stocke le kubeconfig avec l'IP publique
KUBECONFIG_CONTENT=$(cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/$MASTER_PUBLIC_IP/g")
aws ssm put-parameter --name "/$PROJECT/k3s-kubeconfig" --value "$KUBECONFIG_CONTENT" --type SecureString --overwrite --region $REGION

echo "k3s master ready — token and kubeconfig stored in SSM"
