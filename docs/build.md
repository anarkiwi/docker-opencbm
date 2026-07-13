# Building

```sh
docker build -t opencbm .
```

## Build arguments

| Arg | Default | Purpose |
| --- | --- | --- |
| `UBUNTU_VERSION` | `24.04` | Base image tag. |
| `OPENCBM_REF` | pinned commit | OpenCBM git ref (tag, branch, or SHA) to build. |

Build a different OpenCBM revision:

```sh
docker build --build-arg OPENCBM_REF=master -t opencbm:master .
```

The default ref tracks OpenCBM `master`, which builds against `libusb-1.0`. The
newest release *tag* (`v0_4_99_99a`) predates the libusb-1.0 migration and requires
`libusb-0.1`, so it is not used here.

## Multi-arch

CI builds `linux/amd64` and `linux/arm64` with Buildx. To build a single arch
locally for another platform:

```sh
docker buildx build --platform linux/arm64 -t opencbm:arm64 --load .
```

## How it works

Two-stage build:

1. **builder** — installs the toolchain (`build-essential`, `cc65`,
   `libusb-1.0-0-dev`, `libncurses-dev`, `pkg-config`), clones OpenCBM at
   `OPENCBM_REF`, builds `opencbm` + the `xum1541` plugin, and stages an install
   into `/out` via `DESTDIR`.
2. **runtime** — Ubuntu with only `libusb-1.0-0`, into which the staged binaries,
   plugin, man pages, and the auto-generated `/etc/opencbm.conf` (default plugin
   `xum1541`) are copied. `ldconfig` wires up `/usr/local/lib`.
