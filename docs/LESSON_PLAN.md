# 📖 Lesson Plan — Kubernetes-IaC-Deployment

| Field | Value |
|-------|-------|
| Chain | Chain C — Full-Stack + Infrastructure (project C-4 of 4) |
| Difficulty | Advanced |
| Estimated time | ~4 weeks |
| Prerequisite | [Dockerized-Microservices](../../Dockerized-Microservices) (C-2) |
| Next project | — (final project in Chain C) |
| Primary license | GPL v3 (infra/IaC) |
| From scratch | Yes — no application skeleton; this project IS infrastructure |

## What This Project Is

Everything up through C-2 ran on one Docker host. This project takes that
exact containerized app (`ghcr.io/.../dockerized-microservices-api`) the rest
of the way to production: Terraform provisions the cluster itself (an EKS
control plane + node group, on real AWS), Kubernetes objects describe the
desired state of the running app, Helm packages those objects so one chart
deploys to every environment, and Flux closes the loop — instead of CI
pushing changes to the cluster, the cluster pulls its own desired state from
git on an interval.

**A critical scope note, stated up front rather than discovered later:**
this machine has no real AWS account or live Kubernetes cluster. Every file
in this project is real, and every one of them is verified — but verified
*statically* (`terraform validate`, `kubeconform`, `helm lint`/`helm
template`), not by an actual `terraform apply` or `kubectl apply` against a
live cluster. Static verification catches schema errors, broken references,
and invalid HCL — it does NOT catch IAM permission gaps, quota limits, or
a resource that's syntactically valid but wrong in a live AWS account. That
gap is real and worth naming rather than implying a false confidence level.

## Learning Objectives

- Explain why Terraform's job stops at "the cluster exists" and the
  workload (Deployment/Service/Ingress) is deliberately a separate layer,
  applied with `kubectl`/`helm`, not the `kubernetes` Terraform provider.
- Configure an S3 remote backend with native locking, and explain what
  `terraform init -backend=false` validates without one.
- Explain the difference between a `readinessProbe` and a `livenessProbe` in
  terms of the DIFFERENT action Kubernetes takes on failure (remove from
  Service endpoints vs. restart the container).
- Explain what `maxSurge: 1, maxUnavailable: 0` guarantees about a rolling
  update, and what it costs (a brief resource spike) to guarantee it.
- Template a Helm chart's Deployment/Service/Ingress from `values.yaml`, and
  override a value at deploy time with `--set` without editing the chart.
- Explain the actual shift GitOps makes: the pipeline stops pushing to the
  cluster, and the cluster starts pulling from git — so "someone
  `kubectl edit`s a live object" gets corrected back to what git says,
  instead of silently drifting forever.

## Software You Will Use

| Tool | What it is | Why it matters here | Install | Docs |
|------|-----------|----------------------|---------|------|
| Terraform | Infrastructure-as-code tool | Provisions the EKS cluster + VPC | `brew install terraform` | [Terraform — S3 Backend](https://developer.hashicorp.com/terraform/language/backend/s3) |
| kubectl | Kubernetes CLI | Apply manifests, inspect rollouts, read logs | bundled with Docker Desktop or `brew install kubectl` | [Kubernetes — Liveness/Readiness/Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| Helm | Kubernetes package manager | Templates the app's manifests into one versioned chart | `brew install helm` | [Helm — Chart Template Guide](https://helm.sh/docs/chart_template_guide/getting_started/) |
| kubeconform | Offline K8s manifest validator | Schema-validates manifests with NO live cluster required — this project's actual verification tool | `brew install kubeconform` | — |
| Flux CLI / controllers | GitOps toolkit | `GitRepository` + `Kustomization`/`HelmRelease` reconcile the cluster to match git | `brew install fluxcd/tap/flux` | [Flux — GitRepositories](https://fluxcd.io/flux/components/source/gitrepositories/), [Flux — HelmReleases](https://fluxcd.io/flux/components/helm/helmreleases/) |
| prometheus-community/kube-prometheus-stack | Community Helm chart | Installed, not authored — `monitoring/values-*.yaml` is the override, not a from-scratch Prometheus build | `helm repo add prometheus-community ...` | — |

## The Three Deployment Paths This Project Shows

```
1. Manual:        kubectl apply -f k8s/ (or -k k8s/ for the kustomization)
2. CI-driven:      .github/workflows/deploy.yml -> helm upgrade --set image.tag=<sha>
3. GitOps (Flux):  gitops/.../job-board-kustomization.yaml OR job-board-helmrelease.yaml
                   -> Flux pulls from git on its own interval, no CI push required
```

Paths 2 and 3 reach the same end state through opposite mechanics: in (2),
CI decides when to change the cluster and pushes that change. In (3), the
cluster decides when to check git and pulls whatever it finds.

## Build Order

- **Week 1 — Terraform.** `versions.tf`, `variables.tf`, the VPC +
  subnets + IGW + route table, the EKS cluster + node group IAM roles.
  *Verify: `terraform init -backend=false && terraform validate` — both
  must succeed with zero AWS credentials, since validate only checks the
  configuration's internal consistency, not real cloud state.*
- **Week 2 — Kubernetes objects.** `k8s/deployment.yaml` (readiness +
  liveness probes, `RollingUpdate` strategy), `service.yaml`, `ingress.yaml`,
  `configmap.yaml` + `secret.yaml` (template only — real secrets never
  committed), `hpa.yaml`, and `kustomization.yaml` tying them together.
  *Verify: `kubeconform -strict -summary k8s/*.yaml` — this validates
  against the REAL Kubernetes OpenAPI schema, fully offline, no cluster
  needed. `kubectl kustomize k8s/` confirms the kustomization composes.*
- **Week 3 — Helm.** `Chart.yaml`, `values.yaml`, `templates/` (the same
  three resources, parameterized). *Verify: `helm lint`, then
  `helm template test ./helm/job-board-chart | kubeconform -strict` — this
  catches a templating bug that `helm lint` alone would miss, since lint
  checks chart structure, not whether the RENDERED output is still valid
  Kubernetes YAML.*
- **Week 3.5 — CI/CD.** `.github/workflows/deploy.yml`: build → push to
  GHCR → `helm upgrade --set image.tag=<sha>` → `kubectl rollout status`.
  *Verify: `actionlint .github/workflows/deploy.yml`.*
- **Week 4 — GitOps with Flux.** `gitops/clusters/production/`:
  `GitRepository`, a `Kustomization` (Path A: raw manifests) AND a
  `HelmRelease` (Path B: the chart) shown side by side, plus
  `ImageRepository`/`ImagePolicy` for image automation.
  *Verify: `kubeconform` against the community Flux CRD schema catalog
  (`datreeio/CRDs-catalog`) — this is what makes offline validation of
  CUSTOM resources (not just built-in Kubernetes kinds) possible at all.*

## Common Mistakes to Avoid

- **Managing the workload with the Terraform `kubernetes`/`helm` provider.**
  It's possible, but it couples your application's deploy cadence to your
  infrastructure's `plan`/`apply` cycle — a one-line image tag bump
  shouldn't require touching the same state file as the VPC.
- **Using `livenessProbe` to check "has it finished starting up yet."** A
  slow-starting pod that fails its liveness probe gets KILLED and
  restarted — which can never let a genuinely slow-starting app finish
  starting, versus `readinessProbe`, which just withholds traffic without
  killing anything.
- **Trusting `helm lint` alone to catch template bugs.** Lint checks the
  chart's structure and `Chart.yaml` metadata; it does NOT render every
  template with real values. A typo inside a `{{ if }}` block that only
  triggers under a specific `values.yaml` override can pass lint and still
  produce broken YAML — `helm template | kubeconform` is what actually
  proves the rendered output is valid.
- **Writing a `Secret` manifest with real values and committing it.** Base64
  is encoding, not encryption — `k8s/secret.yaml` here is explicitly a
  template with a placeholder, and the LESSON_PLAN says so directly rather
  than relying on a reader to infer it.
- **Running both a Flux `Kustomization` and a CI `helm upgrade` against the
  SAME release.** Whichever reconciles last wins, silently, on whatever
  interval Flux happens to run next — pick one mechanism of truth per app.

## Why This Matters (Industry Application)

**What this skill is used for in the real world**
Terraform + Kubernetes + Helm is the default production infrastructure
stack at the overwhelming majority of companies running containerized
workloads at any real scale. GitOps (Flux or ArgoCD) is the fast-growing
standard for how the cluster side of that stack is actually operated.

**Roles that hire for it**
- Platform Engineer · DevOps Engineer · SRE
- Backend/Full-Stack roles at companies that own their own infrastructure

**Why it strengthens *my* portfolio**
This is the real deployment target for Centric/Keyholders once they outgrow
a single Docker host — the exact same Terraform-for-cluster,
Helm-for-workload, Flux-for-reconciliation shape applies directly, with the
RBAC and WebSocket patterns from C-3 layered on top of it.

**How it connects to the rest of the portfolio**
- Builds on: [C-2 — Dockerized-Microservices](../../Dockerized-Microservices), [C-3 — Ops-Management-Dashboard](../../Ops-Management-Dashboard)
- Completes Chain C.

## Reflection Questions

1. Why does Terraform's responsibility stop at "the cluster exists," leaving the Deployment/Service/Ingress to a separate `kubectl`/`helm` layer?
2. A pod's `readinessProbe` starts failing but its `livenessProbe` keeps passing. What does Kubernetes do, and why is that the correct behavior rather than a bug?
3. `maxSurge: 1, maxUnavailable: 0` guarantees zero-downtime rolling updates. What does it cost to guarantee that, concretely?
4. Why does `helm lint` passing NOT prove the chart's rendered output is valid Kubernetes YAML — and what command in this project's own verification actually proves that?
5. What's the actual mechanical difference between the CI-driven deploy path (`.github/workflows/deploy.yml`) and the GitOps path (Flux's `Kustomization`/`HelmRelease`) — not just "GitOps uses git," but *who initiates the change* in each?
6. If someone runs `kubectl edit deployment/job-board-job-board` directly against a Flux-managed cluster and changes the replica count, what happens on Flux's next reconciliation, and why?

## Topics to Research

- [Terraform — S3 Backend (state + native locking)](https://developer.hashicorp.com/terraform/language/backend/s3)
- [Kubernetes — Configure Liveness, Readiness, and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Helm — Chart Template Guide](https://helm.sh/docs/chart_template_guide/getting_started/)
- [Flux — GitRepositories](https://fluxcd.io/flux/components/source/gitrepositories/)
- [Flux — Kustomizations](https://fluxcd.io/flux/components/kustomize/kustomizations/)
- [Flux — HelmReleases](https://fluxcd.io/flux/components/helm/helmreleases/)
- [Flux — ImageRepositories (image automation)](https://fluxcd.io/flux/components/image/imagerepositories/)

## How This Connects Forward

This is the last project in Chain C. The four projects together are one
story: C-1 is the app, C-2 containerizes it, C-3 adds a real-time layer to
a sibling app, and C-4 is where all of it actually runs in production — on
infrastructure that's declared, versioned, and self-correcting rather than
remembered and typed by hand under pressure.

## Git Commit Checklist

- [ ] Conventional commits, one feature each (`feat:`, `fix:`, `chore:`).
- [ ] Never commit `.tfstate`, `.tfvars`, or a `Secret` manifest with real values.
- [ ] Run `terraform fmt` before every commit touching `terraform/`.
