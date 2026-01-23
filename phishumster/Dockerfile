FROM alpine:latest
LABEL MAINTAINER="https://github.com/htr-tech/zphisher"
WORKDIR /phishumster/
ADD . /phishumster
RUN apk add --no-cache bash ncurses curl unzip wget php 
CMD "./phishumster.sh"
