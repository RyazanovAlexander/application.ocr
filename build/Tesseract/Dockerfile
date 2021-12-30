FROM docker.io/aryazanov/command-executor:0.1.0 AS command-executor

FROM ubuntu
WORKDIR /
COPY --from=command-executor /bin/command-executor /bin/command-executor
RUN apt-get update && apt-get install -y tesseract-ocr

ENTRYPOINT ["command-executor"]