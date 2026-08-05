# ☸️ Kubernetes-IaC-Deployment
### Ship to Kubernetes from scratch — Terraform, K8s, Helm, Prometheus.

![Chain C](https://img.shields.io/badge/Chain%20C-Project%204-378ADD?style=for-the-badge) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue?style=for-the-badge)](LICENSE-GPL) [![License: AGPL v3](https://img.shields.io/badge/License-AGPLv3-blue?style=for-the-badge)](LICENSE-AGPL)

[📖 Lesson Plan](docs/LESSON_PLAN.md) · [🚀 Live Demo](#)

<!-- SCREENSHOT PLACEHOLDER: docs/screenshots/overview.png -->

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
├── README.md
├── docs/{LESSON_PLAN.md, interactive/index.html, screenshots/}
├── LICENSE-GPL
└── LICENSE-AGPL
```

## Getting Started

```bash
git clone https://github.com/niciahrymer-hillian/Kubernetes-IaC-Deployment.git
cd Kubernetes-IaC-Deployment
# Provision the cluster
terraform init && terraform apply

# Deploy the application
helm install ops ./chart

# Watch the rollout, then practise the rollback
kubectl rollout status deploy/ops
kubectl rollout undo deploy/ops
```

## Chain Navigation

Part of **Chain C — Full-Stack + Infrastructure** in the [Post-Bootcamp-Challenge](https://github.com/niciahrymer-hillian/Post-Bootcamp-Challenge) portfolio.

---

Dual licensed — [GPL v3](LICENSE-GPL) and [AGPL v3](LICENSE-AGPL).
