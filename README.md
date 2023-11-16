# Utilityapp

## Build and Push Image
```bash
# (1) change image repo in `Makefile`
# (2) build image
make build
# (2) tag and push image
make tag TAG=<replace with tag>
```

## Change Revision
- `v2.7.2-r7`: includes kyverno cli v1.9.1
- `v2.7.2-r6`: ignore
- `v2.7.2-v5`: baseline
