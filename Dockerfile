FROM ghcr.io/typst/typst:latest

RUN apk add --no-cache curl tar

ENV PKG_ROOT=/root/.local/share/typst/packages/preview/cmarker/0.1.8

# Download official prebuilt package (WASM already included)
RUN mkdir -p "$PKG_ROOT" && \
    curl -L "https://packages.typst.org/preview/cmarker-0.1.8.tar.gz" -o "/tmp/pkg.tar.gz" && \
    tar -xzf "/tmp/pkg.tar.gz" -C "$PKG_ROOT" && \
    rm "/tmp/pkg.tar.gz"

WORKDIR /work
ENTRYPOINT ["typst"]
