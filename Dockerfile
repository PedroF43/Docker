FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 AS builder

ARG TARGETARCH
ARG GOFLAGS="'-ldflags=-w -s'"

# Install Go
RUN apt-get update && apt-get install -y git build-essential cmake
ADD https://dl.google.com/go/go1.21.1.linux-$TARGETARCH.tar.gz /tmp/go1.21.1.tar.gz
RUN tar -C /usr/local -xzf /tmp/go1.21.1.tar.gz

WORKDIR /go/src/github.com/jmorganca/ollama

COPY . .

ENV GOARCH=$TARGETARCH
ENV GOFLAGS=$GOFLAGS

# Skip the go mod download step as there are no Go modules defined
RUN /usr/local/go/bin/go generate ./...
RUN /usr/local/go/bin/go build .

FROM ubuntu:22.04

# Copy the built binary from the builder stage
COPY --from=builder /go/src/github.com/jmorganca/ollama/ollama /bin/ollama

RUN apt-get update && apt-get install -y ca-certificates

EXPOSE 11434
ENV OLLAMA_HOST 0.0.0.0

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]

