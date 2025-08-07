FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y build-essential git curl tar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY build2.sh .
RUN chmod +x build2.sh && \
    ./build2.sh