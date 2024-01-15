# Package a simple Spring Boot Application with Carvel 

## Pre-requisites

### Install kapp controller

```shell
  make install-kapp
```

### Deploy RBAC configuration

```shell
  make deploy-rbac
```

## Build and Deploy the Package (build & deploy the package repository are included)

```shell
  make deploy-package
```

## Documentation

- Package Contents Bundle

```shell
package-contents
└── config
    ├── config.yml
    └── values.yml
```

- Package Repository Bundle

```shell
my-pkg-repo
└── packages
    └── simple-app.corp.com
        ├── 1.0.0.yml
        └── metadata.yml
```

## Build and Deploy the Package (build & deploy the package repository are included) with CLI (kctrl)

## Consuming Packages using the CLI

### Delete the repository

```shell
make deploy-package-repository
```

### Add the repository (PackageRepository)

```shell
kctrl package repo add -r simple-package-repository --url omocquais/simple-app-pkg-repo:1.0.0 --dangerous-allow-use-of-shared-namespace
kctrl package repo list
```

### Installing a Package (PackageInstall)

```shell
kctrl package available get -p simple-app.corp.com/1.0.0 --values-schema
kctrl package install -i pkg-demo -p simple-app.corp.com --version 1.0.0  --dangerous-allow-use-of-shared-namespace
```

### Listing a package

```shell
kctrl package installed list  
```

### Deleting an installation

```shell
kctrl package installed delete -i pkg-demo -y
```

### Adding a PackageRepository to the cluster

- Create a Bundle

```shell
make bundle-create
```

- Push the bundle into a registry

```shell
make bundle-push
```

- Pull the bundle from a registry

```shell
make bundle-pull
```

- Pre-requisite (Package)

- Install kapp-controller in the kubernetes cluster
```shell
make install-kapp
```

# Package an application

- package-contents: 

```shell
.
└── config
    ├── config.yml # k8s manifests 
    └── values.yml
```

- my-pkg-repo: Package Repository definition (CRD)

```shell
.
└── packages
    └── simple-app.corp.com
        ├── 1.0.0.yml # reference to bundle: omocquais/simple-app-packages:1.0.0 
        └── metadata.yml
```

- package-template.yml - Package definition (CRD)

- Reference to bundle + YTT (config)
```shell
      fetch:
        - imgpkgBundle:
            image: #@ "omocquais/simple-app-packages:" + data.values.version
```

- pksginstall.yml - PackageInstall (CRD)

```shell
  packageRef:
    refName: simple-app.corp.com
    versionSelection:
      constraints: 1.0.0
```