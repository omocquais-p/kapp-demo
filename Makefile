# Clean
cleanup-package:
	{ \
	rm -rf package-contents/.imgpkg ;\
	mkdir -p package-contents/.imgpkg ;\
	}

# Generate images.yaml
generate-images-package: cleanup-package
	{ \
	kbld -f package-contents/config/ --imgpkg-lock-output package-contents/.imgpkg/images.yml ;\
	}

# Push a bundle into a registry
bundle-package: generate-images-package
	{ \
	imgpkg push --bundle docker.io/omocquais/simple-app-packages:1.0.0 --file package-contents  ;\
	}

cleanup-package-repository:
	{ \
	rm package-repo/.imgpkg/images.yml  ;\
	mkdir -p package-repo/.imgpkg package-repo/packages/simple-app.corp.com  ;\
	}

# Prepare Package Repository
bundle-package-repository: cleanup-package-repository bundle-package
	{ \
	ytt -f package-template/package-template.yml  -v version="1.0.0" > package-repo/packages/simple-app.corp.com/1.0.0.yml ;\
	kbld -f package-repo/packages/ --imgpkg-lock-output package-repo/.imgpkg/images.yml  ;\
	}

# Push the Package repository
package-repository-push: bundle-package-repository
	imgpkg push -b docker.io/omocquais/simple-app-pkg-repo:1.0.0 -f package-repo

# Deploy the PackageRepository in the k8s cluster
deploy-package-repository: package-repository-push
	kapp deploy -a repo -f packaging/repo.yml -y

# Inspect PackageRepository and Package resources
package-repository-infos:
	{ \
	kubectl get packagerepository ;\
	kubectl get packagemetadatas ;\
	kubectl get package simple-app.corp.com.1.0.0 -o yaml ;\
	}

# Deploy the package
deploy-package: delete-package deploy-package-repository
	kapp deploy -a pkg-demo-simple-app -f packaging/packageinstalls.yml -y

# Check Status
checks-post-install-package:
	{ \
  	kubectl get pods ;\
	kctrl package available list ;\
	kctrl package available get -p simple-app.corp.com/1.0.0 --values-schema  ;\
	}

# Service Port Forward
port-forward:
	kubectl port-forward service/simple-app 8080:8080

# Delete Package Repository
delete-package-repo:
	kapp delete -a repo -y

# Delete Package
delete-package: delete-package-repo
	kapp delete -a pkg-demo-simple-app -y

# Pre-requisites - Kapp Controller installation
install-kapp:
	kapp deploy -a kc -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml

# Pre-requisites - RBAC - required for package
deploy-rbac:
	kapp deploy -a default-ns-rbac -f ./k8s-cluster-setup/rbac/default-ns.yml --yes

# Inspect the application
inspect-cluster:
	{ \
	kapp inspect -a  pkg-demo.app --tree ;\
	kubectl api-resources --api-group packaging.carvel.dev ;\
	kctrl package available list ;\
	kctrl package available get -p simple-app.corp.com ;\
	}

# CLI Delete Package Repository
cli-delete-package-repository:
	{ \
	kctrl package repo delete -r simple-package-repository -y ;\
	kctrl package repo list ;\
	}

# CLI Add Package Repository
cli-add-package-repository:
	{ \
	kctrl package repo add -r simple-package-repository --url omocquais/simple-app-pkg-repo:1.0.0 --dangerous-allow-use-of-shared-namespace ;\
	kctrl package repo list ;\
	}

# CLI Add Package
cli-add-package:
	{ \
	kctrl package available list ;\
	kctrl package available get -p  simple-app.corp.com ;\
	kctrl package install -i pkg-demo -p simple-app.corp.com --version 1.0.0  --values-file cli/values-cli.yaml --dangerous-allow-use-of-shared-namespace ;\
	}

# CLI Delete Package
cli-delete-package:
	{ \
	kctrl package installed delete -i pkg-demo -y ;\
	}