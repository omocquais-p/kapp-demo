bundle-create:
	{ \
  	cd app ;\
  	rm -rf .imgpkg ;\
	mkdir .imgpkg ;\
	kbld -f deploy.yml --imgpkg-lock-output .imgpkg/images.yml ;\
	}

bundle-push: bundle-create
	{ \
	imgpkg push --bundle docker.io/omocquais/carvel-demo:cnd --file app  ;\
	}

bundle-pull:
	{ \
  	imgpkg pull --bundle docker.io/omocquais/carvel-demo:cnd --output tmp ;\
	}

generate-deployment:
	{ \
  	cd tmp ;\
  	kbld -f ./deploy.yml -f .imgpkg/images.yml ;\
	}

deploy-rbac:
	kapp deploy -a default-ns-rbac -f ./rbac/default-ns.yml --yes
