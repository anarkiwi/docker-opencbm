# docker-opencbm

[OpenCBM](https://github.com/OpenCBM/OpenCBM) in a Docker image (Ubuntu 24.04),
built with the `xum1541` plugin for the [ZoomFloppy](https://www.go4retro.com/products/zoomfloppy/)
USB adapter. Access Commodore drives (1541/1571/1581, IEEE, etc.) from any Linux host.

## Image

`anarkiwi/opencbm` — multi-arch (`linux/amd64`, `linux/arm64`).

## Quick start

```sh
# Reset the IEC bus (device 8 on the ZoomFloppy):
docker run --rm -it --device=/dev/bus/usb anarkiwi/opencbm cbmctrl reset

# Copy a disk to a .d64 image in the current directory:
docker run --rm -it --device=/dev/bus/usb -v "$PWD:/data" -w /data \
    anarkiwi/opencbm d64copy 8 game.d64
```

`--device=/dev/bus/usb` passes the ZoomFloppy through; the container runs as root
so it accesses the USB node directly (no host udev rules needed). Included tools:
`cbmctrl`, `cbmcopy`, `d64copy`, `d82copy`, `imgcopy`, `cbmformat`, `cbmforng`,
`cbmread`, `cbmwrite`, `xum1541cfg` (firmware update).

## Documentation

- [docs/usage.md](docs/usage.md) — commands, USB passthrough, firmware updates, troubleshooting.
- [docs/build.md](docs/build.md) — building locally, pinning the OpenCBM version.

## License

Packaging (this repo): see [LICENSE](LICENSE). OpenCBM itself is GPL-2.0-only and is
fetched from source at build time; no OpenCBM source is vendored here.
