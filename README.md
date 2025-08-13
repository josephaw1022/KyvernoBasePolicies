# Kyverno Secured Kind Cluster

This repo sets up a Kind cluster with Kyverno and applies security-focused policies automatically.

## What It Does

* Installs Kyverno via Helm
* Adds RBAC so Kyverno can create PodDisruptionBudgets
* Labels all namespaces with Pod Security Standards (baseline enforce, restricted audit/warn)
* Generates default:

  * `LimitRange`
  * `ResourceQuota`
  * `NetworkPolicy` (default deny)
  * `PodDisruptionBudget` for Deployments
* Enforces restricted `securityContext` on Deployments

## Quick Start

```bash
make bootstrap-secured-cluster   # Create Kind cluster, install Kyverno & policies
make test-cluster-with-ns-creation   # Create test namespace & nginx deployment
make test-cluster-with-ns-deletion   # Remove test resources
make delete-cluster                  # Tear down cluster
```

## Files

* `makefile` – Commands for setup, testing, cleanup
* `kyverno-permissions.yaml` – RBAC for PDB creation
* `policies.yaml` – Kyverno policies for namespace defaults & security
* `test-resources.yaml` – Example namespace, nginx deployment, service
