# syntax=docker/dockerfile:1

## Build
FROM golang:1.19 AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
COPY .env ./
RUN go mod download

ADD . ./

RUN go build -o /tell-the-time

## Deploy
FROM gcr.io/distroless/base-debian11

WORKDIR /

COPY --from=build /tell-the-time /tell-the-time
COPY --from=build /app/.env /.env
COPY --from=build /app/web /web

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/tell-the-time"]