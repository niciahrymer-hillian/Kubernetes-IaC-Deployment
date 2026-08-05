# 📖 Lesson Plan — Kubernetes-IaC-Deployment

> **Chain C — Full-Stack + Infrastructure** | Ship to Kubernetes from scratch — Terraform, K8s, Helm, Prometheus.

## What This Project Is

Deploy to Kubernetes declaratively with infrastructure as code — manifests, config and secrets, scaling, and rollouts that can be reversed.

## Learning Objectives

By the end I can:

1. Write Deployment, Service, and Ingress manifests.
2. Explain the reconciliation loop and desired state.
3. Manage configuration with ConfigMaps and Secrets.
4. Set liveness and readiness probes correctly.
5. Perform a rolling update and a rollback.
6. Set resource requests and limits deliberately.

## Software You Will Use

- kubectl with kind, minikube, or k3s.
- Helm or Kustomize.
- Terraform (optional) for cluster provisioning.

## Build Order

1. Deploy a single service with a manifest.
2. Add a Service and Ingress; reach it from outside.
3. Externalise configuration and secrets.
4. Add liveness and readiness probes; test each by breaking it.
5. Perform a rolling update, then roll it back.
6. Set resource requests and observe scheduling behaviour.

## Common Mistakes to Avoid

- Confusing liveness and readiness, causing restart loops.
- No resource limits, so one pod starves the node.
- Secrets committed to version control as base64 (which is not encryption).
- Imperative kubectl edits that vanish on the next apply.
- No rollback plan for a bad image.

## Check Your Understanding

The quiz covers liveness vs readiness, reconciliation, rolling updates, and resource requests vs limits.

## Why This Matters (Industry Application)

Kubernetes runs a large share of production infrastructure, and declarative deployment is the standard practice. The core ideas — desired state, reconciliation, health probes, and rolling updates with rollback — are what make deployments repeatable instead of ceremonial.

## Reflection Questions

- What happens to in-flight requests during your rolling update?
- How would you know a deployment was bad before your users told you?
