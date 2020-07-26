FROM 0x01be/icestorm as icestorm

FROM alpine:3.12.0 as builder

COPY --from=icestorm /opt/icestorm/ /opt/icestorm/

ENV PATH $PATH:/opt/icestorm/bin/

RUN apk add --no-cache --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    git \
    build-base \
    cmake \
    eigen-dev \
    python3-dev \
    boost-dev

RUN git --depth 1 clone https://github.com/YosysHQ/nextpnr.git /nextpnr

WORKDIR /nextpnr

RUN cmake -DARCH=ice40 -DBUILD_HEAP=OFF -DBUILD_GUI=OFF -DICESTORM_INSTALL_PREFIX=/opt/icestorm -DCMAKE_INSTALL_PREFIX=/opt/nextpnr .
RUN make -j$(nproc)
RUN make install

FROM alpine:3.12.0

RUN apk add --no-cache --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    boost

COPY --from=builder /opt/nextpnr/ /opt/nextpnr/

ENV PATH $PATH:/opt/nextpnr/bin/

