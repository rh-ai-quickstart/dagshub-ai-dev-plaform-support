# DagsHub Installation Makefile for OpenShift
# Usage: make -f dagshub.mk install-dagshub NAMESPACE=dagshub-ofridman SERVICE_ACCOUNT=service-account.json [URL=https://my-dagshub.com]

.PHONY: help install-dagshub create-namespaces create-secrets check-service-account check-url authenticate-helm deploy-dagshub expose-route uninstall-dagshub delete-secrets clean status logs restart-main-pod

# Default values
NAMESPACE ?= dagshub
LABEL_STUDIO_NAMESPACE ?= label-studio
SERVICE_ACCOUNT ?= service-account.json
URL ?= http://localhost:3000
CHART_VERSION ?= 1.23.3
RELEASE_NAME ?= dagshub
OCI_REGISTRY ?= oci://us-docker.pkg.dev/dagshub-containers/dagshub-charts/dagshub
FS_GROUP ?= 0

# URL validation patterns
HTTPS_PREFIX := https://
URL_SUFFIX := .com

# Derived values (extracted during runtime, validated in check-service-account)
DOCKER_EMAIL = $(shell grep -o '"client_email": *"[^"]*"' $(SERVICE_ACCOUNT) 2>/dev/null | sed 's/"client_email": *"\([^"]*\)"/\1/')
NGINX_SERVICE = $(RELEASE_NAME)-nginx

# Color output
GREEN = \033[32m
YELLOW = \033[033m
RED = \033[031m
NC = \033[0m # No Color

help:
	@echo -e "$(GREEN)DagsHub OpenShift Installation Makefile$(NC)"
	@echo ""
	@echo "Usage:"
	@echo "  make -f dagshub.mk install-dagshub [NAMESPACE=<namespace>] [SERVICE_ACCOUNT=<path>] [URL=<url>]"
	@echo ""
	@echo "Variables:"
	@echo "  NAMESPACE                 - OpenShift namespace for DagsHub (default: dagshub)"
	@echo "  SERVICE_ACCOUNT           - Path to GCP service account JSON (default: service-account.json)"
	@echo "  URL                       - Public URL for DagsHub (default: http://localhost:3000)"
	@echo "                              For production, use HTTPS URL ending with .com"
	@echo "  LABEL_STUDIO_NAMESPACE    - Label Studio namespace (default: label-studio)"
	@echo "  CHART_VERSION             - Helm chart version (default: 1.23.3)"
	@echo "  RELEASE_NAME              - Helm release name (default: dagshub)"
	@echo "  FS_GROUP                  - Pod fsGroup for volume permissions (default: 0)"
	@echo ""
	@echo "Examples:"
	@echo ""
	@echo "  # Install with custom URL"
	@echo "  make -f dagshub.mk install-dagshub NAMESPACE=<NAMESPACE> SERVICE_ACCOUNT=./sa.json URL=https://dagshub.example.com"
	@echo ""
	@echo "  # Check status"
	@echo "  make -f dagshub.mk status NAMESPACE=<NAMESPACE>"
	@echo ""
	@echo "  # Uninstall"
	@echo "  make -f dagshub.mk uninstall-dagshub NAMESPACE=<NAMESPACE>"
	@echo ""

check-service-account:
	@if [ ! -f "$(SERVICE_ACCOUNT)" ]; then \
		echo -e "$(RED)Error: Service account file '$(SERVICE_ACCOUNT)' not found$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(GREEN)✓ Service account file found: $(SERVICE_ACCOUNT)$(NC)"
	@if [ -z "$(DOCKER_EMAIL)" ]; then \
		echo -e "$(RED)Error: Failed to extract client_email from service account file$(NC)"; \
		echo -e "$(RED)Please ensure the file is a valid GCP service account JSON$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(GREEN)✓ Extracted client_email: $(DOCKER_EMAIL)$(NC)"

check-url:
	@echo -e "$(YELLOW)Validating URL...$(NC)"
	@if [ "$(URL)" != "http://localhost:3000" ]; then \
		if ! echo "$(URL)" | grep -q "^$(HTTPS_PREFIX)"; then \
			echo -e "$(RED)Error: Custom URL must start with https://$(NC)"; \
			echo -e "$(RED)Provided: $(URL)$(NC)"; \
			echo -e "$(YELLOW)For production use, provide a valid HTTPS URL: URL=https://dagshub.example.com$(NC)"; \
			exit 1; \
		fi; \
		if ! echo "$(URL)" | grep -q "$(URL_SUFFIX)$$"; then \
			echo -e "$(RED)Error: Custom URL must end with .com$(NC)"; \
			echo -e "$(RED)Provided: $(URL)$(NC)"; \
			exit 1; \
		fi; \
	fi
	@echo -e "$(GREEN)✓ URL validated: $(URL)$(NC)"

authenticate-helm: check-service-account
	@echo -e "$(YELLOW)Authenticating to Helm OCI registry...$(NC)"
	@cat $(SERVICE_ACCOUNT) | helm registry login -u _json_key --password-stdin us-docker.pkg.dev
	@echo -e "$(GREEN)✓ Helm registry authentication successful$(NC)"

create-namespaces:
	@echo -e  "$(YELLOW)Creating namespaces...$(NC)"
	@oc create namespace $(NAMESPACE) --dry-run=client -o yaml | oc apply -f -
	@oc create namespace $(LABEL_STUDIO_NAMESPACE) --dry-run=client -o yaml | oc apply -f -
	@echo -e "$(GREEN)✓ Namespaces created: $(NAMESPACE), $(LABEL_STUDIO_NAMESPACE)$(NC)"

create-secrets: check-service-account
	@echo -e "$(YELLOW)Creating container registry secrets...$(NC)"
	@oc create secret docker-registry container-registry \
		-n $(NAMESPACE) \
		--docker-server=gcr.io \
		--docker-username=_json_key \
		--docker-password="$$(cat $(SERVICE_ACCOUNT))" \
		--docker-email="$(DOCKER_EMAIL)" \
		--dry-run=client -o yaml | oc apply -f -
	@oc create secret docker-registry container-registry \
		-n $(LABEL_STUDIO_NAMESPACE) \
		--docker-server=gcr.io \
		--docker-username=_json_key \
		--docker-password="$$(cat $(SERVICE_ACCOUNT))" \
		--docker-email="$(DOCKER_EMAIL)" \
		--dry-run=client -o yaml | oc apply -f -
	@echo -e "$(GREEN)✓ Container registry secrets created$(NC)"
	@echo -e "$(YELLOW)Creating OCI registry secrets (for Helm chart pulls)...$(NC)"
	@oc create secret docker-registry oci-registry \
		-n $(NAMESPACE) \
		--docker-server=us-docker.pkg.dev \
		--docker-username=_json_key \
		--docker-password="$$(cat $(SERVICE_ACCOUNT))" \
		--docker-email="$(DOCKER_EMAIL)" \
		--dry-run=client -o yaml | oc apply -f -
	@oc create secret docker-registry oci-registry \
		-n $(LABEL_STUDIO_NAMESPACE) \
		--docker-server=us-docker.pkg.dev \
		--docker-username=_json_key \
		--docker-password="$$(cat $(SERVICE_ACCOUNT))" \
		--docker-email="$(DOCKER_EMAIL)" \
		--dry-run=client -o yaml | oc apply -f -
	@echo -e "$(GREEN)✓ OCI registry secrets created in both namespaces$(NC)"

deploy-dagshub: check-url authenticate-helm
	@echo -e "$(YELLOW)Deploying DagsHub...$(NC)"
	@echo -e "$(YELLOW)Using URL: $(URL)$(NC)"
	@echo -e "$(YELLOW)Using chart version: $(CHART_VERSION)$(NC)"
	@helm upgrade --install $(RELEASE_NAME) $(OCI_REGISTRY) \
		--version $(CHART_VERSION) \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--set omitSecurityContextExceptFsGroup=true \
		--set rootUrl="$(URL)" \
		--set podSecurityContext.fsGroup=$(FS_GROUP) \
		--set labelstudio.namespaces.git=$(LABEL_STUDIO_NAMESPACE) \
		--set labelstudio.namespaces.dataEngine=$(LABEL_STUDIO_NAMESPACE) \
		--set temporal.server.securityContext=null \
		--set temporal.web.securityContext=null \
		--set temporal.server.podSecurityContext=null \
		--set temporal.web.podSecurityContext=null \
		--set redis.master.podSecurityContext.enabled=false \
		--set seaweedfs.master.podSecurityContext.enabled=false \
		--set seaweedfs.volume.podSecurityContext.enabled=false \
		--set seaweedfs.filer.podSecurityContext.enabled=false \
		--timeout 10m \
		--wait
	@echo -e "$(GREEN)✓ DagsHub deployed successfully$(NC)"
expose-route: check-url
	@if [ "$(URL)" = "http://localhost:3000" ]; then \
		echo -e "$(YELLOW)Skipping route creation (using localhost URL)$(NC)"; \
		echo -e "$(YELLOW)To access DagsHub, use port-forwarding:$(NC)"; \
		echo -e "$(YELLOW)  oc port-forward -n $(NAMESPACE) service/$(NGINX_SERVICE) 3000:80$(NC)"; \
	else \
		echo -e "$(YELLOW)Exposing nginx service via OpenShift route...$(NC)"; \
		URL_HOST=$$(echo "$(URL)" | sed -e 's|^https\?://||' -e 's|/.*||'); \
		if oc get route $(NGINX_SERVICE) -n $(NAMESPACE) &>/dev/null; then \
			echo -e "$(YELLOW)Route already exists$(NC)"; \
			ROUTE_URL=$$(oc get route $(NGINX_SERVICE) -n $(NAMESPACE) -o jsonpath='https://{.spec.host}'); \
			echo -e "$(GREEN)DagsHub is accessible at: $$ROUTE_URL$(NC)"; \
		else \
			oc create route edge $(NGINX_SERVICE) --service=$(NGINX_SERVICE) --hostname=$$URL_HOST -n $(NAMESPACE); \
			echo -e "$(GREEN)✓ Route created with hostname: $$URL_HOST and TLS$(NC)"; \
			echo -e "$(GREEN)DagsHub is accessible at: $(URL)$(NC)"; \
		fi; \
	fi

install-dagshub: check-service-account create-namespaces create-secrets deploy-dagshub expose-route
	@echo ""
	@echo -e "$(GREEN)========================================$(NC)"
	@echo -e "$(GREEN)DagsHub Installation Complete!$(NC)"
	@echo -e "$(GREEN)========================================$(NC)"
	@echo ""
	@echo "To check pod status, run:"
	@echo "  oc get pods -n $(NAMESPACE)"
	@echo ""
	@echo "To view logs of the main pod, run:"
	@echo "  oc logs -f $(RELEASE_NAME)-0 -n $(NAMESPACE)"
	@echo ""

status:
	@echo -e "$(YELLOW)DagsHub Status in namespace: $(NAMESPACE)$(NC)"
	@echo ""
	@echo "Helm Release:"
	@helm list -n $(NAMESPACE) | grep $(RELEASE_NAME) || echo "No release found"
	@echo ""
	@echo "Pods:"
	@oc get pods -n $(NAMESPACE)
	@echo ""
	@echo "Services:"
	@oc get svc -n $(NAMESPACE) | grep $(RELEASE_NAME)
	@echo ""
	@if oc get route $(NGINX_SERVICE) -n $(NAMESPACE) &>/dev/null; then \
		echo "Route:"; \
		oc get route $(NGINX_SERVICE) -n $(NAMESPACE); \
		echo ""; \
		ROUTE_URL=$$(oc get route $(NGINX_SERVICE) -n $(NAMESPACE) -o jsonpath='https://{.spec.host}'); \
		echo -e "$(GREEN)Access DagsHub at: $$ROUTE_URL$(NC)"; \
	else \
		echo -e "$(YELLOW)No route exposed yet. Run 'make expose-route NAMESPACE=$(NAMESPACE)' to expose$(NC)"; \
	fi

delete-secrets:
	@echo -e "$(YELLOW)Deleting secrets from namespace: $(NAMESPACE)$(NC)"
	@oc delete secret container-registry -n $(NAMESPACE) --ignore-not-found=true
	@oc delete secret oci-registry -n $(NAMESPACE) --ignore-not-found=true
	@echo -e "$(GREEN)✓ Secrets deleted from $(NAMESPACE)$(NC)"
	@echo -e "$(YELLOW)Deleting secrets from namespace: $(LABEL_STUDIO_NAMESPACE)$(NC)"
	@oc delete secret container-registry -n $(LABEL_STUDIO_NAMESPACE) --ignore-not-found=true
	@oc delete secret oci-registry -n $(LABEL_STUDIO_NAMESPACE) --ignore-not-found=true
	@echo -e "$(GREEN)✓ Secrets deleted from $(LABEL_STUDIO_NAMESPACE)$(NC)"

uninstall-dagshub:
	@echo -e "$(RED)Uninstalling DagsHub from namespace: $(NAMESPACE)$(NC)"
	@helm uninstall $(RELEASE_NAME) -n $(NAMESPACE) || true
	@echo -e "$(YELLOW)Helm release uninstalled$(NC)"
	@echo ""
	@read -p "Do you want to delete the secrets? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		$(MAKE) -f dagshub.mk delete-secrets NAMESPACE=$(NAMESPACE) LABEL_STUDIO_NAMESPACE=$(LABEL_STUDIO_NAMESPACE); \
	else \
		echo -e "$(YELLOW)Secrets preserved. Run 'make -f dagshub.mk delete-secrets NAMESPACE=$(NAMESPACE)' to delete them later$(NC)"; \
	fi
	@echo ""
	@read -p "Do you want to delete the namespace '$(NAMESPACE)'? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		oc delete namespace $(NAMESPACE) --wait=false; \
		echo -e "$(YELLOW)Namespace $(NAMESPACE) deletion initiated (this will also delete any remaining secrets)$(NC)"; \
	else \
		echo -e "$(YELLOW)Namespace $(NAMESPACE) preserved$(NC)"; \
	fi
	@echo ""
	@read -p "Do you want to delete the Label Studio namespace '$(LABEL_STUDIO_NAMESPACE)'? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		oc delete namespace $(LABEL_STUDIO_NAMESPACE) --wait=false; \
		echo -e "$(YELLOW)Namespace $(LABEL_STUDIO_NAMESPACE) deletion initiated (this will also delete any remaining secrets)$(NC)"; \
	else \
		echo -e "$(YELLOW)Namespace $(LABEL_STUDIO_NAMESPACE) preserved$(NC)"; \
	fi

clean: uninstall-dagshub
	@echo -e "$(GREEN)Cleanup complete$(NC)"

logs:
	@echo -e "$(YELLOW)Streaming logs from $(RELEASE_NAME)-0...$(NC)"
	@oc logs -f $(RELEASE_NAME)-0 -n $(NAMESPACE)

restart-main-pod:
	@echo -e "$(YELLOW)Restarting main DagsHub pod...$(NC)"
	@oc delete pod $(RELEASE_NAME)-0 -n $(NAMESPACE)
	@echo -e "$(GREEN)Pod deleted, waiting for restart...$(NC)"
	@oc wait --for=condition=Ready pod/$(RELEASE_NAME)-0 -n $(NAMESPACE) --timeout=300s
	@echo -e "$(GREEN)Pod restarted successfully$(NC)"
