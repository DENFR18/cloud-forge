#!/bin/bash
# ============================================================
# bootstrap.sh — A executer UNE SEULE FOIS avant terraform init
# Cree le bucket S3 et la table DynamoDB pour le state Terraform
# ============================================================

set -e

REGION="eu-west-3"
BUCKET="cloud-forge-tfstate"
TABLE="cloud-forge-tflock"

echo "================================================"
echo "  Cloud Forge — Bootstrap Terraform Backend"
echo "================================================"

# Bucket S3
echo "[1/3] Creation du bucket S3 : $BUCKET"
aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

echo "[2/3] Creation de la table DynamoDB : $TABLE"
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"

echo "[3/3] Ajout des secrets GitHub (necessite gh CLI)"
echo ""
echo "  Lance les commandes suivantes pour configurer les secrets :"
echo ""
echo "  gh secret set AWS_ACCESS_KEY_ID     --body '<ta-cle>'"
echo "  gh secret set AWS_SECRET_ACCESS_KEY --body '<ton-secret>'"
echo ""
echo "  Puis cree l'environment 'production' dans GitHub :"
echo "  Settings → Environments → New environment → production"
echo "  Active 'Required reviewers' et ajoute-toi."
echo ""
echo "================================================"
echo "  Bootstrap termine. Tu peux lancer le workflow."
echo "================================================"
