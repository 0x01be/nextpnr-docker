FROM 0x01be/icestorm as icestorm

FROM alpine as builder

COPY --from=icestorm /opt/icestorm/ /opt/icestorm/

ENV PATH $PATH:/opt/icestorm/bin/

RUN apk add --no-cache --virtual nextpnr-build-dependencies \
    git \
    build-base \
    cmake \
    python3-dev \
    boost-dev

RUN git clone --depth 1 https://github.com/YosysHQ/nextpnr.git /nextpnr

WORKDIR /nextpnr

RUN cmake -DARCH=ice40 -DBUILD_HEAP=OFF -DBUILD_GUI=OFF -DICESTORM_INSTALL_PREFIX=/opt/icestorm -DCMAKE_INSTALL_PREFIX=/opt/nextpnr .
RUN make -j$(nproc)
RUN make install

FROM alpine

RUN apk add --no-cache --virtual nextpnr-runtime-dependencies \
    boost

COPY --from=builder /opt/nextpnr/ /opt/nextpnr/

ENV PATH $PATH:/opt/nextpnr/bin/

