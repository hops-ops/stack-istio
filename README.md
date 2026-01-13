# helm-istio

A Crossplane Configuration package that installs the istiod Helm chart with a minimal, stable interface.

## Overview

`helm-istio` renders a single Helm release for istiod (Istio control plane). It exposes only the inputs needed
for chart values, namespace, and release name, keeping the interface stable while allowing full Helm overrides.

## Features

- **Minimal Helm interface**: values and overrideAllValues with stable defaults
- **Predictable naming**: defaults to `<clusterName>-istio` in the `istio-system` namespace
- **GitOps friendly**: ships a `.gitops/` deploy chart

## Prerequisites

- Crossplane installed in the cluster
- Crossplane providers:
  - `provider-helm` (>=v1.0.2)
- Crossplane function:
  - `function-auto-ready` (>=v0.6.0)

## Quick Start

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: helm-istio
spec:
  package: ghcr.io/hops-ops/helm-istio:latest
```

```yaml
apiVersion: helm.hops.ops.com.ai/v1alpha1
kind: Istio
metadata:
  name: istio
  namespace: example-env
spec:
  clusterName: example-cluster
  values:
    pilot:
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
```

## Development

```bash
make render
make validate
make test
```
