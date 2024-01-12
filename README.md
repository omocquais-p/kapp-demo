# 

- Create a Bundle

```
make bundle-create
```

- Push the bundle into a registry

```
make bundle-push
```

- Pull the bundle from a registry

```
make bundle-pull
```

- Pre-requisite (Package)

- Install kapp-controller in the kubernetes cluster
```
make install-kapp
```

# Package an application

- package-contents: 

```
.
└── config
    ├── config.yml # k8s manifests 
    └── values.yml
```

- my-pkg-repo: Package Repository definition (CRD)
```
.
└── packages
    └── simple-app.corp.com
        ├── 1.0.0.yml # reference to bundle: omocquais/simple-app-packages:1.0.0 
        └── metadata.yml
```

- package-template.yml - Package definition (CRD)
- Reference to bundle + YTT (config)
```
      fetch:
        - imgpkgBundle:
            image: #@ "omocquais/simple-app-packages:" + data.values.version
```

- pksginstall.yml - PackageInstall (CRD)
```
  packageRef:
    refName: simple-app.corp.com
    versionSelection:
      constraints: 1.0.0
``` 

# TODO
- ytt - update replicas and deployment name
- package
  env:
  - name: HELLO_MSG
  value: #@ data.values.hello_msg