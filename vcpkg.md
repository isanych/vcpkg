# Our `vcpkg` Fork

This repository is our internal fork of `vcpkg`.

Its purpose is to provide a controlled package build environment for the
limited set of ports that we actually consume, rather than to mirror the full
upstream ecosystem or support every upstream configuration.

## What This Fork Is Used For

- Building and maintaining a selected subset of ports that we depend on
- Integrating our own custom ports and local fixes
- Supporting our internal platform and toolchain matrix
- Providing package layouts and triplets aligned with our products and build
  infrastructure

We also use the commercial version of Qt as part of this environment.

## Triplets

We maintain our own triplets:

- `x64l`
- `x64w`
- `x64ws`
- `x64wa`

These triplets reflect our supported deployment targets and packaging needs.

## Toolchains and Build Hosts

For Linux builds we currently use:

- GCC 15 on Debian 11
- GCC 15 on openSUSE Tumbleweed
- GCC 15 on Ubuntu 26.04
- GCC 14 on Debian 13
- GCC 14 on Ubuntu 24.04

For Windows builds we use:

- Visual Studio 2022
- Visual Studio 2026

## C++ Standard

Our current baseline is C++17.

We plan to migrate this environment and the ports we consume to C++20.
