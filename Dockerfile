# syntax=docker/dockerfile:1

# OpenCBM in a container, built for the xum1541/ZoomFloppy USB adapter.
ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} AS builder
# Master builds against libusb-1.0; the newest release tag still needs libusb-0.1.
# Override with --build-arg OPENCBM_REF=<tag|branch|sha>.
ARG OPENCBM_REF=894195ca74445f05cdeebb1fda731982d0a0f25a
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cc65 \
        git \
        libncurses-dev \
        libusb-1.0-0-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone https://github.com/OpenCBM/OpenCBM.git . \
    && git checkout "${OPENCBM_REF}"

# Build core tools + the xum1541 (ZoomFloppy) plugin, then stage into /out.
RUN make -f LINUX/Makefile opencbm plugin-xum1541 \
    && make -f LINUX/Makefile DESTDIR=/out install install-plugin-xum1541

FROM ubuntu:${UBUNTU_VERSION} AS runtime
LABEL org.opencontainers.image.title="opencbm" \
      org.opencontainers.image.description="OpenCBM with xum1541/ZoomFloppy support on Ubuntu" \
      org.opencontainers.image.source="https://github.com/anarkiwi/docker-opencbm" \
      org.opencontainers.image.licenses="GPL-2.0-only"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        libusb-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/usr/local/bin/ /usr/local/bin/
COPY --from=builder /out/usr/local/lib/ /usr/local/lib/
COPY --from=builder /out/usr/local/man/ /usr/local/share/man/
COPY --from=builder /out/etc/opencbm.conf /etc/opencbm.conf
COPY --from=builder /out/etc/opencbm.conf.d/ /etc/opencbm.conf.d/
COPY --from=builder /out/etc/udev/rules.d/ /etc/udev/rules.d/
RUN echo /usr/local/lib > /etc/ld.so.conf.d/opencbm.conf && ldconfig

CMD ["cbmctrl", "--help"]
