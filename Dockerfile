FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y build-essential git curl tar pkg-config nasm && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY build.sh .
RUN chmod +x build.sh && \
    ./build.sh