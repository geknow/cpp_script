FROM registry.sensetime.com/sensemaster/sensemedia_algoservice_gpu_base:1.1.0

RUN mkdir -p /sensetime/logs/service_logs /usr/local/src/source \
    && apt-get clean \
    && apt-get update \
    \
    && /bin/bash -c "/usr/bin/rsync -ah rsync://172.20.23.42:10873/volume/repository/source/poco-poco-1.9.0-release.tar.gz /usr/local/src/source; exit 0" \
    && cd /usr/local/src/source \
    && tar zxvf poco-poco-1.9.0-release.tar.gz \
    && cd /usr/local/src/source/poco-poco-1.9.0-release \
    && mkdir cmake-build \
    && cd cmake-build \
    && /usr/local/bin/cmake .. \
    && make -j10 \
    && make install \
    \
    && /bin/bash -c "/usr/bin/rsync -ah rsync://172.20.23.42:10873/volume/repository/source/openssl-1.1.0g.tar.gz /usr/local/src/source; exit 0" \
    && cd /usr/local/src/source \
    && tar zxvf openssl-1.1.0g.tar.gz \
    && cd /usr/local/src/source/openssl-1.1.0g \
    && ./config \
    && make -j10 \
    && make install \
    \
    && /bin/bash -c "/usr/bin/rsync -ah rsync://172.20.23.42:10873/volume/repository/source/curl-7.61.1.tar.gz /usr/local/src/source; exit 0" \
    && cd /usr/local/src/source \
    && tar zxvf curl-7.61.1.tar.gz \
    && cd /usr/local/src/source/curl-7.61.1 \
    && ./configure --with-ssl \
    && make -j10 \
    && make install \
    \
    && rm -rf /var/lib/apt/lists/* \
    /usr/local/src* 

ARG DB_TYPE 
ENV DB_TYPE=${DB_TYPE}
ARG CORE_TYPE
ENV CORE_TYPE=${CORE_TYPE}
ARG LICENSE_TYPE
ENV LICENSE_TYPE=${LICENSE_TYPE}

COPY sdk_release/models /usr/local/sensemedia/AlgoWorkServer/sdk_release/models
COPY sdk_release/data/${DB_TYPE}/db.feats_str   /usr/local/sensemedia/AlgoWorkServer/sdk_release/data/db.feats_str
COPY sdk_release/data/${DB_TYPE}/maps.lst   /usr/local/sensemedia/AlgoWorkServer/sdk_release/data/maps.lst
COPY sdk_release/conf/celebrity_config.json   /usr/local/sensemedia/AlgoWorkServer/sdk_release/conf/celebrity_config.json
COPY sdk_release/lib_${CORE_TYPE}/${LICENSE_TYPE} /usr/local/sensemedia/AlgoWorkServer/sdk_release/lib_${CORE_TYPE}/${LICENSE_TYPE}
COPY sdk_release/plugins /usr/local/sensemedia/AlgoWorkServer/sdk_release/plugins
COPY lib /usr/local/sensemedia/AlgoWorkServer/lib
COPY build_${CORE_TYPE}/debug/SenseMediaAlgoService_FilterCelebrity /usr/local/sensemedia/AlgoWorkServer/build_${CORE_TYPE}/release/SenseMediaAlgoService_FilterCelebrity
COPY run.sh /usr/local/sensemedia/AlgoWorkServer/run.sh
COPY conf/config.ini /usr/local/sensemedia/AlgoWorkServer/conf/
COPY licenses/SENSEMEDIA-PRODUCT-LICENSE.lic /usr/local/sensemedia/AlgoWorkServer/licenses/SENSEMEDIA-PRODUCT-LICENSE.lic

CMD ["sh", "-c", "./usr/local/sensemedia/AlgoWorkServer/run.sh release ${CORE_TYPE} ${LICENSE_TYPE}"]
