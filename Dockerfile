FROM phusion/baseimage:latest
# 0.9.19

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

EXPOSE 1883 1884

RUN apt-get update && apt-get install -y cmake libc-ares-dev uuid-dev daemon wget zlib1g-dev libssl-dev build-essential g++ && \
    wget --no-check-certificate https://libwebsockets.org/git/libwebsockets/snapshot/libwebsockets-1.4-chrome43-firefox-36.tar.gz && \
    tar zxvf libwebsockets* && cd libwebsockets* && mkdir build && cd build &&  cmake .. && make install && ldconfig && \
    cd && wget http://mosquitto.org/files/source/mosquitto-1.4.1.tar.gz && tar zxvf mosquitto-1.4.1.tar.gz && cd mosquitto-1.4.1 && \
    sed -i -e 's/WITH_WEBSOCKETS:=no/WITH_WEBSOCKETS:=yes/g' config.mk && make && make install

RUN mkdir -p /mqtt/config /mqtt/data /mqtt/log
COPY mosquitto.conf /mqtt/config/mosquitto.conf
VOLUME ["/mqtt/config", "/mqtt/data", "/mqtt/log"]

RUN mkdir /etc/service/mqtt
ADD mosquitto.sh /etc/service/mqtt/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
