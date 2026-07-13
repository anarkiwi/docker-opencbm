# Usage

The image ships OpenCBM configured with `xum1541` as the default plugin, so every
tool talks to a ZoomFloppy out of the box.

## USB passthrough

The ZoomFloppy enumerates as USB id `16d0:0504` (or `03eb:2ff0` in DFU/bootloader
mode). Grant the container access to it:

| Method | Flag | Notes |
| --- | --- | --- |
| Whole USB bus | `--device=/dev/bus/usb` | Simplest; works for one-shot commands. |
| Single device | `--device=/dev/bus/usb/003/004` | Tightest scope; path from `lsusb`. |
| Privileged | `--privileged -v /dev/bus/usb:/dev/bus/usb` | Fallback if `--device` is blocked; also survives replug. |

The container runs as root, so it opens the USB node directly — the host does not
need the OpenCBM udev rules installed.

## Common commands

Mount your working directory to read/write disk images:

```sh
alias opencbm='docker run --rm -it --device=/dev/bus/usb -v "$PWD:/data" -w /data anarkiwi/opencbm'

opencbm cbmctrl reset            # reset the IEC bus
opencbm cbmctrl status 8         # query drive 8 status channel
opencbm cbmctrl dir 8            # directory listing
opencbm d64copy 8 disk.d64       # read a 1541 disk to disk.d64
opencbm d64copy disk.d64 8       # write disk.d64 back to a disk
opencbm cbmformat 8 "mydisk,01"  # format a disk
opencbm cbmcopy -r 8 -o out.prg FILE   # copy a file off a disk
opencbm imgcopy image.d71 8      # 1571 / other formats
```

Run any tool with `--help` for full options, e.g. `opencbm d64copy --help`.

## Firmware updates

`xum1541cfg` updates the ZoomFloppy firmware. Put the device in DFU mode per the
[ZoomFloppy docs](https://www.go4retro.com/products/zoomfloppy/), then:

```sh
docker run --rm -it --device=/dev/bus/usb -v "$PWD:/data" -w /data \
    anarkiwi/opencbm xum1541cfg update firmware.hex
```

## Troubleshooting

- **`cannot query product name` / no device found** — confirm `lsusb` on the host
  shows `16d0:0504`. If you plugged the device in *after* starting a long-running
  container, use the privileged form above so replugs are visible.
- **Permission denied on the USB node** — use `--privileged` as a fallback; some
  hosts restrict `--device` cgroup rules.
- **Wrong plugin** — the default is `xum1541`; override per-command with
  `-@<plugin>` where supported, or edit `/etc/opencbm.conf.d/` and run
  `opencbm_plugin_helper_tools rebuild`.
