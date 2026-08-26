FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wine32 xvfb python3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

CMD python3 -m http.server ${PORT:-10000} & (sleep 5 && for d in */; do (cd "$d" && xvfb-run wine "RakSAMP Lite.exe" &); done)