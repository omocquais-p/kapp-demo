# Generate images.yaml
generate-images-package:
	{ \
	rm -rf package-contents/.imgpkg ;\
	mkdir -p package-contents/.imgpkg ;\
	kbld -f package-contents/config/ --imgpkg-lock-output package-contents/.imgpkg/images.yml ;\
	}

# Push a bundle into a registry
bundle-package: generate-images-package
	{ \
	imgpkg push --bundle docker.io/omocquais/simple-app-packages:1.0.0 --file package-contents  ;\
	}

# Prepare Package Repository
bundle-package-repository: bundle-package
	{ \
	rm my-pkg-repo/.imgpkg/images.yml  ;\
	mkdir -p my-pkg-repo/.imgpkg my-pkg-repo/packages/simple-app.corp.com  ;\
	ytt -f package-template.yml  -v version="1.0.0" > my-pkg-repo/packages/simple-app.corp.com/1.0.0.yml ;\
	kbld -f my-pkg-repo/packages/ --imgpkg-lock-output my-pkg-repo/.imgpkg/images.yml  ;\
	}

# Push the Package repository
package-repository-push: bundle-package-repository
	imgpkg push -b docker.io/omocquais/simple-app-pkg-repo:1.0.0 -f my-pkg-repo

# Deploy the PackageRepository in the k8s cluster
deploy-package-repository: package-repository-push
	kapp deploy -a repo -f repo.yml -y

# Inspect PackageRepository and Package resources
packagerepository-infos:
	{ \
	kubectl get packagerepository ;\
	kubectl get packagemetadatas ;\
	kubectl get package simple-app.corp.com.1.0.0 -o yaml ;\
	}

# Deploy the package
deploy-package: delete-package deploy-package-repository
	kapp deploy -a pkg-demo-simple-app -f pkginstall.yml -y

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

delete-package-repo:
	kapp delete -a repo -y

delete-package: delete-package-repo
	kapp delete -a pkg-demo-simple-app -y


# Pre-requisites - Kapp Controller installation
install-kapp:
	kapp deploy -a kc -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml

# Pre-requisites - RBAC - required for package
deploy-rbac:
	kapp deploy -a default-ns-rbac -f ./rbac/default-ns.yml --yes
