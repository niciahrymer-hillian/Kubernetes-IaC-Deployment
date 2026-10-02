# ☸️ Kubernetes-IaC-Deployment
### Ship to Kubernetes from scratch — Terraform, K8s, Helm, Prometheus.

![Chain C](https://img.shields.io/badge/Chain%20C-Project%204-378ADD?style=for-the-badge) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue?style=for-the-badge)](LICENSE-GPL) [![License: AGPL v3](https://img.shields.io/badge/License-AGPLv3-blue?style=for-the-badge)](LICENSE-AGPL)

[📖 Lesson Plan](docs/LESSON_PLAN.md) · [🚀 Live Demo](#)

<!-- SCREENSHOT PLACEHOLDER: docs/screenshots/overview.png -->

> **Why this matters:** Terraform + Kubernetes + Helm + GitOps is the
> default production deployment stack at any company past a handful of
> engineers — hired for as *Platform Engineer* or *DevOps/SRE*. This project
> takes C-2's exact containerized app the rest of the way to production.

## Why This Was Built

Deploying by hand is fine right up until you have to do it again under pressure and can't remember the
steps. Kubernetes plus infrastructure-as-code replaces that memory with a declaration: this is the desired
state, go make it true.

I want the full path — Terraform provisioning the cluster, Helm packaging the application, probes that
genuinely reflect readiness, and a rollback I've actually rehearsed rather than assumed.

## Tech Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| Terraform | — | Provision the cluster and supporting cloud resources declaratively |
| Kubernetes | — | Run the workload against a declared desired state |
| Helm | — | Package and template the application's manifests |
| Prometheus | — | Scrape metrics and drive alerting |
| Grafana | — | Visualise cluster and application health |
| GHCR | — | Host the built container images the cluster pulls |

## Project Structure

```
Kubernetes-IaC-Deployment/
├── terraform/              # provisions the EKS cluster + VPC only — not the workload
│   ├── main.tf, variables.tf, outputs.tf, versions.tf
│   └── backend.tf          # S3 remote state (commented — needs a real bucket)
├── k8s/                    # raw manifests: Deployment, Service, Ingress, ConfigMap, Secret, HPA
│   └── kustomization.yaml
├── helm/job-board-chart/   # the same app, packaged as a Helm chart
├── monitoring/values-kube-prometheus-stack.yaml  # override for the COMMUNITY chart
├── gitops/clusters/production/  # Flux: GitRepository, Kustomization, HelmRelease, image automation
├── .github/workflows/deploy.yml  # build -> push GHCR -> helm upgrade -> verify rollout
├── docs/{LESSON_PLAN.md, interactive/index.html, screenshots/}
├── LICENSE-GPL
└── LICENSE-AGPL
```

## Getting Started

```bash
git clone https://github.com/niciahrymer-hillian/Kubernetes-IaC-Deployment.git
cd Kubernetes-IaC-Deployment

# Provision the cluster (needs real AWS credentials)
cd terraform && terraform init && terraform apply
aws eks update-kubeconfig --region us-east-1 --name job-board-cluster

# Deploy the application
cd ../helm && helm install job-board ./job-board-chart -n job-board --create-namespace

# Watch the rollout, then practise the rollback
kubectl rollout status deploy/job-board-job-board -n job-board
kubectl rollout undo deploy/job-board-job-board -n job-board

# Static validation (no cluster/cloud account needed) — how this repo itself
# was verified:
terraform -chdir=terraform init -backend=false && terraform -chdir=terraform validate
kubeconform -strict -summary k8s/*.yaml
helm lint helm/job-board-chart && helm template test helm/job-board-chart | kubeconform -strict
```

## Chain Navigation

Part of **Chain C — Full-Stack + Infrastructure** in the [Post-Bootcamp-Challenge](https://github.com/niciahrymer-hillian/Post-Bootcamp-Challenge) portfolio.

---

Dual licensed — [GPL v3](LICENSE-GPL) and [AGPL v3](LICENSE-AGPL).
