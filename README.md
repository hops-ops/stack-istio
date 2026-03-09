# istio-stack

A Crossplane Configuration package that installs Istio (base, istiod, and gateways) via Helm with a minimal, stable interface.

## Overview

`istio-stack` renders three categories of Helm releases:

- **istio-base** — CRDs and cluster-wide resources
- **istiod** — Istio control plane with observability defaults (Prometheus, Tempo)
- **gateways** — Ingress and egress gateway instances (both included by default)

Optionally, `egress.allowedHosts` restricts outbound traffic to an explicit allowlist — no Istio knowledge required.

Deletion protection (Usages) ensures correct teardown order: gateways before istiod, istiod before base.

## Prerequisites

- Crossplane installed in the cluster
- Crossplane providers:
  - `provider-helm` (>=v1.0.6)
  - `provider-kubernetes` (>=v0.15.0) — only needed when using `egress.allowedHosts`
- Crossplane function:
  - `function-auto-ready` (>=v0.6.0)

## Quick Start

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: istio-stack
spec:
  package: ghcr.io/hops-ops/istio-stack:latest
```

```yaml
apiVersion: hops.ops.com.ai/v1alpha1
kind: IstioStack
metadata:
  name: istio
  namespace: example-env
spec:
  clusterName: example-cluster
```

This minimal spec installs istio-base, istiod, and default ingress + egress gateways in `istio-system`.

## Egress Allowlist

To restrict outbound traffic to specific hosts, list them under `egress.allowedHosts`. This automatically:

1. Sets `outboundTrafficPolicy.mode: REGISTRY_ONLY` on istiod (blocks all unlisted egress)
2. Creates a `ServiceEntry` per host allowing HTTPS on port 443

```yaml
spec:
  clusterName: example-cluster
  egress:
    allowedHosts:
    - "*.googleapis.com"
    - "api.github.com"
    - "registry.npmjs.org"
```

Wildcard hosts (e.g. `*.googleapis.com`) use `resolution: NONE`. Specific hosts use `resolution: DNS`.

> **Note:** Requires a `provider-kubernetes` ProviderConfig with the same name as your Helm ProviderConfig.

## Full Example

```yaml
apiVersion: hops.ops.com.ai/v1alpha1
kind: IstioStack
metadata:
  name: istio
  namespace: example-env
spec:
  clusterName: example-cluster
  labels:
    team: platform
  namespace: istio-system
  istiod:
    values:
      pilot:
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
  gateways:
  - name: istio-ingressgateway
    type: LoadBalancer
  - name: istio-egressgateway
    type: ClusterIP
  egress:
    allowedHosts:
    - "*.googleapis.com"
    - "api.github.com"
```

## Spec Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `clusterName` | string | **required** | Target cluster name, used for provider config |
| `labels` | map | `{}` | Labels merged with defaults on all resources |
| `namespace` | string | `istio-system` | Namespace for all Helm releases |
| `providerConfigRef.name` | string | `<clusterName>` | Helm ProviderConfig name |
| `providerConfigRef.kind` | string | `ProviderConfig` | ProviderConfig or ClusterProviderConfig |
| `base.values` | object | `{}` | Helm values merged with istio-base defaults |
| `base.overrideAllValues` | object | | Replaces all istio-base defaults |
| `istiod.values` | object | `{}` | Helm values merged with istiod defaults |
| `istiod.overrideAllValues` | object | | Replaces all istiod defaults |
| `gateways` | array | ingress + egress | List of gateway instances |
| `gateways[].name` | string | `istio-ingressgateway` | Gateway name |
| `gateways[].type` | string | `LoadBalancer` | Service type |
| `gateways[].ports` | array | `[]` | Custom port definitions |
| `gateways[].values` | object | `{}` | Per-gateway Helm values |
| `gateways[].overrideAllValues` | object | | Replaces all gateway defaults |
| `egress.allowedHosts` | string[] | `[]` | Hosts to allow egress to (enables REGISTRY_ONLY) |

## Development

```bash
make render        # Render all examples
make validate      # Validate against XRD schema
make test          # Run unit tests
make e2e           # Run E2E tests
```
