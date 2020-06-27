FROM 0x01be/icestorm as icestorm

FROM alpine:3.12.0 as builder

COPY --from=icestorm /opt/icestorm/ /opt/icestorm/

ENV PATH $PATH:/opt/icestorm/bin/

RUN apk --no-cache add --virtual build-dependencies \
    build-base \
    cmake \
    git \
    python3 \
    eigen-dev \
    python3-dev \
    boost-dev

RUN git clone https://github.com/YosysHQ/nextpnr.git /nextpnr

WORKDIR /nextpnr/

RUN cmake -DARCH=ice40 -DBUILD_HEAP=OFF -DBUILD_GUI=OFF -DICESTORM_INSTALL_PREFIX=/opt/icestorm -DCMAKE_INSTALL_PREFIX=/opt/nextpnr .
RUN make -j$(nproc)
RUN make install

FROM alpine:3.12.0

COPY --from=builder /opt/nextpnr/ /opt/nextpnr/

ENV PATH $PATH:/opt/nextpnr/bin/

