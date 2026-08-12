#!/bin/sh
# Smoke test an opencbm image: tests/smoke.sh <image>
set -eu

image=${1:?usage: smoke.sh <image>}
here=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

ok() { echo "ok: $*"; }

ok "opencbm $(sed -n 's/^ARG OPENCBM_REF=//p' "${here}/../Dockerfile" | cut -c1-8)"

docker run --rm "${image}" cbmctrl --help >/dev/null
ok "cbmctrl runs"

docker run --rm "${image}" grep -qx 'default=xum1541' /etc/opencbm.conf
ok "xum1541 is the default plugin"

docker run --rm "${image}" \
  ldd /usr/local/lib/opencbm/plugin/libopencbm-xum1541.so | grep -q libusb-1.0
ok "xum1541 plugin links libusb"

echo "PASS ${image}"
