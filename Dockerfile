FROM golang:1.13-alpine AS builder

ENV GO111MODULE=on \
  CGO_ENABLED=0 \
  GOOS=linux \
  GOPROXY="http://goproxy.easystack.io,https://goproxy.cn,https://goproxy.io,direct"

RUN sed -e 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' -i /etc/apk/repositories
RUN apk add make git
WORKDIR /src
COPY . .

RUN make build

FROM alpine:3.18.2

RUN sed -e 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' -i /etc/apk/repositories
RUN apk --no-cache add ca-certificates

RUN addgroup -g 1001 appgroup && \
  adduser -H -D -s /bin/false -G appgroup -u 1001 appuser

USER 1001:1001
COPY --from=builder /src/releases/harbor_exporter /bin/harbor_exporter
ENTRYPOINT ["/bin/harbor_exporter"]
