# DagsHub Installation Makefile for OpenShift
# Usage: make -f dagshub.mk install-dagshub NAMESPACE=dagshub-ofridman SERVICE_ACCOUNT=service-account.json [URL=https://my-dagshub.com]

.PHONY: help install-dagshub install-dagshub-with-route create-namespaces create-secrets generate-values-file deploy-dagshub expose-route uninstall-dagshub delete-secrets clean status logs restart-main-pod

# Default values
NAMESPACE ?= dagshub
LABEL_STUDIO_NAMESPACE ?= label-studio
SERVICE_ACCOUNT ?= service-account.json
URL ?=
CHART_VERSION ?= 1.23.3
RELEASE_NAME ?= dagshub
OCI_REGISTRY ?= oci://us-docker.pkg.dev/dagshub-containers/dagshub-charts/dagshub
FS_GROUP ?= 0

# Derived values
DOCKER_EMAIL = $(shell grep -o '"client_email": *"[^"]*"' $(SERVICE_ACCOUNT) | sed 's/"client_email": *"\([^"]*\)"/\1/')
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
	@echo "  make -f dagshub.mk install-dagshub NAMESPACE=<namespace> SERVICE_ACCOUNT=<path-to-json> [URL=<url>]"
	@echo "  make -f dagshub.mk install-dagshub-with-route NAMESPACE=<namespace> SERVICE_ACCOUNT=<path-to-json> [URL=<url>]"
	@echo ""
	@echo "Required variables:"
	@echo "  NAMESPACE          - OpenShift namespace for DagsHub (default: dagshub)"
	@echo "  SERVICE_ACCOUNT    - Path to GCP service account JSON file (default: service-account.json)"
	@echo ""
	@echo "Optional variables:"
	@echo "  URL                       - Public URL for DagsHub (if not set, uses OpenShift route default)"
	@echo "  LABEL_STUDIO_NAMESPACE    - Label Studio namespace (default: label-studio)"
	@echo "  CHART_VERSION             - Helm chart version (default: 1.23.3)"
	@echo "  RELEASE_NAME              - Helm release name (default: dagshub)"
	@echo "  FS_GROUP                  - Pod fsGroup for volume permissions (default: 0)"
	@echo ""
	@echo "Examples:"
	@echo "  make -f dagshub.mk install-dagshub NAMESPACE=dagshub-prod SERVICE_ACCOUNT=./my-sa.json"
	@echo "  make -f dagshub.mk install-dagshub-with-route NAMESPACE=dagshub-prod SERVICE_ACCOUNT=./my-sa.json"
	@echo "  make -f dagshub.mk install-dagshub NAMESPACE=dagshub-dev SERVICE_ACCOUNT=./sa.json URL=https://dagshub.example.com"
	@echo "  make -f dagshub.mk expose-route NAMESPACE=dagshub-prod"
	@echo "  make -f dagshub.mk delete-secrets NAMESPACE=dagshub-prod"
	@echo "  make -f dagshub.mk uninstall-dagshub NAMESPACE=dagshub-prod"
	@echo ""

check-service-account:
	@if [ ! -f "$(SERVICE_ACCOUNT)" ]; then \
		echo -e "$(RED)Error: Service account file '$(SERVICE_ACCOUNT)' not found$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(GREEN)✓ Service account file found: $(SERVICE_ACCOUNT)$(NC)"

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
	@echo -e "$(YELLOW)Creating OCI registry secret...$(NC)"
	@oc create secret generic oci-registry \
		-n $(NAMESPACE) \
		--from-file=config.json=$(SERVICE_ACCOUNT) \
		--dry-run=client -o yaml | oc apply -f -
	@echo -e "$(GREEN)✓ OCI registry secret created$(NC)"

get-route-url:
	@if [ -z "$(URL)" ]; then \
		echo -e "$(YELLOW)No URL specified, determining OpenShift route URL...$(NC)" >&2; \
		ROUTE_HOST=$$(oc get route $(NGINX_SERVICE) -n $(NAMESPACE) -o jsonpath='{.spec.host}' 2>/dev/null || echo ""); \
		if [ -z "$$ROUTE_HOST" ]; then \
			CLUSTER_DOMAIN=$$(oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}' 2>/dev/null || echo ""); \
			if [ -z "$$CLUSTER_DOMAIN" ]; then \
				echo "http://$(NGINX_SERVICE).$(NAMESPACE).svc.cluster.local"; \
			else \
				echo "https://$(NGINX_SERVICE)-$(NAMESPACE).$$CLUSTER_DOMAIN"; \
			fi; \
		else \
			echo "https://$$ROUTE_HOST"; \
		fi; \
	else \
		echo "$(URL)"; \
	fi

generate-values-file:
	@DAGSHUB_URL=$$($(MAKE) -s get-route-url NAMESPACE=$(NAMESPACE) URL=$(URL)); \
	printf "omitSecurityContexts: true\n" > /tmp/dagshub-install-values.yaml; \
	printf "rootUrl: \"$$DAGSHUB_URL\"\n" >> /tmp/dagshub-install-values.yaml; \
	printf "\nlabelstudio:\n  namespaces:\n    git: $(LABEL_STUDIO_NAMESPACE)\n    dataEngine: $(LABEL_STUDIO_NAMESPACE)\n" >> /tmp/dagshub-install-values.yaml; \
	printf "\ntemporal:\n  server:\n    securityContext: {}\n    podSecurityContext: {}\n  web:\n    securityContext: {}\n    podSecurityContext: {}\n" >> /tmp/dagshub-install-values.yaml; \

deploy-dagshub: authenticate-helm
	@echo -e "$(YELLOW)Deploying DagsHub...$(NC)"
	@DAGSHUB_URL=$$($(MAKE) -s get-route-url NAMESPACE=$(NAMESPACE) URL=$(URL)); \
	echo -e "$(YELLOW)Using URL: $$DAGSHUB_URL$(NC)"; \
	helm upgrade --install $(RELEASE_NAME) $(OCI_REGISTRY) \
		--version $(CHART_VERSION) \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--set omitSecurityContextExceptFsGroup=true \
		--set rootUrl="$$DAGSHUB_URL" \
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
expose-route:
	@echo -e "$(YELLOW)Exposing nginx service via OpenShift route...$(NC)"
	@if oc get route $(NGINX_SERVICE) -n $(NAMESPACE) &>/dev/null; then \
		echo -e "$(YELLOW)Route already exists$(NC)"; \
	else \
		if [ -z "$(URL)" ]; then \
			oc create route edge $(NGINX_SERVICE) --service=$(NGINX_SERVICE) -n $(NAMESPACE); \
			echo -e "$(GREEN)✓ Route created with auto-generated hostname and TLS$(NC)"; \
		else \
			URL_HOST=$$(echo "$(URL)" | sed -e 's|^https\?://||' -e 's|/.*||'); \
			oc create route edge $(NGINX_SERVICE) --service=$(NGINX_SERVICE) --hostname=$$URL_HOST -n $(NAMESPACE); \
			echo -e "$(GREEN)✓ Route created with hostname: $$URL_HOST and TLS$(NC)"; \
		fi; \
	fi
	@ROUTE_URL=$$(oc get route $(NGINX_SERVICE) -n $(NAMESPACE) -o jsonpath='https://{.spec.host}'); \
	echo -e "$(GREEN)DagsHub is accessible at: $$ROUTE_URL$(NC)"

install-dagshub: check-service-account create-namespaces create-secrets deploy-dagshub
	@echo ""
	@echo -e "$(GREEN)========================================$(NC)"
	@echo -e "$(GREEN)DagsHub Installation Complete!$(NC)"
	@echo -e "$(GREEN)========================================$(NC)"
	@echo ""
	@echo "To expose DagsHub externally, run:"
	@echo "  make -f dagshub.mk expose-route NAMESPACE=$(NAMESPACE)"
	@echo ""
	@echo "To check pod status, run:"
	@echo "  oc get pods -n $(NAMESPACE)"
	@echo ""
	@echo "To view logs of the main pod, run:"
	@echo "  oc logs -f $(RELEASE_NAME)-0 -n $(NAMESPACE)"
	@echo ""

install-dagshub-with-route: check-service-account create-namespaces create-secrets deploy-dagshub expose-route
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
	@echo -e "$(GREEN)✓ Secrets deleted from $(LABEL_STUDIO_NAMESPACE)$(NC)"

uninstall-dagshub:
	@echo -e "$(RED)Uninstalling DagsHub from namespace: $(NAMESPACE)$(NC)"
	@helm uninstall $(RELEASE_NAME) -n $(NAMESPACE) || true
	@echo -e "$(YELLOW)Helm release uninstalled$(NC)"
	@echo ""
	@read -p "Do you want to delete the secrets? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		$(MAKE) delete-secrets NAMESPACE=$(NAMESPACE) LABEL_STUDIO_NAMESPACE=$(LABEL_STUDIO_NAMESPACE); \
	else \
		echo -e "$(YELLOW)Secrets preserved. Run 'make delete-secrets NAMESPACE=$(NAMESPACE)' to delete them later$(NC)"; \
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
