FROM alpine

RUN apk --no-cache add bash

VOLUME /shared /script

WORKDIR /script

# COPY ./script.sh .

ENTRYPOINT /bin/bash ./script.sh
