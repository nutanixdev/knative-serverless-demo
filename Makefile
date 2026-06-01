REGISTRY ?= ghcr.io/nutanixdev
NKP_CONTEXT ?= nkp-dev
EKS_CONTEXT ?= eks-dev
KUBECONFIG_DIR ?= kubeconfigs
FUNC_NAME ?= hello
NAMESPACE ?= default

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make verify        - Check tools and current kube contexts"
	@echo "  make ghcr-login    - Login to GHCR"
	@echo "  make aws-login     - Login to AWS SSO"
	@echo "  make aws-check     - Check current AWS identity"
	@echo "  make create        - Create the Knative function"
	@echo "  make build         - Build the function image"
	@echo "  make deploy-nkp    - Deploy function to NKP"
	@echo "  make deploy-eks    - Deploy function to EKS"
	@echo "  make urls          - Show Knative service URLs"
	@echo "  make pods          - Show pods"
	@echo "  make watch-pods    - Watch pods"
	@echo "  make reset         - Delete function from current context"
	@echo "  make reset-all     - Delete function from NKP and EKS"
	@echo "  make kubeconfig    - Merge kubeconfig files from $(KUBECONFIG_DIR)/"
	@echo "  make ksvc          - Show Knative Services"
	@echo "  make revisions     - Show Knative Revisions"
	@echo "  make reset-nkp     - Delete function from NKP"
	@echo "  make reset-eks     - Delete function from EKS"

.PHONY: verify
verify:
	kubectl config get-contexts
	kn version
	kn func version
	pack version
	gh --version
	aws --version
	$(MAKE) aws-check
	docker ps

.PHONY: ghcr-login
ghcr-login:
	docker login ghcr.io

.PHONY: aws-login
aws-login:
	AWS_PAGER="" aws sso login

.PHONY: aws-check
aws-check:
	AWS_PAGER="" aws sts get-caller-identity || echo "AWS credentials not configured. Run: make aws-login"

.PHONY: kubeconfig
kubeconfig:
	@mkdir -p ~/.kube
	@if [ ! -d "$(KUBECONFIG_DIR)" ]; then \
		echo "Creating $(KUBECONFIG_DIR)/ directory..."; \
		mkdir -p "$(KUBECONFIG_DIR)"; \
		echo ""; \
		echo "Place your kubeconfig files in:"; \
		echo "  $(KUBECONFIG_DIR)/"; \
		echo ""; \
		echo "Supported extensions:"; \
		echo "  *.conf"; \
		echo "  *.kubeconfig"; \
		echo "  *.yaml"; \
		echo "  *.yml"; \
		exit 0; \
	fi
	@FILES=$$(find $(KUBECONFIG_DIR) -type f \( -name "*.conf" -o -name "*.kubeconfig" -o -name "*.yaml" -o -name "*.yml" \) | paste -sd ':' -); \
	if [ -z "$$FILES" ]; then \
		echo "No kubeconfig files found in $(KUBECONFIG_DIR)/"; \
		echo ""; \
		echo "Place your kubeconfig files there and run:"; \
		echo "  make kubeconfig"; \
		exit 0; \
	fi; \
	KUBECONFIG=$$FILES kubectl config view --flatten > ~/.kube/config
	@chmod 600 ~/.kube/config
	@kubectl config get-contexts

.PHONY: create
create:
	test ! -d $(FUNC_NAME) || (echo "$(FUNC_NAME) already exists" && exit 1)
	kn func create -l node -t http $(FUNC_NAME)

.PHONY: build
build:
	cd $(FUNC_NAME) && kn func build --registry $(REGISTRY)

.PHONY: deploy-nkp
deploy-nkp:
	kubectx $(NKP_CONTEXT)
	cd $(FUNC_NAME) && kn func deploy --registry $(REGISTRY)

.PHONY: deploy-eks
deploy-eks:
	kubectx $(EKS_CONTEXT)
	cd $(FUNC_NAME) && kn func deploy --registry $(REGISTRY)

.PHONY: urls
urls:
	kn service list -n $(NAMESPACE)

.PHONY: pods
pods:
	kubectl get pods -n $(NAMESPACE)

.PHONY: watch-pods
watch-pods:
	watch kubectl get pods -n $(NAMESPACE)

.PHONY: ksvc
ksvc:
	kubectl get ksvc -n $(NAMESPACE)

.PHONY: revisions
revisions:
	kubectl get revisions -n $(NAMESPACE)

.PHONY: reset
reset:
	kubectl delete ksvc $(FUNC_NAME) -n $(NAMESPACE) --ignore-not-found=true

.PHONY: reset-nkp
reset-nkp:
	kubectx $(NKP_CONTEXT)
	kubectl delete ksvc $(FUNC_NAME) -n $(NAMESPACE) --ignore-not-found=true

.PHONY: reset-eks
reset-eks:
	kubectx $(EKS_CONTEXT)
	kubectl delete ksvc $(FUNC_NAME) -n $(NAMESPACE) --ignore-not-found=true

.PHONY: reset-all
reset-all: reset-nkp reset-eks