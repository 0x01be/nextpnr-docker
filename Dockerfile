FROM 0x01be/icestorm as icestorm
FROM 0x01be/prjtrellis as prjtrellis

FROM alpine:3.12.0 as builder

COPY --from=icestorm /opt/icestorm/ /opt/icestorm/
COPY --from=prjtrellis /opt/prjtrellis/ /opt/prjtrellis/

ENV PATH $PATH:/opt/icestorm/bin/:/opt/prjtrellis/bin/

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

RUN cmake -DARCH=ecp5 -DBUILD_HEAP=OFF -DBUILD_GUI=OFF -DTRELLIS_LIBDIR=/opt/prjtrellis/lib64/trellis -DTRELLIS_INSTALL_PREFIX=/opt/prjtrellis .
RUN make -j$(nproc)
RUN make install

FROM alpine:3.12.0

COPY --from=icestorm /opt/icestorm/ /opt/icestorm/
COPY --from=builder  /usr/local/bin/nextpnr-ecp5 /usr/local/bin/nextpnr-ecp5

ENV PATH /opt/icestorm/bin/:/usr/local/bin/:$PATH

