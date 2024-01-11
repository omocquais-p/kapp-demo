```
ytt -f . | kapp deploy -a cloudnativepp -f - --yes
```

```
kapp deploy -a default-ns-rbac -f ./rbac/default-ns.yml --yes
```
