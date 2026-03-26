# ⚡ Cloud Forge

Plateforme DevOps multi-stack déployée sur **AWS EKS** via **Terraform** et **GitHub Actions**.
Infrastructure 100% as Code avec monitoring Prometheus + Grafana intégré.

---

## Architecture

```
cloud-forge/
├── .github/workflows/       # GitHub Actions (infra, apps, monitoring)
├── terraform/
│   └── modules/
│       ├── vpc/             # VPC, subnets public/privé, NAT Gateway
│       ├── eks/             # Cluster EKS + node group + IAM
│       └── ecr/             # Repositories ECR (node-api, flask-api, react)
├── k8s/                     # Manifestes Kubernetes par stack
├── apps/
│   ├── node-api/            # API Express.js (Node 20)
│   ├── flask-api/           # API Flask + Gunicorn (Python 3.12)
│   └── react/               # Frontend React + Vite (servi via Nginx)
├── monitoring/
│   ├── prometheus/          # Helm values Prometheus
│   └── grafana/             # Helm values Grafana + dashboards
└── portal/                  # Dashboard HTML de la plateforme
```

---

## Stack technique

| Composant | Technologie |
|---|---|
| Cloud | AWS (eu-west-3) |
| Kubernetes | Amazon EKS 1.31 |
| IaC | Terraform 1.7 |
| CI/CD | GitHub Actions |
| Registry | Amazon ECR |
| Ingress | NGINX Ingress Controller |
| Monitoring | Prometheus + Grafana (Helm) |
| State Terraform | S3 + DynamoDB |

---

## Stacks déployées

| Stack | Namespace | Image |
|---|---|---|
| WordPress + MySQL | `stack-wordpress` | Docker Hub |
| Ghost | `stack-ghost` | Docker Hub |
| Gitea | `stack-gitea` | Docker Hub |
| Node API | `stack-node-api` | ECR |
| Flask API | `stack-flask-api` | ECR |
| React App | `stack-react` | ECR |

---

## Démarrage

### 1. Prérequis

- AWS CLI configuré (`aws configure`)
- Compte GitHub avec accès au repo
- Secrets GitHub configurés :
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- Environment GitHub `production` créé avec reviewer obligatoire

### 2. Bootstrap (une seule fois)

Crée le bucket S3 et la table DynamoDB pour le state Terraform :

```powershell
aws s3api create-bucket --bucket cloud-forge-tfstate --region eu-west-3 --create-bucket-configuration LocationConstraint=eu-west-3

aws dynamodb create-table --table-name cloud-forge-tflock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region eu-west-3
```

### 3. Déploiement

Lancer les workflows dans cet ordre :

```
1. Actions → Infrastructure      → Run workflow → deploy
2. Actions → Deploy Apps         → Run workflow
3. Actions → Deploy Monitoring   → Run workflow
```

### 4. Destruction

```
Actions → Infrastructure → Run workflow → destroy
```

Une confirmation manuelle est requise via GitHub Environments avant la destruction.

---

## Workflows GitHub Actions

### `Infrastructure` — `infra.yml`

Déclenchement manuel avec choix de l'action :

- **deploy** — Crée toute l'infra AWS (VPC, EKS, ECR, NAT Gateway)
- **destroy** — Détruit toute l'infra AWS. Nécessite une approbation manuelle via l'environment `production`

### `Deploy Apps` — `deploy-apps.yml`

- Build les images Docker (node-api, flask-api, react)
- Push sur ECR
- Déploie toutes les stacks sur EKS
- Installe NGINX Ingress Controller via Helm
- Affiche les URLs d'accès à la fin

### `Deploy Monitoring` — `deploy-monitoring.yml`

- Déploie Prometheus via Helm
- Déploie Grafana via Helm avec dashboards préconfigurés
- Affiche les credentials Grafana à la fin

---

## Monitoring

Dashboards Grafana préconfigurés :
- **Kubernetes Cluster** (ID 15661)
- **Node Exporter Full** (ID 1860)

Credentials par défaut : `admin` / `CloudForge2024!`

---

## Coûts estimés AWS

| Ressource | Coût estimé |
|---|---|
| EKS Control Plane | ~$0.10/h |
| 2× t3.medium | ~$0.10/h |
| NAT Gateway | ~$0.05/h + data |
| **Total** | **~$6/jour** |

> Penser à détruire l'infra quand elle n'est pas utilisée.
