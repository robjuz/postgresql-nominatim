FROM bitnami/postgresql:latest as builder
ARG NOMINATIM_VERSION=3.7.2
USER 0

    # Do not start daemons after installation.
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

RUN apt-get update -y
RUN apt-get install -y \
    -o APT::Install-Recommends="false" \
    -o APT::Install-Suggests="false" \
    build-essential \
    g++ \
    cmake \
    lbzip2

RUN true \
    && curl https://nominatim.org/release/Nominatim-$NOMINATIM_VERSION.tar.bz2 -o nominatim.tar.bz2 \
    && tar xf nominatim.tar.bz2 \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_IMPORTER=off -DBUILD_API=off -DBUILD_TESTS=off -DBUILD_DOCS=off -DBUILD_OSM2PGSQL=off ../Nominatim-$NOMINATIM_VERSION \
    && make

FROM bitnami/postgresql:latest

COPY --from=builder build/module/nominatim.so /bitnami

VOLUME [ "/bitnami/postgresql", "/docker-entrypoint-initdb.d", "/docker-entrypoint-preinitdb.d" ]

EXPOSE 5432

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/postgresql/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/postgresql/run.sh" ]