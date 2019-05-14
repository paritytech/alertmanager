FROM golang:1.11-alpine AS build


ADD . /go/src/github.com/prometheus/alertmanager
WORKDIR /go/src/github.com/prometheus/alertmanager
RUN apk add --no-cache git make curl
RUN make build



FROM  prom/busybox:latest
LABEL maintainer="Parity Devops <devops-team@parity.io>"

COPY --from=build /go/src/github.com/prometheus/alertmanager/amtool          /bin/amtool
COPY --from=build /go/src/github.com/prometheus/alertmanager/alertmanager    /bin/alertmanager

RUN mkdir -p /alertmanager /etc/alertmanager && \
    chown -R nobody:nogroup /etc/alertmanager /alertmanager

USER       nobody
EXPOSE     9093
VOLUME     [ "/alertmanager" ]
WORKDIR    /alertmanager
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "--config.file=/etc/alertmanager/alertmanager.yml", \
             "--storage.path=/alertmanager" ]
