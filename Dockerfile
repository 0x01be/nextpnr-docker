FROM 0x01be/prjtrellis as prjtrellis
FROM 0x01be/eigen as eigen

FROM alpine as build

RUN apk add --no-cache --virtual nextpnr-build-dependencies \
    git \
    build-base \
    cmake \
    python3-dev \
    boost-dev

COPY --from=prjtrellis /opt/prjtrellis/ /opt/prjtrellis/
COPY --from=eigen /opt/eigen/include/* /usr/include/
ENV PATH ${PATH}:/opt/prjtrellis/bin/

ENV REVISION master
RUN git clone --depth 1 --branch ${REVISION} https://github.com/YosysHQ/nextpnr.git /nextpnr

WORKDIR /nextpnr/build

RUN cmake \
    -DARCH=ecp5 \
    -DBUILD_HEAP=ON \
    -DBUILD_GUI=OFF \
    -DTRELLIS_LIBDIR=/opt/prjtrellis/lib64/trellis \
    -DTRELLIS_INSTALL_PREFIX=/opt/prjtrellis \
    -DCMAKE_INSTALL_PREFIX=/opt/nextpnr \
    ..
RUN make -j$(nproc)
RUN make install

FROM alpine

RUN apk add --no-cache --virtual nextpnr-runtime-dependencies \
    boost

COPY --from=build /opt/nextpnr/ /opt/nextpnr/

WORKDIR /workspace
RUN adduser -D -u 1000 nextpnr && chown nextpnr:nextpnr /workspace

USER nextpnr
ENV PATH $PATH:/opt/nextpnr/bin/

