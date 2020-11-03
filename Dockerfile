FROM 0x01be/icestorm as icestorm
FROM 0x01be/prjtrellis as prjtrellis
FROM 0x01be/eigen as eigen

FROM alpine as build

RUN apk add --no-cache --virtual nextpnr-build-dependencies \
    git \
    build-base \
    cmake \
    python3-dev \
    boost-dev \
    qt5-qtbase-dev \
    qt5-qttools-dev \
    qt5-qtsvg-dev

COPY --from=icestorm /opt/icestorm/ /opt/icestorm/
COPY --from=prjtrellis /opt/prjtrellis/ /opt/prjtrellis/
COPY --from=eigen /opt/eigen/ /opt/eigen/
ENV PATH ${PATH}:/opt/prjtrellis/bin/:/opt/icestorm/bin/

ENV REVISION master
RUN git clone --depth 1 --branch ${REVISION} https://github.com/YosysHQ/nextpnr.git /nextpnr

WORKDIR /nextpnr/build

ENV CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}:/opt/eigen/:/opt/prjtrellis/:/opt/icestorm/
RUN cmake \
    -DARCH="ice40;ecp5" \
    -DBUILD_HEAP=ON \
    -DBUILD_GUI=ON \
    -DTRELLIS_LIBDIR=/opt/prjtrellis/lib64/trellis \
    -DTRELLIS_INSTALL_PREFIX=/opt/prjtrellis \
    -DICESTORM_INSTALL_PREFIX=/opt/icestorm \
    -DCMAKE_INSTALL_PREFIX=/opt/nextpnr \
    ..
RUN make -j$(nproc)
RUN make install

FROM 0x01be/xpra

RUN apk add --no-cache --virtual nextpnr-runtime-dependencies \
    boost \
    qt5-qtbase \
    qt5-qttools \
    qt5-qtsvg \
    mesa-gl \
    mesa-dri-swrast

COPY --from=build /opt/icestorm/ /opt/icestorm/
COPY --from=build /opt/nextpnr/ /opt/nextpnr/

USER ${USER}
ENV PATH=${PATH}:/opt/prjtrellis/bin/:/opt/nextpnr/bin/:/opt/icestorm/bin/ \
    COMMAND="nextpnr-ecp5 --gui"

