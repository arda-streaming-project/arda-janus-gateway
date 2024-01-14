FROM ubuntu:23.04 as Builder

RUN apt-get -y update \
	&& apt-get install -y \
	libavutil-dev \
	libavformat-dev \
	libavcodec-dev \
	libmicrohttpd-dev \
	libjansson-dev \
	libssl-dev \
	libsofia-sip-ua-dev \
	libglib2.0-dev \
	libopus-dev \
	libogg-dev \
	libcurl4-openssl-dev \
	liblua5.3-dev \
	libconfig-dev \
	libusrsctp-dev \
	libwebsockets-dev \
	libsrtp2-dev \
	libnice-dev \
	pkg-config \
	gengetopt \
	libtool \
	automake \
	build-essential \
	wget \
	git \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN wget https://github.com/meetecho/janus-gateway/archive/refs/tags/v1.2.1.tar.gz \
	&& tar -xvf v1.2.1.tar.gz \
	&& cd janus-gateway-1.2.1 \
	&& sh autogen.sh \
	&& ./configure --enable-post-processing --prefix=/opt/janus \
	&& make \
	&& make install

COPY ./configuration /opt/janus/etc/janus/

FROM ubuntu:23.04 as Runtime

RUN apt-get -y update && \
	apt-get install -y \
	libmicrohttpd12 \
	libavutil-dev \
	libavformat-dev \
	libavcodec-dev \
	libjansson4 \
	libssl3 \
	libsofia-sip-ua0 \
	libglib2.0-0 \
	libopus0 \
	libogg0 \
	libcurl4 \
	liblua5.3-0 \
	libconfig9 \
	libusrsctp2 \
	libsrtp2-1 \
	libwebsockets17 \
	libnice10 \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=Builder /opt/janus/bin/janus /opt/janus/bin/janus
COPY --from=Builder /opt/janus/etc/janus /opt/janus/etc/janus
COPY --from=Builder /opt/janus/lib/janus /opt/janus/lib/janus
COPY --from=Builder /opt/janus/share/janus /opt/janus/share/janus

EXPOSE 8088
EXPOSE 8188

ENTRYPOINT [ "/opt/janus/bin/janus" ]