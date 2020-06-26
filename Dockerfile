FROM 0x01be/icestorm as icestorm
FROM 0x01be/prjtrellis as prjtrellis

FROM alpine:3.12.0 as builder

COPY --from=icestorm /opt/icestorm/ /opt/icestorm/a
COPY --from=prjtrellis /usr/local/lib64/trellis/ /usr/local/lib64/trellis/
COPY --from=prjtrellis /usr/local/bin/ /usr/local/bin/
COPY --from=prjtrellis /usr/local/share/trellis/ /usr/local/share/trellis/

ENV PATH $PATH:/opt/icestorm/bin/:/usr/local/bin/

RUN apk --no-cache add --virtual build-dependencies \
    build-base \
    cmake \
    git \
    python3 \
    eigen-dev \
    python3-dev

RUN git clone https://github.com/YosysHQ/nextpnr.git /nextpnr

WORKDIR /nextpnr/

RUN cmake -DBUILD_GUI=OFF -DARCH=ecp5 -DBUILD_HEAP=OFF .
RUN make -j$(nproc)
RUN make install

FROM alpine:3.12.0

COPY --from=icestorm /opt/icestorm/ /opt/icestorm/
COPY --from=builder  /usr/local/bin/nextpnr-ecp5 /usr/local/bin/nextpnr-ecp5

ENV PATH /opt/icestorm/bin/:/usr/local/bin/:$PATH

