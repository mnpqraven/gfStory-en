default:
    @just --list

update-deps:
    git submodule update --init --remote unpack/downloader unpack/gf-data-us

dev:
    nix develop --command pnpm dev

build:
    nix build
    ./result/bin/gfstory-build
