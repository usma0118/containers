# Containers

Opinionated containers build specifically for my needs.

## Architecture

These containers are build with [rootless](https://rootlesscontaine.rs/), [tini init](https://github.com/krallin/tini) and [multiple architecture](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/) containers for various applications.

## Available Images

Each Image will be built with a `rolling` tag, along with tags specific to it's version. Available Images Below

Container | Channel | Image
--- | --- | ---
[Cryfs](https://github.com/onedr0p/containers/pkgs/container/actions-runner) | stable | ghcr.io/usma0118/containers/cryfs
[EncFs](https://github.com/onedr0p/containers/pkgs/container/bazarr) | stable | ghcr.io/usma0118/containers/encfs
[dev Container](https://github.com/onedr0p/containers/pkgs/container/home-assistant) | stable | ghcr.io/usma0118/containers/.devcontainer/base
