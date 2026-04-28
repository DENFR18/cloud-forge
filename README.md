# Cloud Forge

Plateforme DevOps multi-tenant ESN deployee sur **Scaleway Kapsule** via **Terraform** et **GitHub Actions**.
Infrastructure 100% as Code avec monitoring Prometheus + Grafana integre.

---

## Architecture

```
cloud-forge/
├── .github/workflows/       # GitHub Actions (infra, argocd, apps, monitoring, security)
├── terraform/
│   └── modules/
│       ├── kapsule/         # Cluster Kapsule + node pool
│       └── registry/        # Scaleway Container Registry (SCR)
├── charts/                  # Helm charts (source de verite GitOps)
│   ├── namespaces/          # Namespaces + ResourceQuotas
│   ├── wordpress/           # WordPress + MySQL
│   ├── ghost/               # Ghost (SQLite)
│   ├── gitea/               # Gitea
│   ├── node-api/            # API Express.js
│   ├── flask-api/           # API Flask
│   └── react/               # Portail React
├── argocd/                  # Configuration ArgoCD (GitOps)
│   ├── install/values.yaml  # Helm values pour l'install ArgoCD
│   ├── project.yaml         # AppProject cloud-forge
│   ├── root-app.yaml        # App-of-apps (pointe vers applications/)
│   └── applications/        # 1 Application par chart
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
| CI/CD | GitHub Actions + Trivy + Checkov + SonarCloud |
| GitOps | ArgoCD (Helm charts, app-of-apps) |
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
Infrastructure :
  checkov (scan Terraform) → deploy (terraform apply) → wait nodes ready

Deploy ArgoCD :
  helm install argocd → apply project + root-app (app-of-apps)
                      → root-app reconcilie automatiquement
                        toutes les Applications dans argocd/applications/

Deploy Apps :
  validate-yaml + helm-lint → build-scan-push → sync via ArgoCD
                                    │                   │
                                    ├─ docker build     ├─ argocd app set (registry/tag/host)
                                    ├─ Trivy scan       └─ argocd app sync + wait health
                                    └─ docker push (tag = SHA + latest)

Deploy Monitoring :
  setup kubeconfig → Prometheus → Grafana → ingress

Security Scan (push/PR sur main) :
  sonarcloud        → analyse qualite du code
  checkov (pip)     → scan Terraform + K8s manifests + Dockerfiles
```

Le job `validate-yaml` parse tous les fichiers `k8s/**` et `argocd/**` via Python.
Le job `validate-helm` execute `helm lint` + `helm template` sur chaque chart.
Si un fichier est invalide, le pipeline s'arrete avant le build.

---

## Securite

Trois outils de securite integres au pipeline :

### Trivy — scan des images Docker
- Declenche apres chaque `docker build`, avant le `docker push`
- Scanne les vulnerabilites **CRITICAL** et **HIGH** avec correctif disponible
- **Bloque le push** si une vulnerabilite corrigeable est detectee (`exit-code: 1`)
- Cible : images `node-api`, `flask-api`, `react`

### Checkov — scan IaC
- S'execute sur chaque push et PR vers `main`
- Analyse trois perimètres : fichiers Terraform, manifests Kubernetes, Dockerfiles
- Mode `soft-fail` : affiche les alertes dans les logs sans bloquer le pipeline
- Dans `infra.yml`, un job `checkov` precede le `terraform apply`

### SonarCloud — qualite et securite du code
- Analyse statique du code source (`apps/`)
- Detecte les bugs, code smells, et vulnerabilites de securite
- Necessite le secret `SONAR_TOKEN` (genere sur sonarcloud.io)
- Lien projet : https://sonarcloud.io/project/overview?id=denfr18_cloud-forge

---

## Secrets GitHub requis

| Secret | Description |
|---|---|
| `SCW_ACCESS_KEY` | Cle d'acces Scaleway |
| `SCW_SECRET_KEY` | Cle secrete Scaleway |
| `SCW_DEFAULT_ORGANIZATION_ID` | ID organisation Scaleway |
| `SCW_DEFAULT_PROJECT_ID` | ID projet Scaleway |
| `SONAR_TOKEN` | Token SonarCloud (genere sur sonarcloud.io) |
| `MYSQL_ROOT_PASSWORD` | (optionnel) Mot de passe root MySQL pour WordPress. Genere si absent. |
| `MYSQL_USER_PASSWORD` | (optionnel) Mot de passe utilisateur MySQL pour WordPress. Genere si absent. |

---

## Déploiement

Lancer les workflows dans cet ordre :

```
1. Actions -> Infrastructure      -> Run workflow -> deploy
2. Actions -> Deploy ArgoCD       -> Run workflow         (premiere fois uniquement)
3. Actions -> Deploy Apps         -> Run workflow         (build images + sync ArgoCD)
4. Actions -> Deploy Monitoring   -> Run workflow
```

A partir du 2eme run, ArgoCD reconcilie automatiquement les charts a chaque commit
sur la branche cible (`syncPolicy.automated.selfHeal=true`). Le workflow `Deploy Apps`
n'a besoin de tourner que pour reconstruire les images custom (node-api, flask-api, react).

### Acces ArgoCD UI

ArgoCD est expose publiquement via NGINX Ingress sur `argocd.<LB_IP>.nip.io`.
L'URL exacte + le mot de passe admin sont affiches a la fin du workflow `Deploy ArgoCD`.

Fallback (port-forward local) :

```
kubectl -n argocd port-forward svc/argocd-server 8080:443
# https://localhost:8080  - user: admin
# password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
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
