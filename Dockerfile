FROM 0x01be/prjtrellis as prjtrellis

FROM alpine:3.12.0 as builder

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

RUN git clone https://gitlab.com/libeigen/eigen.git /eigen

RUN mkdir /eigen/build/
WORKDIR /eigen/build/

RUN cmake ..
RUN make
RUN make install

RUN git clone https://github.com/YosysHQ/nextpnr.git /nextpnr

WORKDIR /nextpnr/

RUN cmake -DARCH=ecp5 -DBUILD_HEAP=ON -DBUILD_GUI=OFF -DTRELLIS_LIBDIR=/opt/prjtrellis/lib64/trellis -DTRELLIS_INSTALL_PREFIX=/opt/prjtrellis -DCMAKE_INSTALL_PREFIX=/opt/nextpnr .
RUN make -j$(nproc)
RUN make install

FROM alpine:3.12.0

COPY --from=builder /opt/nextpnr/ /opt/nextpnr/

ENV PATH $PATH:/opt/nextpnr/bin/

