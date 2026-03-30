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
├── monitoring/
│   ├── prometheus/          # Helm values Prometheus
│   └── grafana/             # Helm values Grafana + dashboards
└── scripts/
    └── validate_yaml.py     # Validation syntaxique des YAML Kubernetes
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
| Validation | Python (PyYAML) — bloque le deploy si YAML invalide |

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

## Pipeline CI/CD

```
Deploy Apps :
  validate-yaml → build-push → deploy

Deploy Monitoring :
  setup kubeconfig → Prometheus → Grafana → ingress
```

Le job `validate-yaml` parse tous les fichiers `k8s/**/*.yaml` via Python.
Si un fichier est invalide, le pipeline s'arrete avant le build.

---

## Secrets GitHub requis

| Secret | Description |
|---|---|
| `SCW_ACCESS_KEY` | Cle d'acces Scaleway |
| `SCW_SECRET_KEY` | Cle secrete Scaleway |
| `SCW_DEFAULT_ORGANIZATION_ID` | ID organisation Scaleway |
| `SCW_DEFAULT_PROJECT_ID` | ID projet Scaleway |

---

## Déploiement

Lancer les workflows dans cet ordre :

```
1. Actions -> Infrastructure      -> Run workflow -> deploy
2. Actions -> Deploy Apps         -> Run workflow
3. Actions -> Deploy Monitoring   -> Run workflow
```

Le workflow Infrastructure cree automatiquement le bucket S3 pour le state Terraform.

Pour détruire :

```
Actions -> Infrastructure -> Run workflow -> destroy
```

---

## Monitoring

5 dashboards Grafana pre-configures dans le dossier **Cloud Forge** :

| Dashboard | ID | Contenu |
|---|---|---|
| Kubernetes Cluster | 15661 | Vue globale du cluster |
| Node Exporter Full | 1860 | CPU, RAM, disk, network par node |
| K8s Pods | 15760 | Ressources par pod |
| K8s Namespaces | 15758 | Ressources par namespace |
| NGINX Ingress | 14981 | Requetes, latence, erreurs par route |

Credentials : `admin` / `CloudForge2024!`

---

## Couts estimes Scaleway

| Ressource | Cout |
|---|---|
| 2x DEV1-M (4 GB RAM) | ~14 EUR/mois |
| Container Registry | Gratuit (< 75 GB) |
| Object Storage (tfstate) | < 1 EUR/mois |
| **Total** | **~15 EUR/mois** |
