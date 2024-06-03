# Containers

Opinionated containers build specifically for my needs.

[![Quality gate](https://github.com/usma0118/containers/actions/workflows/Qualitygate.yml/badge.svg)](https://github.com/usma0118/containers/actions/workflows/Qualitygate.yml)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

## Architecture

These containers are build with [rootless](https://rootlesscontaine.rs/), [tini init](https://github.com/krallin/tini) and [multiple architecture](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/) containers for various applications.

## Available Images

Each Image will be built with a `rolling` tag, along with tags specific to it's version. Available Images Below

Container | Channel | Image
--- | --- | ---
[Cryfs](https://github.com/usma0118/containers/pkgs/container/containers%2Fcryfs) | stable | ghcr.io/usma0118/containers/cryfs
[EncFs](https://github.com/usma0118/containers/pkgs/container/containers%2Fencfs) | stable | ghcr.io/usma0118/containers/encfs
[dev Container](https://github.com/usma0118/containers/pkgs/container/containers%2Fdevcontainers%2Fbase) | stable | ghcr.io/usma0118/containers/.devcontainer/base
