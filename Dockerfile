FROM docker.io/library/golang:1.24.5-alpine as builder
WORKDIR /go/src/github.com/squarefactory/submer-pod-exporter/
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o app .

# ---
FROM docker.io/library/busybox:1.37.0-musl

ENV HOST=0.0.0.0
ENV PORT=3000

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-muslc-amd64 /tini
RUN chmod +x /tini

RUN mkdir /app
RUN addgroup -S app && adduser -S -G app app
WORKDIR /app

COPY --from=builder /go/src/github.com/squarefactory/submer-pod-exporter/app .

RUN chown -R app:app .
USER app

EXPOSE 3000

ENTRYPOINT [ "/tini", "--", "./app" ]
