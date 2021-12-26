ARG COMMAND_EXECUTOR_VERSION=latest
FROM docker.io/aryazanov/command-executor:${COMMAND_EXECUTOR_VERSION} AS command-executor

FROM minio/mc:RELEASE.2021-04-22T17-40-00Z
WORKDIR /
COPY --from=command-executor /bin/command-executor /bin/command-executor

RUN chown 65535 /bin/command-executor
RUN mkdir /buckets && chown -R 65535 buckets
RUN mkdir /.mc && chown -R 65535 /.mc

USER 65535:65535
RUN mc config

ENTRYPOINT ["command-executor"]