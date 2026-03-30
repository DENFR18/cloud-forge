# Cloud Forge

Plateforme DevOps multi-tenant ESN deployee sur **Scaleway Kapsule** via **Terraform** et **GitHub Actions**.
Infrastructure 100% as Code avec monitoring Prometheus + Grafana integre.

---

## Architecture

```
cloud-forge/
├── .github/workflows/       # GitHub Actions (infra, apps, monitoring)
├── terraform/
│   └── modules/
│       ├── kapsule/         # Cluster Kapsule + node pool
│       └── registry/        # Scaleway Container Registry (SCR)
├── k8s/                     # Manifestes Kubernetes par stack
│   ├── namespaces/          # Namespaces + ResourceQuotas
│   ├── wordpress/           # WordPress + MySQL
│   ├── ghost/               # Ghost (SQLite)
│   ├── gitea/               # Gitea
│   ├── node-api/            # API Express.js
│   ├── flask-api/           # API Flask
│   └── react/               # Portail React
├── apps/
│   ├── node-api/            # API Express.js (Node 20)
│   ├── flask-api/           # API Flask + Gunicorn (Python 3.12)
│   └── react/               # Frontend React + Vite (servi via Nginx)
└── monitoring/
    ├── prometheus/           # Helm values Prometheus
    └── grafana/              # Helm values Grafana + dashboards
```

---

## Stack technique

| Composant | Technologie |
|---|---|
| Cloud | Scaleway (fr-par) |
| Kubernetes | Scaleway Kapsule 1.34 (Cilium CNI) |
| IaC | Terraform + provider scaleway/scaleway |
| CI/CD | GitHub Actions |
| Registry | Scaleway Container Registry (SCR) |
| Ingress | NGINX Ingress Controller |
| Monitoring | Prometheus + Grafana (Helm) |
| DNS | nip.io (wildcard DNS) |
| State Terraform | Scaleway Object Storage (S3-compatible) |

---

## Stacks deployees

| Stack | Namespace | Image | Acces |
|---|---|---|---|
| WordPress + MySQL | `stack-wordpress` | Docker Hub | `wordpress.<IP>.nip.io` |
| Ghost (SQLite) | `stack-ghost` | Docker Hub | `ghost.<IP>.nip.io` |
| Gitea | `stack-gitea` | Docker Hub | `gitea.<IP>.nip.io` |
| Node API | `stack-node-api` | SCR | `<IP>.nip.io/api` |
| Flask API | `stack-flask-api` | SCR | `<IP>.nip.io/flask` |
| Portail React | `stack-react` | SCR | `<IP>.nip.io` |
| Grafana | `monitoring` | Helm | `grafana.<IP>.nip.io` |
| Prometheus | `monitoring` | Helm | `prometheus.<IP>.nip.io` |

---

## Demarrage

### 1. Prerequis

- Compte Scaleway avec cles API generees
- Compte GitHub avec acces au repo
- Secrets GitHub configures :
  - `SCW_ACCESS_KEY` — Cle d'acces Scaleway
  - `SCW_SECRET_KEY` — Cle secrete Scaleway
  - `SCW_DEFAULT_ORGANIZATION_ID` — ID organisation Scaleway
  - `SCW_DEFAULT_PROJECT_ID` — ID projet Scaleway

### 2. Deploiement

Lancer les workflows dans cet ordre :

```
1. Actions -> Infrastructure      -> Run workflow -> deploy
2. Actions -> Deploy Apps         -> Run workflow
3. Actions -> Deploy Monitoring   -> Run workflow
```

Le workflow Infrastructure cree automatiquement le bucket S3 pour le state Terraform.

### 3. Destruction

```
Actions -> Infrastructure -> Run workflow -> destroy
```

---

## Workflows GitHub Actions

### `Infrastructure` — `infra.yml`

Declenchement manuel avec choix de l'action :

- **deploy** — Cree le cluster Kapsule, le node pool, le registry SCR et le reseau prive
- **destroy** — Detruit toute l'infra Scaleway

### `Deploy Apps` — `deploy-apps.yml`

- Build les images Docker (node-api, flask-api, react)
- Push sur Scaleway Container Registry
- Deploie toutes les stacks sur Kapsule
- Installe NGINX Ingress Controller via Helm
- Configure le routage host-based avec nip.io
- Affiche les URLs d'acces a la fin

### `Deploy Monitoring` — `deploy-monitoring.yml`

- Deploie Prometheus via Helm
- Deploie Grafana via Helm avec dashboards preconfigures
- Configure les ingress monitoring
- Affiche les credentials Grafana a la fin

---

## Monitoring

Dashboards Grafana preconfigures :
- **Kubernetes Cluster** (ID 15661)
- **Node Exporter Full** (ID 1860)

Credentials par defaut : `admin` / `CloudForge2024!`

---

## Couts estimes Scaleway

| Ressource | Cout estime |
|---|---|
| 2x DEV1-M (4 GB RAM) | ~14 EUR/mois |
| Container Registry | Gratuit (< 75 GB) |
| Object Storage (tfstate) | < 1 EUR/mois |
| **Total** | **~15 EUR/mois** |

---

SUP DE VINCI — Mastere DevOps 2025-2026
