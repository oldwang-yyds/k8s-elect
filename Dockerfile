FROM hub.ucloudadmin.com/uaek/golang:1.15.15-alpine3.14 as builder

WORKDIR /go/src/github.com/friendly-u/k8s-elect/
COPY . .
# RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-mod=vendor go build -o elect main.go

# =============================================================================
FROM hub.ucloudadmin.com/uaek/alpine:3.9 AS final

RUN apk add --no-cache tzdata
ENV TZ=Asia/Shanghai

WORKDIR /app/
COPY --from=builder /go/src/github.com/friendly-u/k8s-elect/elect .
RUN chmod +x elect

ENTRYPOINT ["/app/elect"]