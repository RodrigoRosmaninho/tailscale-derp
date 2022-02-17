FROM golang:alpine AS builder
RUN go install tailscale.com/cmd/derper@main

FROM tailscale/tailscale:latest
WORKDIR /app

COPY --from=builder /go/bin/derper .
COPY init.sh .

ENTRYPOINT /bin/sh /app/init.sh
