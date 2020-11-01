FROM 0x01be/icestorm as icestorm

FROM alpine as build

RUN apk add --no-cache --virtual nextpnr-build-dependencies \
    git \
    build-base \
    cmake \
    python3-dev \
    boost-dev

COPY --from=icestorm /opt/icestorm/ /opt/icestorm/
ENV PATH $PATH:/opt/icestorm/bin/

ENV REVISION master
RUN git clone --depth 1 --branch ${REVISION} https://github.com/YosysHQ/nextpnr.git /nextpnr

WORKDIR /nextpnr/build

RUN cmake \
    -DARCH=ice40 \
    -DBUILD_HEAP=OFF \
    -DBUILD_GUI=OFF \
    -DICESTORM_INSTALL_PREFIX=/opt/icestorm \
    -DCMAKE_INSTALL_PREFIX=/opt/nextpnr \
    ..
RUN make -j$(nproc)
RUN make install

FROM alpine

RUN apk add --no-cache --virtual nextpnr-runtime-dependencies \
    boost

COPY --from=build /opt/nextpnr/ /opt/nextpnr/

RUN adduser -D -u 1000 nextpnr

WORKDIR /workspace
RUN chown nextpnr:nextpnr /workspace

USER nextpnr

ENV PATH $PATH:/opt/nextpnr/bin/

