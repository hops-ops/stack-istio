import datetime
import math
import models.ai.com.ops.hops.stacks.v1alpha1 as stacksv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

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
                autoUpgrade.channel = "Rapid"
            }
            defaultConditions = ["Ready"]
            timeoutSeconds = 1800  # 30 minutes
            cleanupTimeoutSeconds = 1800  # 30 minutes
            skipDelete = False

            # ==============================================================
            # extraResources: RBAC, Helm ProviderConfig, Kubernetes ProviderConfig
            # These are NOT deleted during cleanup
            # ==============================================================
            extraResources = [
                # Grant cluster-admin to all SAs in crossplane-system namespace
                # This allows the Helm provider to create namespaces and install charts,
                # and for Kubernetes provider to create Object resources
                {
                    apiVersion = "rbac.authorization.k8s.io/v1"
                    kind = "ClusterRoleBinding"
                    metadata.name = "crossplane-system-cluster-admin"
                    roleRef = {
                        apiGroup = "rbac.authorization.k8s.io"
                        kind = "ClusterRole"
                        name = "cluster-admin"
                    }
                    subjects = [
                        {
                            kind = "Group"
                            name = "system:serviceaccounts:crossplane-system"
                            apiGroup = "rbac.authorization.k8s.io"
                        }
                    ]
                }
                # Helm ProviderConfig - uses in-cluster identity
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata = {
                        name = "default"
                        namespace = "default"
                    }
                    spec = {
                        credentials = {
                            source = "InjectedIdentity"
                        }
                    }
                }
                # Kubernetes ProviderConfig - uses in-cluster identity
                # Used by Object resources (namespace, egress ServiceEntries)
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "ProviderConfig"
                    metadata = {
                        name = "default"
                        namespace = "default"
                    }
                    spec = {
                        credentials = {
                            source = "InjectedIdentity"
                        }
                    }
                }
            ]

            # ==============================================================
            # manifests: The Istio XR to test
            # Resources here ARE deleted during cleanup
            # ==============================================================
            manifests = [
                stacksv1alpha1.IstioStack {
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
                        istiod = {
                            values = {
                                pilot = {
                                    resources = {
                                        requests = {cpu = "10m", memory = "64Mi"}
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
