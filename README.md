# akkabuild

The build script to generate some RPM for https://github.com/Altiscale/akka branch `alti-v2.3.16`.
We use version `2.3.16` which is part of `release-2.3` form upstream.

The script here is a simple one that just wrap existing JARs from maven repo.
We currently don't re-build them from source until we need to tweak/patch the source code
or customize it. Currently, we are taking it as-is.


Adding submodules
```
git submodule add -b alti-v2.3.16 https://github.com/Altiscale/akka.git
```

IF you run `docker.sh` locally on your Mac, it will not work due to `id -g` is showing an existing
GID (e.g. `20`) that conflicts with an existing GID already in the base image.
