ARG COMMAND_EXECUTOR_VERSION=latest
FROM docker.io/aryazanov/command-executor:${COMMAND_EXECUTOR_VERSION} AS command-executor

FROM alpine:3.15.0
WORKDIR /
COPY --from=command-executor /bin/command-executor /bin/command-executor
RUN apk add --no-cache wget

ENTRYPOINT ["command-executor"]