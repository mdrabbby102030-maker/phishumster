FROM alpine:latest
LABEL MAINTAINER="https://github.com/mdrabbby102030-maker/phishumster"
WORKDIR /Phishumster/
ADD . /Phishumster
RUN apk add --no-cache bash ncurses curl unzip wget php 
CMD "./Phishumster.sh"
