# Default target
.DEFAULT_GOAL := help

# Vars
KIND_CLUSTER    := kind
KYVERNO_NS      := kyverno
KYVERNO_RELEASE := kyverno
POLICIES_FILE   := policies.yaml
PSS_VERSION := v1.33


.PHONY: help
help: ## Show help for each target
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?##"} {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

.PHONY: create-cluster
create-cluster: ## Create a Kind cluster
	@kind create cluster --name $(KIND_CLUSTER)

.PHONY: delete-cluster
delete-cluster: ## Delete the Kind cluster
	@kind delete cluster --name $(KIND_CLUSTER)

.PHONY: install-kyverno
install-kyverno: ## Install Kyverno via Helm (namespace: $(KYVERNO_NS))
	@helm repo add kyverno https://kyverno.github.io/kyverno/ --force-update
	@helm repo update
	@helm install $(KYVERNO_RELEASE) kyverno/kyverno -n $(KYVERNO_NS) --create-namespace


install-kyverno-permissions: ## Install Kyverno RBAC permissions
	@kubectl apply -f kyverno-permissions.yaml

.PHONY: install-policies
install-policies: ## Apply Kyverno policies from $(POLICIES_FILE)
	@kubectl apply -f $(POLICIES_FILE)

.PHONY: pss-baseline-all
pss-baseline-all: ## Label all namespaces with baseline PSS labels
	for ns in $$(kubectl get ns -o name); do \
		kubectl patch $$ns --type merge -p '{"metadata":{"labels":{"pod-security.kubernetes.io/enforce":"baseline","pod-security.kubernetes.io/enforce-version":"$(PSS_VERSION)","pod-security.kubernetes.io/audit":"restricted","pod-security.kubernetes.io/audit-version":"$(PSS_VERSION)","pod-security.kubernetes.io/warn":"restricted","pod-security.kubernetes.io/warn-version":"$(PSS_VERSION)"}}}'; \
	done

.PHONY: bootstrap-secured-cluster
bootstrap-secured-cluster: create-cluster install-kyverno install-kyverno-permissions pss-baseline-all install-policies ## Create a secured Kind cluster with Kyverno and policies



.PHONY: test-cluster-with-ns-creation
test-cluster-with-ns-creation: ## Test cluster by creating namespaces and deploying Nginx
	@kubectl apply -f ./test-resources.yaml



.PHONY: test-cluster-with-ns-deletion
test-cluster-with-ns-deletion: ## Test cluster by deleting namespaces
	@kubectl delete -f ./test-resources.yaml
