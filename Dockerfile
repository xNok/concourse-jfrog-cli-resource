FROM golang:alpine AS builder

COPY go/ /go/
ENV CGO_ENABLED 0
ENV GOOS linux 
ENV GOARCH amd64
RUN go build -a -ldflags="-w -s" -o /go/bin/sort-versions github.com/emerald-squad/artifactory-resource/sort-versions
RUN go test github.com/emerald-squad/artifactory-resource/sort-versions/versioning

FROM docker.bintray.io/jfrog/jfrog-cli-go:1.24.3 AS resource

RUN apk --no-cache add \
      curl \
      jq \
      bash \
      git

ENV JFROG_CLI_LOG_LEVEL=INFO

COPY --from=builder /go/bin/sort-versions /usr/local/bin/
COPY assets/ /opt/resource/

FROM resource