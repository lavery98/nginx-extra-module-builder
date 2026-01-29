ARG DEBIAN_IMAGE=debian:trixie

FROM ${DEBIAN_IMAGE}

ARG NGINX_VERSION=1.29.4
ARG BUILD_MODULES

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

RUN if [ "$BUILD_MODULES" = "" ]; then \
        echo "No build modules specified, exiting"; \
        exit 1; \
    fi

RUN apt-get update \
    && apt-get install -y --no-install-suggests --no-install-recommends \
                patch make wget git devscripts debhelper dpkg-dev \
                quilt lsb-release build-essential libxml2-utils xsltproc \
                equivs git g++ libparse-recdescent-perl \
    && git clone https://github.com/nginx/pkg-oss/ \
    && cd pkg-oss \
    && mkdir /tmp/packages \
    && for module in $BUILD_MODULES; do \
        echo "Building $module for nginx-$NGINX_VERSION"; \
        if make -C /pkg-oss/debian list | grep -P "^$module\s+\d" > /dev/null; then \
            echo "Building $module from pkg-oss sources"; \
            cd /pkg-oss/debian; \
            make rules-module-$module BASE_VERSION=$NGINX_VERSION NGINX_VERSION=$NGINX_VERSION; \
            mk-build-deps --install --tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes" debuild-module-$module/nginx-$NGINX_VERSION/debian/control; \
            make module-$module BASE_VERSION=$NGINX_VERSION NGINX_VERSION=$NGINX_VERSION; \
            find ../../ -maxdepth 1 -mindepth 1 -type f -name "*.deb" -exec mv -v {} /tmp/packages/ \;; \
        else \
            echo "Don't know how to build $module module, exiting"; \
            exit 1; \
        fi; \
    done


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
