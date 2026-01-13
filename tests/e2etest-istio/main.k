import datetime
import math
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# E2E Test for Istio XRD (Kubernetes-only)
#
# This test uses the Helm provider with ProviderConfig which uses
# injected identity (no credentials needed - runs in-cluster).
# ==============================================================================

# Generate unique name using timestamp to avoid CI conflicts
_now = str(int(math.floor(datetime.ticks())))
_test_name = "e2e-istio-" + _now

_items = [
    metav1alpha1.E2ETest {
        metadata.name = "istio-helm"
        spec = {
            crossplane = {
                version = "2.0.2-up.5"
                autoUpgrade.channel = "None"
            }
            skipDelete = False

            # ==============================================================
            # extraResources: Helm ProviderConfig with injected identity
            # ==============================================================
            extraResources = [
                # Helm ProviderConfig - uses in-cluster identity
                {
                    apiVersion = "helm.crossplane.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata.name = "default"
                    spec = {
                        credentials = {
                            source = "InjectedIdentity"
                        }
                    }
                }
            ]

            # ==============================================================
            # manifests: The Istio XR to test
            # ==============================================================
            manifests = [
                {
                    apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                    kind = "Istio"
                    metadata = {
                        name = _test_name
                        namespace = "default"
                    }
                    spec = {
                        clusterName = _test_name
                        labels = {
                            "hops.ops.com.ai/e2etest" = "true"
                            "hops.ops.com.ai/test-run" = _now
                        }
                        providerConfigRef = {
                            name = "default"
                            kind = "ProviderConfig"
                        }
                        values = {
                            # Minimal resources for E2E test
                            pilot = {
                                resources = {
                                    requests = {
                                        cpu = "10m"
                                        memory = "64Mi"
                                    }
                                }
                            }
                        }
                    }
                }
            ]
        }
    }
]
items = _items
