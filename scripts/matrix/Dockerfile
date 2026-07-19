FROM ubuntu:24.04@sha256:4fbb8e6a8395de5a7550b33509421a2bafbc0aab6c06ba2cef9ebffbc7092d90 AS matrix-base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        clang \
        curl \
        git \
        libclang-rt-18-dev \
        libcairo2-dev \
        libfontconfig1-dev \
        libfreetype-dev \
        libglib2.0-dev \
        liblzo2-dev \
        libpixman-1-dev \
        libpng-dev \
        llvm \
        meson \
        ninja-build \
        pkg-config \
        python3 \
        xz-utils \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ARG MOONBIT_INSTALL_VERSION=0.10.4+4f2e8f7dc-nightly

RUN printf '%s\n' \
        'retry = 5' \
        'retry-all-errors' \
        'retry-delay = 2' \
        'connect-timeout = 30' \
        'continue-at = -' \
        > /root/.curlrc

RUN curl -fsSL https://cli.moonbitlang.com/install/unix.sh -o /tmp/moonbit-install.sh \
    && MOONBIT_INSTALL_VERSION="${MOONBIT_INSTALL_VERSION}" \
        bash /tmp/moonbit-install.sh \
    && rm /tmp/moonbit-install.sh

ENV PATH="/root/.moon/bin:${PATH}"

FROM matrix-base AS lane-runner

COPY run-lane.sh /usr/local/bin/cairoon-matrix-lane

RUN chmod +x /usr/local/bin/cairoon-matrix-lane

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/cairoon-matrix-lane"]

FROM lane-runner AS system-cairo

ENV CAIROON_MATRIX_CAIRO_VERSION="1.18.0"

RUN test "$(pkg-config --modversion cairo)" = "${CAIROON_MATRIX_CAIRO_VERSION}"

FROM matrix-base AS exact-cairo

ARG CAIRO_VERSION
ARG CAIRO_URL
ARG CAIRO_SHA256

RUN curl -fsSL "${CAIRO_URL}" -o /tmp/cairo.tar.xz \
    && echo "${CAIRO_SHA256}  /tmp/cairo.tar.xz" | sha256sum --check --strict \
    && mkdir -p /tmp/cairo-source /tmp/cairo-build \
    && tar -xJf /tmp/cairo.tar.xz --strip-components=1 -C /tmp/cairo-source \
    && if [ -x /tmp/cairo-source/configure ]; then \
         cd /tmp/cairo-build \
         && /tmp/cairo-source/configure \
              --prefix="/opt/cairo-${CAIRO_VERSION}" \
              --enable-png=yes \
              --enable-ft=yes \
              --enable-fc=yes \
              --enable-pdf=yes \
              --enable-ps=yes \
              --enable-svg=yes \
              --enable-script=yes \
              --enable-tee=yes \
              --disable-xlib \
              --disable-xcb \
              --disable-gl \
              --disable-glesv2 \
              --disable-glesv3 \
              --disable-egl \
              --disable-glx \
              --disable-gobject \
         && make -j"$(nproc)" \
         && make install; \
       else \
         meson setup /tmp/cairo-build /tmp/cairo-source \
           --prefix="/opt/cairo-${CAIRO_VERSION}" \
           --libdir=lib \
           --buildtype=release \
           -Dfontconfig=enabled \
           -Dfreetype=enabled \
           -Dglib=disabled \
           -Dlzo=enabled \
           -Dpng=enabled \
           -Dspectre=disabled \
           -Dsymbol-lookup=disabled \
           -Dtee=enabled \
           -Dtests=disabled \
           -Dxcb=disabled \
           -Dxlib=disabled \
           -Dzlib=enabled \
         && meson compile -C /tmp/cairo-build -j "$(nproc)" \
         && meson install -C /tmp/cairo-build; \
       fi \
    && rm -rf /tmp/cairo.tar.xz /tmp/cairo-source /tmp/cairo-build

ENV PKG_CONFIG_PATH="/opt/cairo-${CAIRO_VERSION}/lib/pkgconfig"
ENV LD_LIBRARY_PATH="/opt/cairo-${CAIRO_VERSION}/lib"
ENV CAIROON_MATRIX_CAIRO_VERSION="${CAIRO_VERSION}"

COPY --from=lane-runner \
    /usr/local/bin/cairoon-matrix-lane \
    /usr/local/bin/cairoon-matrix-lane

RUN test "$(pkg-config --modversion cairo)" = "${CAIRO_VERSION}"

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/cairoon-matrix-lane"]
