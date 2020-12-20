FROM alpine

MAINTAINER EgoFelix <docker@egofelix.de>

# Install packages
RUN apk --no-cache add \
    bash curl bind-tools && \
    mkdir -p /opt/servercow

# Install script
COPY functions.sh dnsUpdater.sh /opt/servercow/

# Entry
ENTRYPOINT /opt/servercow/dnsUpdater.sh
